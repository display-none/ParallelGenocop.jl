
# GenocopSpec for specification of the problem and parameters

immutable type GenocopSpec{T <: FloatingPoint}
    equalities::Matrix{T}
    equalities_right::Vector{T}
    inequalities::Matrix{T}
    inequalities_lower::Vector{T}
    inequalities_upper::Vector{T}
    lower_bounds::Vector{T}
    upper_bounds::Vector{T}
    population_size::Integer
    max_iterations::Integer
    operators::Vector{Operator}
    operator_frequency::Vector{Integer}
    cumulative_prob_coeff::FloatingPoint
    minmax::MinMaxType
    starting_population_type::StartPopType

    no_of_variables::Int

    function GenocopSpec{T}(equalities::Matrix{T},
        equalities_right::Vector{T},
        inequalities::Matrix{T},
        inequalities_lower::Vector{T},
        inequalities_upper::Vector{T},
        lower_bounds::Vector{T},
        upper_bounds::Vector{T},
        population_size::Integer,
        max_iterations::Integer,
        operator_mapping::Dict{Operator, Integer},
        cumulative_prob_coeff::FloatingPoint,
        minmax::MinMaxType,
        starting_population_type::StartPopType)

        operators = collect(keys(operator_mapping))
        operator_frequency = Integer[operator_mapping[operator] / operator.arity for operator in operators]

        verify_dimensions_rows(equalities, equalities_right, "dimensions of equalities and its right hand side do not match")
        verify_dimensions_rows(inequalities, inequalities_lower, "dimensions of inequalities and its lower limits do not match")
        verify_dimensions_rows(inequalities, inequalities_upper, "dimensions of inequalities and its upper limits do not match")
        verify_dimensions_columns(equalities, lower_bounds, "dimensions of equalities and lower bounds do not match")
        verify_dimensions_columns(inequalities, upper_bounds, "dimensions of inequalities and upper bounds do not match")
        verify_same_size(lower_bounds, upper_bounds)
        @assert population_size > 0 "population size must be a positive integer"
        @assert max_iterations > 0 "max iterations must be a positive integer"
        @assert sum(operator_frequency) > 0 "there must be at least one operator with at least one application"
        @assert sum(operator_frequency) <= population_size "sum of all operator applications cannot exceed population size"

        if sum(operator_frequency) > population_size/2
            @warn "sum of all parents needed for reproduction should not exceed half of population size"
        end

        no_of_variables = length(lower_bounds)

        new(equalities, equalities_right, inequalities, inequalities_lower, inequalities_upper, lower_bounds,
                upper_bounds, population_size, max_iterations, operators, operator_frequency,
                cumulative_prob_coeff, minmax, starting_population_type, no_of_variables)
    end
end


function GenocopSpec{T <: FloatingPoint}(
        equalities::Matrix{T},
        equalities_right::Vector{T},
        inequalities::Matrix{T},
        inequalities_right::Vector{T},
        lower_bounds::Vector{T},
        upper_bounds::Vector{T};
        population_size::Integer=_default_population_size,
        max_iterations::Integer=_default_max_iter,
        operator_mapping::Dict{Operator, Integer}=_default_operator_mapping,
        cumulative_prob_coeff::FloatingPoint=_default_cumulative_prob_coeff,
        minmax::MinMaxType=_default_minmax_type,
        starting_population_type::StartPopType=_default_starting_population)

        inequalities_lower = T[-Inf for i in 1:length(inequalities_right)]

        GenocopSpec{T}(equalities, equalities_right, inequalities, inequalities_lower, inequalities_right, lower_bounds,
                            upper_bounds, population_size, max_iterations, operator_mapping,
                            cumulative_prob_coeff, minmax, starting_population_type)
end



# Individual type to store an individual

type Individual{T <: FloatingPoint}
    chromosome::Vector{T}
    fitness::Union(T, Nothing)
    dead::Bool

    function Individual(chromosome::Vector{T})
        new(chromosome, nothing, false)
    end

    function Individual(individual::Individual{T})
        new(individual.chromosome, individual.fitness, individual.dead)
    end
end

Individual{T <: FloatingPoint}(chromosome::Vector{T}) = Individual{T}(chromosome)

function copy(individual::Individual)
    ind = Individual(individual.chromosome)
    ind.fitness = individual.fitness
    ind.dead = individual.dead
    return ind
end


# Generation type to represent a generation

type Generation{T <: FloatingPoint}
    number::Integer
    population::Vector{Individual{T}}
    cumulative_probabilities::Vector{Float64}
    operator_applications_left::Vector{Integer}

    function Generation(number::Integer, population::Vector{Individual{T}}, operator_applications_left::Vector{Integer})
        gen = new()
        gen.number = number
        gen.population = population
        gen.operator_applications_left = operator_applications_left
        return gen
    end
end

Generation{T <: FloatingPoint}(number::Integer, population::Vector{Individual{T}}, operator_applications_left::Vector{Integer}) = Generation{T}(number, population, operator_applications_left)


