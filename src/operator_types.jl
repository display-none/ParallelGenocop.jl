

# Operator type as a base class for operators

abstract Operator



# Uniform Mutation

immutable type UniformMutation <: Operator
    arity::Integer
    UniformMutation() = new(1)
end


# Boundary Mutation

immutable type BoundaryMutation <: Operator
    arity::Integer
    BoundaryMutation() = new(1)
end


# Non-Uniform Mutation
const _default_non_uniform_mutation_parameter = 6

immutable type NonUniformMutation <: Operator
    arity::Integer
    degree_of_non_uniformity::Integer
    NonUniformMutation() = new(1, _default_non_uniform_mutation_parameter)
    NonUniformMutation(degree) = new(1, degree)
end


# Arithmetical Crossover

immutable type ArithmeticalCrossover <: Operator
    arity::Integer
    ArithmeticalCrossover() = new(2)
end


# Simple Crossover

const _default_simple_crossover_step = 10

immutable type SimpleCrossover <: Operator
    arity::Integer
    step::Integer
    SimpleCrossover() = new(2, _default_simple_crossover_step)
    SimpleCrossover(step) = new(2, step)
end
