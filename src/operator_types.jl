

# Operator type as a base class for operators

abstract Operator



# Uniform Mutation

immutable type UniformMutation <: Operator
    arity::Integer
    UniformMutation() = new(1)
end


# BoundaryMutation

immutable type BoundaryMutation <: Operator
    arity::Integer
    BoundaryMutation() = new(1)
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
end
