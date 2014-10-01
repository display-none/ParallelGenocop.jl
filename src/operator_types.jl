

# Operator type as a base class for operators

abstract Operator


# Operators divided by selection strategy
abstract UniformSelectionUnaryOperator <: Operator
abstract FitnessBasedSelectionBinaryOperator <: Operator



# Uniform Mutation

immutable type UniformMutation <: UniformSelectionUnaryOperator
    arity::Integer
    UniformMutation() = new(1)
end


# Boundary Mutation

immutable type BoundaryMutation <: UniformSelectionUnaryOperator
    arity::Integer
    BoundaryMutation() = new(1)
end


# Non-Uniform Mutation
const _default_non_uniform_mutation_parameter = 6

immutable type NonUniformMutation <: UniformSelectionUnaryOperator
    arity::Integer
    degree_of_non_uniformity::Integer
    NonUniformMutation() = new(1, _default_non_uniform_mutation_parameter)
    NonUniformMutation(degree) = new(1, degree)
end


# Whole Non-Uniform Mutation

immutable type WholeNonUniformMutation <: UniformSelectionUnaryOperator
    arity::Integer
    degree_of_non_uniformity::Integer
    WholeNonUniformMutation() = new(1, _default_non_uniform_mutation_parameter)
    WholeNonUniformMutation(degree) = new(1, degree)
end


# Arithmetical Crossover

immutable type ArithmeticalCrossover <: FitnessBasedSelectionBinaryOperator
    arity::Integer
    ArithmeticalCrossover() = new(2)
end


# Simple Crossover

const _default_simple_crossover_step = 10

immutable type SimpleCrossover <: FitnessBasedSelectionBinaryOperator
    arity::Integer
    step::Integer
    SimpleCrossover() = new(2, _default_simple_crossover_step)
    SimpleCrossover(step) = new(2, step)
end


# Heuristic Crossover
const _default_heuristic_crossover_tries = 10

immutable type HeuristicCrossover <: Operator
    arity::Integer
    tries::Integer
    HeuristicCrossover() = new(2, _default_heuristic_crossover_tries)
    HeuristicCrossover(tries) = new(2, tries)
end

