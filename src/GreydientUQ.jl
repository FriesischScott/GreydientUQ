module GreydientUQ

using Reexport

@reexport using Distributions

using QuasiMonteCarlo

abstract type AbstractMonteCarlo end

# Structs
export Model
export MonteCarlo
export SobolSampling

# Methods
export sample
export evaluate
export probability_of_failure

struct MonteCarlo <: AbstractMonteCarlo
    n::Int
end

struct SobolSampling <: AbstractMonteCarlo
    n::Int
end

function sample(rvs::Vector{T} where {T<:UnivariateDistribution}, sim::MonteCarlo)
    x = fill(0.0, (sim.n, length(rvs)))

    for i in eachindex(rvs)
        x[:, i] = rand(rvs[i], sim.n)
    end

    return x
    # return mapreduce(rv -> rand(rv, n), hcat, rvs)
end

function sample(rvs::Vector{T} where {T<:UnivariateDistribution}, sim::SobolSampling)
    s = QuasiMonteCarlo.sample(sim.n, zeros(length(rvs)), ones(length(rvs)), SobolSample())

    return mapreduce((rv, row) -> quantile.(rv, row), hcat, rvs, eachrow(s))
end

struct Model
    f::Function
end

function evaluate(m::Model, x::Matrix)
    return m.f(x)
end

function probability_of_failure(rvs::Vector{T} where {T<:UnivariateDistribution}, m::Model, performance::Function, sim::AbstractMonteCarlo)
    x = sample(rvs, sim)
    y = evaluate(m, x)

    g = performance(y)

    pf = sum(g .< 0) / sim.n

    variance = (pf - pf^2) / sim.n
    cov = sqrt(variance) / pf

    return pf, x, cov
end

end # module GreydientUQ
