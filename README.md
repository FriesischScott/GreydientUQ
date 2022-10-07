# Uncertainty Quantification with Julia

In this workshop we will build a small package capable of computing the probability of failure for simple models written in Julia and arbitrary numbers of random variables using standard Monte Carlo simulation.

## Prerequisites

Install the latest Julia version from <https://julialang.org>. Alternatively use your OS package manager such as brew, apt, winget.

The suggested editor is Visual Studio Code (<https://code.visualstudio.com/>) with the Julia extension but feel free to use any editor you are comfortable with.

## Dependencies

To install the dependencies in your project environment run

```julia
] activate . #activates the project environment
] instantiate
```

In the Julia REPL `]` is used to switch to `Pkg`. Visual Studio Code can automatically activate the project environment when starting the REPL.

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

which will sample from each of the `m` random variables given in the vector `rvs` and return an `nxm` matrix of samples. Use the function `rand(d,n)` to sample from a distribution.

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

## Task 4: Quasi-Monte Carlo

In this task we will make use of Julia's multiple dispatch to allow for the easy extension of our probability of failure method to multiple Quasi-Monte Carlo sampling methods.

### Task 4.1

To begin, add the package `QuasiMonteCarlo` (<https://github.com/SciML/QuasiMonteCarlo.jl>) as a dependency to the module and add the corresponding `using` statement in `src/GreydientUQ.jl`.

Next, we define an `abstract` super type for all our simulations as
```julia
abstract type AbstractMonteCarlo end
```

Then, define a `struct` `MonteCarlo` that inherits from `AbstractMonteCarlo` using `<:` and has the number of samples to use `n` as an `Integer` property. Additionally, define another `struct` of the same form for `SobolSampling`.

### Task 4.2

Update the `sample` method defined in Task 1.1 to accept an object of type `MonteCarlo` instead of the number of samples. Then update the `probability_of_failure` method to accept any object of the `abstract` type `AbstractMonteCarlo`. Update your scripts accordingly.

### Task 4.3

Finally, implement a second `sample` method for `SobolSampling`.

```julia
function  sample(rvs::Vector{T} where {T<:UnivariateDistribution}, sim::SobolSampling)
...
end
```

In this method you must first use the method provided by `QuasiMonteCarlo` to obtain samples of the Sobol' sequence in $[0,1]$-space. These are then transformed to the marginal distributions using the inverse transformation method. **Hint**: The inverse cdf in `Distributions` is called `quantile`.

In this way, any simulation technique from `QuasiMonteCarlo` can be included by simply defining a new `struct` inheriting from `AbstractMonteCarlo` and adding the appropriate `sample` method.

### Task 4.4

Update the script `demo/task-4.jl` to compute the probability of failure with standard Monte Carlo simulation and Sobol sampling, then compare your solutions.



