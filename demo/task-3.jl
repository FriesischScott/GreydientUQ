using GreydientUQ

l = 1.8
b = 0.12

h = Normal(0.24, 0.01)
E = LogNormal(23.0, 0.16)
P = LogNormal(8.5, 0.08)
ρ = LogNormal(6.37, 0.23)

rvs = [h, E, P, ρ]

function displacement(x::Matrix)
    I = b .* x[:, 1] .^ 3 / 12

    return (x[:, 4] .* 9.81 .* b .* x[:, 1] .* l .^ 4) ./ (8 .* x[:, 2] .* I) .+
           (x[:, 3] .* l .^ 3) ./ (3 .* x[:, 2] .* I)
end

m = Model(displacement)

max_displacement = 0.01

function performance(x::Vector)
    return max_displacement .- x
end

pf, x, cov = probability_of_failure(rvs, m, performance, MonteCarlo(10000000))

println("Probability of failure: $pf")
