using FuzzyLogic, MacroTools, Test

@testset "compile Mamdani fuzzy system" begin
    fis = @mamfis function tipper(service, food)::tip
        service := begin
            domain = 0:10
            poor = GaussianMF(0.0, 1.5)
            good = GaussianMF(5.0, 1.5)
            excellent = GaussianMF(10.0, 1.5)
        end

        food := begin
            domain = 0:10
            rancid = TrapezoidalMF(-2, 0, 1, 3)
            delicious = TrapezoidalMF(7, 9, 10, 12)
        end

        tip := begin
            domain = 0:30
            cheap = TriangularMF(0, 5, 10)
            average = TriangularMF(10, 15, 20)
            generous = TriangularMF(20, 25, 30)
        end

        service == poor || food == rancid --> tip == cheap * 0.5
        service == good && food != rancid --> tip == average
        service == excellent || food == delicious --> tip == generous
    end

    fis_ex = compilefis(fis)

    # construct output range outside, since LinRange repr changed between 1.6 and 1.8
    out_dom = LinRange(0.0, 30.0, 101)
    ref_ex = prettify(:(function tipper(service, food)
                            poor = exp(-((service - 0.0)^2) / 4.5)
                            good = exp(-((service - 5.0)^2) / 4.5)
                            excellent = exp(-((service - 10.0)^2) / 4.5)
                            rancid = max(min((food - -2) / 2, 1, (3 - food) / 2), 0)
                            delicious = max(min((food - 7) / 2, 1, (12 - food) / 2), 0)
                            ant1 = max(poor, rancid)
                            ant2 = min(good, 1 - rancid)
                            ant3 = max(excellent, delicious)
                            tip_agg = collect($out_dom)
                            @inbounds for (i, x) in enumerate(tip_agg)
                                cheap = max(min((x - 0) / 5, (10 - x) / 5), 0)
                                average = max(min((x - 10) / 5, (20 - x) / 5), 0)
                                generous = max(min((x - 20) / 5, (30 - x) / 5), 0)
                                tip_agg[i] = max(max(0.5 * min(ant1, cheap),
                                                     min(ant2, average)),
                                                 min(ant3, generous))
                            end
                            tip = ((2 *
                                    sum((mfi * xi
                                         for (mfi, xi) in zip(tip_agg, $out_dom))) -
                                    first(tip_agg) * 0) - last(tip_agg) * 30) /
                                  ((2 * sum(tip_agg) - first(tip_agg)) - last(tip_agg))
                            return tip
                        end))

    @test string(fis_ex) == string(ref_ex)

    fname = joinpath(tempdir(), "tmp.jl")
    compilefis(fname, fis, :tipper2)
    include(fname)

    @test fis((2, 7))[:tip] ≈ tipper2(2, 7)

    rm(fname)
end

@testset "compile sugeno system" begin
    fis = @sugfis function tipper(service, food)::tip
        service := begin
            domain = 0:10
            poor = GaussianMF(0.0, 1.5)
            good = GaussianMF(5.0, 1.5)
            excellent = GaussianMF(10.0, 1.5)
        end

        food := begin
            domain = 0:10
            rancid = TrapezoidalMF(-2, 0, 1, 3)
            delicious = TrapezoidalMF(7, 9, 10, 12)
        end

        tip := begin
            domain = 0:30
            cheap = 5.002
            average = 15
            generous = 2service, 0.5food, 5.0
        end

        service == poor || food == rancid --> tip == cheap * 0.5
        service == good --> tip == average
        service == excellent || food == delicious --> tip == generous
    end

    fis_ex = compilefis(fis)

    ref_ex = prettify(:(function tipper(service, food)
                            poor = exp(-((service - 0.0)^2) / 4.5)
                            good = exp(-((service - 5.0)^2) / 4.5)
                            excellent = exp(-((service - 10.0)^2) / 4.5)
                            rancid = max(min((food - -2) / 2, 1, (3 - food) / 2), 0)
                            delicious = max(min((food - 7) / 2, 1, (12 - food) / 2), 0)
                            ant1 = 0.5 * ((poor + rancid) - poor * rancid)
                            ant2 = good
                            ant3 = (excellent + delicious) - excellent * delicious
                            tot_weight = ant1 + ant2 + ant3
                            cheap = 5.002
                            average = 15
                            generous = 5.0 + 2.0service + 0.5 * food
                            tip = (ant1 * cheap + ant2 * average + ant3 * generous) /
                                  tot_weight
                            return tip
                        end))

    @test string(fis_ex) == string(ref_ex)

    fname = joinpath(tempdir(), "tmp.jl")
    compilefis(fname, fis, :tipper2)
    include(fname)

    @test fis((2, 7))[:tip] ≈ tipper2(2, 7)

    rm(fname)
end
