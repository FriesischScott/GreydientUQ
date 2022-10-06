# Uncertainty Quantification with Julia

In this workshop we will build a small package capable of computing the probability of failure for simple models written in Julia and arbitrary numbers of random variables using standard Monte Carlo simulation.

## Prerequisites

Install the latest Julia version from <https://julialang.org>. Alternatively use your OS package manager such as brew, apt, winget.

The suggested editor is Visual Studio Code (<https://code.visualstudio.com/>) with the Julia extension but feel free to use any editor you are comfortable with.

## Example model: Cantilever beam

The model we  will be using is of simple cantilever beam subject to a tip load. The parameters and random variables are as follows:

- `l = 1.8` (length)
- `b = 0.12` (width)
- `h = Normal(0.24, 0.01)` (height)
- `E = LogNormal(23.0, 0.16)` (Young's modulus)
- `P = LogNormal(8.5, 0.08)` (tip load)
- `ρ = LogNormal(6.37, 0.23)` (density)

The displacement of the beam can be calculated as

$w = \frac{pgbhl^4}{8EI} + \frac{Pl^3}{3EI}$

with the moment of inertia `I`

$I = \frac{bh^3}{12}$.

## Task 1: Sampling random variables

For our random variables we will make use of the `Distributions` (<https://github.com/JuliaStats/Distributions.jl>) package which is already included as a dependency in this package. `Distributions` ist reexported from our package which is why no extra `using Distributions` is needed to make the methods available.

### Task 1.1

Implement and export a function

```julia
function  sample(rvs::Vector{T} where {T<:UnivariateDistribution}, n::Int)
...
end
```

which will sample from each of the `m` random variables given in the vector `rvs` and return an `mxn` matrix of samples. Use the function `rand(d,n)` to sample from a distribution.

### Task 1.2

Test your method by updating the script `demo/task-1.jl`. First create two normal random variables using `Normal(μ, σ)`. Then draw 100 samples from these distributions using your method implemented in Task 1.1.

Use the `Plots` package (<https://docs.juliaplots.org/stable/>) to create histograms for the samples of your random variables.

## Task 2: The model

In our case the model will be a simple wrapper around a native Julia function.

### Task 2.1

Define and export a `struct` `Model` which has as a single property a `Function`. Then implement a function

```julia
function evaluate(m::Model, x::Matrix)
...
end
```

which evaluates the given function for the samples passed in the matrix `x`.

### Task 2.2

Test your method by updating the script `demo/task-2.jl`. First create the necessary parameters and random variables for the cantilever beam example given above. Then define a function `displacement` and wrap it inside a model. Finally create some samples from your random variables and evaluate the model for the resulting matrix. To inspect the results create a histogram of the displacements.

## Task 3: Probability of failure

Now we will compute the probability of failure for the cantilever beam exceeding a maximum displacement of `0.01m` using standard Monte Carlo simulation

### Task 3.1

Implement and export a function

```julia
function probability_of_failure(rvs::Vector{T} where {T<:UnivariateDistribution}, m::Model, performance::Function, n::Int)
...
end
```

which will return the probability of failure, the random samples and the coefficient of variation.

Recall that the probability of failure can be estimated as

$\hat{pf} \approx \sum_1^N \frac{n_f}{N}$

where $n_f$ is the number of failures (performance < 0) in our simulation. The coefficient of variation is then computed as

$cov = \frac{\sqrt{\hat{pf} - \hat{pf}^2}/N}{\hat{pf}}$

### Task 3.2

Test your method by updating the script `demo/task-3.jl`. Define the necessary parameters and random variables as well as the `displacement` function and model like in Task 2. Afterwards use your new method to compute the failure probability for a maximum displacement of `0.01`. With a sufficient number of samples, the `pf` should converge to `0.072`.
