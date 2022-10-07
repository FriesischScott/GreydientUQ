module GreydientUQ

using Reexport

@reexport using Distributions

# Structs
export Model

# Methods
export sample
export evaluate
export probability_of_failure

function sample(rvs::Vector{T} where {T<:UnivariateDistribution}, n::Int)
    x = fill(0.0, (n, length(rvs)))

    for i in eachindex(rvs)
        x[:, i] = rand(rvs[i], n)
    end

    return x
    # return mapreduce(rv -> rand(rv, n), hcat, rvs)
end

struct Model
    f::Function
end

function evaluate(m::Model, x::Matrix)
    return m.f(x)
end

function probability_of_failure(rvs::Vector{T} where {T<:UnivariateDistribution}, m::Model, performance::Function, n::Int)
    x = sample(rvs, n)
    y = evaluate(m, x)

    g = performance(y)

    pf = sum(g .< 0) / n

    variance = (pf - pf^2) / n
    cov = sqrt(variance) / pf

    return pf, x, cov
end

end # module GreydientUQ
