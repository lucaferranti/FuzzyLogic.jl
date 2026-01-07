
"""
Performs fuzzy clustering on th data `X` using `N` clusters.

### Input

- `X` -- ``d × M`` matrix of data, each column is a data point
- `N` -- number of clusters used.

### Keyword argumes

- `m` -- exponent of the fuzzy membership function, default `2.0`
- `maxiter` -- maximum number of iterations, default `100`
- `tol` -- absolute error for stopping condition. Stop if ``|Eₖ - Eₖ₊₁|≤tol``, where ``Eₖ``
           is the cost function value at the ``k``:th iteration.
### Output

- `C` -- ``d × N``matrix of centers, each column is the center of a cluster.
- `U` -- ``M × N`` matrix of membership degrees, `Uᵢⱼ`` tells has the membership degree of
         the ``i``th point to the ``j``th cluster.
"""
function fuzzy_cmeans(X::Matrix{T}, N::Int; m = 2.0, maxiter = 100,
                      tol = 1e-5) where {T <: Real}
    m > 1 || throw(ArgumentError("m must be greater than 1"))
    e = 1 / (m - 1)
    M = size(X, 2)
    U = rand(float(T), M, N)
    C = X * U .^ m ./ sum(U .^ m; dims = 1)

    J = zero(float(T))
    @inbounds for (j, cj) in enumerate(eachcol(C))
        for (i, xi) in enumerate(eachcol(X))
            J += U[i, j]^m * sum(abs2(k) for k in xi - cj)
        end
    end

    @inbounds for i in 1:maxiter
        for (j, cj) in enumerate(eachcol(C))
            for (i, xi) in enumerate(eachcol(X))
                U[i, j] = 1 /
                          sum(sum(abs2.(xi - cj)) / sum(abs2.(xi - ck))
                              for ck in eachcol(C))^e
            end
        end
        C .= X * U .^ m ./ sum(U .^ m; dims = 1)

        Jnew = zero(float(T))
        for (j, cj) in enumerate(eachcol(C))
            for (i, xi) in enumerate(eachcol(X))
                Jnew += U[i, j]^m * sum(abs2(k) for k in xi - cj)
            end
        end
        abs(J - Jnew) <= tol && break
        J = Jnew
    end
    return C, U
end

"""
Performs fuzzy clustering on the data `X` using `C` clusters.

### Input

- `X` -- ``d × N`` matrix of data, each column is a data point
- `C` -- number of clusters used.

### Keyword arguments

- `α` -- exponent of the fuzzy membership function, default `2.0`
- `ρ` -- ``1 × C`` vector of normalization factors for cluster sizes, default `ones(C)`
- `maxiter` -- maximum number of iterations, default `100`
- `tol` -- absolute error for stopping condition. Stop if ``|Eₖ - Eₖ₊₁|≤tol``, where ``Eₖ``
           is the cost function value at the ``k``:th iteration.
- `stabilize` -- applies covariance matrix stabilization proposed by Babuska et. al., default `true`
- `γ` -- regularization coefficient, only used when stabilize is true, default `0.1`
- `β` -- condition number threshold, only used when stabilize is true, default `10^15`
### Output

- `V` -- ``d × N``matrix of centers, each column is the center of a cluster.
- `W` -- ``N × C`` matrix of membership degrees, ``Wᵢⱼ`` tells has the membership degree of
         the ``i``th point to the ``j``th cluster.
"""
function gustafson_kessel(X::Matrix{T}, C::Int; α=2.0, ρ = ones(C),
    maxiter=100, tol=1e-5, stabilize=true, γ=0.1, β=10^15) where {T <: Real}

    α > 1 || throw(ArgumentError("α must be greater than 1"))
    size(ρ, 1) == C || throw(ArgumentError("length of ρ must equal to C"))
    γ >= 0 && γ <= 1 || throw(ArgumentError("γ must be within the range [0, 1]"))

    N = size(X, 2)
    d = size(X, 1)
    W = rand(float(T), N, C)
    W ./= sum(W, dims=2)
    distances = zeros(N, C)
    e = 2 / (α - 1)
    J = Inf
    P0_det = stabilize ? det(cov(X')) ^(1/d) : zero(float(T))

    V = Matrix{float(T)}(undef, d, C)

    @inbounds for iter in 1:maxiter
        pow_W = W .^ α
        W_sum = sum(pow_W, dims=1)
        V .= (X * pow_W) ./ W_sum
        for (i, vi) in enumerate(eachcol(V))
            P = zeros(d, d)
            for (j, xj) in enumerate(eachcol(X))
                sub = xj - vi
                P += pow_W[j, i] .* sub * sub'
            end

            P ./= W_sum[1, i]
            stabilize && _recalculate_cov_matrix(P, γ, β, P0_det)
            A = (ρ[i] * det(P))^(1/d) * inv(P)

            for (j, xj) in enumerate(eachcol(X))
                sub = xj - vi
                distances[j, i] = sub' * A * sub
            end
        end

        J_new = 0
        for (i, di) in enumerate(eachrow(distances))
            idx = findfirst(==(0), di)

            if idx === nothing
                for (j, dij) in enumerate(di)
                    denom = sum((dij ./ di[k]) .^ e for k in 1:C)
                    W[i, j] = 1/denom
                    J_new += W[i, j] * dij
                end
            else
                result = zeros(N)
                result[idx] = 1
                W[i, :] .= result
            end
        end

        abs(J - J_new) < tol && break
        J = J_new
    end

    return V, W
end

function _recalculate_cov_matrix(P::Matrix{Float64}, γ::Number,
                                β::Int, P0_det::Float64)
    temp_P = (1 - γ) * P + γ * P0_det * I(size(P, 1))
    eig = eigen(Symmetric(temp_P))
    eig_vals = eig.values
    max_val = maximum(eig_vals)

    eig_vals[max_val ./ eig_vals .> β] .= max_val / β

    P .= eig.vectors * diagm(eig_vals) * eig.vectors'
end
