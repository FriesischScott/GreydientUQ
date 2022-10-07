using GreydientUQ
using Plots

rv1 = Normal()
rv2 = Normal(1, 0.5)

rvs = [rv1, rv2]

x = sample(rvs, MonteCarlo(1000))

histogram(x[:, 1], bins=50, alpha=0.8, label="x1")
histogram!(x[:, 2], bins=50, alpha=0.8, label="x2")
