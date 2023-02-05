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
         the ``j``th point to the ``i``th cluster.
"""
function fuzzy_cmeans(X::Matrix{T}, N::Int; m = 2.0, maxiter = 100,
                      tol = 1e-5) where {T <: Real}
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
