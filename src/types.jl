
# GenocopSpecification for specification of the problem and parameters

immutable type GenocopSpecification{T <: FloatingPoint}
    evaluation_function::Function
    equalities::Matrix{T}
    equalities_right::Vector{T}
    inequalities::Matrix{T}
    inequalities_lower::Vector{T}
    inequalities_upper::Vector{T}
    lower_bounds::Vector{T}
    upper_bounds::Vector{T}
    population_size::Integer
    max_iterations::Integer
    operator_mapping::Dict{Operator, Integer}
    cumulative_prob_coeff::FloatingPoint
    minmax::MinMaxType
    starting_population_type::StartPopType
    starting_point::Union(Vector{T}, Nothing)

    function GenocopSpecification{T}(
        evaluation_function::Function,
        equalities::Matrix{T},
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
        starting_population_type::StartPopType,
        starting_point::Union(Vector{T}, Nothing))

        operators = collect(keys(operator_mapping))
        operator_frequency = Integer[div(operator_mapping[operator], operator.arity) for operator in operators]

        verify_dimensions_rows(equalities, equalities_right, "dimensions of equalities and its right hand side do not match")
        verify_dimensions_rows(inequalities, inequalities_lower, "dimensions of inequalities and its lower limits do not match")
        verify_dimensions_rows(inequalities, inequalities_upper, "dimensions of inequalities and its upper limits do not match")
        verify_same_size(lower_bounds, upper_bounds)
        if has_rows(equalities)
            verify_dimensions_columns(equalities, lower_bounds, "dimensions of equalities and lower bounds do not match")
        end
        if has_rows(inequalities)
            verify_dimensions_columns(inequalities, upper_bounds, "dimensions of inequalities and upper bounds do not match")
        end
        @assert population_size > 0 "population size must be a positive integer"
        @assert max_iterations > 0 "max iterations must be a positive integer"
        @assert sum(operator_frequency) > 0 "there must be at least one operator with at least one application"
        @assert sum(operator_frequency) <= population_size "sum of all operator applications cannot exceed population size"

        if sum(operator_frequency) > population_size/2
            @warn "sum of all parents needed for reproduction should not exceed half of population size"
        end

        new(evaluation_function, equalities, equalities_right, inequalities, inequalities_lower, inequalities_upper, lower_bounds,
                upper_bounds, population_size, max_iterations, operator_mapping,
                cumulative_prob_coeff, minmax, starting_population_type, starting_point)
    end
end

function GenocopSpecification{T <: FloatingPoint}(
        evaluation_function::Function,
        equalities::Matrix{T},
        equalities_right::Vector{T},
        inequalities::Matrix{T},
        inequalities_lower::Vector{T},
        inequalities_upper::Vector{T},
        lower_bounds::Vector{T},
        upper_bounds::Vector{T};
        population_size::Integer=_default_population_size,
        max_iterations::Integer=_default_max_iter,
        operator_mapping::Dict{Operator, Integer}=_default_operator_mapping,
        cumulative_prob_coeff::FloatingPoint=_default_cumulative_prob_coeff,
        minmax::MinMaxType=_default_minmax_type,
        starting_population_type::StartPopType=_default_starting_population,
        starting_point::Union(Vector{T}, Nothing)=nothing)

        GenocopSpecification{T}(evaluation_function, equalities, equalities_right, inequalities, inequalities_lower, inequalities_upper, lower_bounds,
                            upper_bounds, population_size, max_iterations, operator_mapping,
                            cumulative_prob_coeff, minmax, starting_population_type, starting_point)
end

function GenocopSpecification{T <: FloatingPoint}(
        evaluation_function::Function,
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
        starting_population_type::StartPopType=_default_starting_population,
        starting_point::Union(Vector{T}, Nothing)=nothing)

        inequalities_lower = T[-Inf for i in 1:length(inequalities_right)]

        GenocopSpecification{T}(evaluation_function, equalities, equalities_right, inequalities, inequalities_lower, inequalities_right, lower_bounds,
                            upper_bounds, population_size, max_iterations, operator_mapping,
                            cumulative_prob_coeff, minmax, starting_population_type, starting_point)
end


function GenocopSpecification{T <: FloatingPoint}(
        evaluation_function::Function,
        lower_bounds::Vector{T},
        upper_bounds::Vector{T};
        population_size::Integer=_default_population_size,
        max_iterations::Integer=_default_max_iter,
        operator_mapping::Dict{Operator, Integer}=_default_operator_mapping,
        cumulative_prob_coeff::FloatingPoint=_default_cumulative_prob_coeff,
        minmax::MinMaxType=_default_minmax_type,
        starting_population_type::StartPopType=_default_starting_population,
        starting_point::Union(Vector{T}, Nothing)=nothing)

        equalities = Array(T, 0, 0)
        equalities_right = Array(T, 0)
        inequalities = Array(T, 0, 0)
        inequalities_lower = Array(T, 0)
        inequalities_right = Array(T, 0)

        GenocopSpecification{T}(evaluation_function, equalities, equalities_right, inequalities, inequalities_lower, inequalities_right, lower_bounds,
                            upper_bounds, population_size, max_iterations, operator_mapping,
                            cumulative_prob_coeff, minmax, starting_population_type, starting_point)
end


# internal specification holding processed information

immutable type InternalSpec{T <: FloatingPoint}
    evaluation_function::Function
    removed_variables_indices::Vector{Int}
    inequalities::Matrix{T}
    inequalities_lower::Vector{T}
    inequalities_upper::Vector{T}
    lower_bounds::Vector{T}
    upper_bounds::Vector{T}
    population_size::Integer
    max_iterations::Integer
    operators::Vector{Operator}
    operator_frequency::Vector{Int16}
    cumulative_prob_coeff::Float16
    minmax::MinMaxType
    starting_population_type::StartPopType
    starting_point::Union(Vector{T}, Nothing)

    no_of_variables::Int
    A1inv_b::Vector{T}
    A1inv_A2::Matrix{T}


    ineq::Matrix{T}

    function InternalSpec{T}(
        evaluation_function::Function,
        removed_variables_indices::Vector{Int},
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
        starting_population_type::StartPopType,
        starting_point::Union(Vector{T}, Nothing),
        no_of_variables::Int,
        A1inv_b::Vector{T},
        A1inv_A2::Matrix{T})

        operators = collect(keys(operator_mapping))
        operator_frequency = Integer[div(operator_mapping[operator], operator.arity) for operator in operators]

        ineq = flipud(rotl90(inequalities))

        new(evaluation_function, removed_variables_indices, inequalities, inequalities_lower, inequalities_upper,
            lower_bounds, upper_bounds, population_size, max_iterations, operators, operator_frequency, cumulative_prob_coeff,
            minmax, starting_population_type, starting_point, no_of_variables, A1inv_b, A1inv_A2, ineq)
    end
end


function InternalSpec{T <: FloatingPoint}(evaluation_function::Function,
    removed_variables_indices::Vector{Int},
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
    starting_population_type::StartPopType,
    starting_point::Union(Vector{T}, Nothing),
    no_of_variables::Int,
    A1inv_b::Vector{T},
    A1inv_A2::Matrix{T})

    InternalSpec{T}(evaluation_function, removed_variables_indices, inequalities, inequalities_lower, inequalities_upper,
        lower_bounds, upper_bounds, population_size, max_iterations, operator_mapping, cumulative_prob_coeff,
        minmax, starting_population_type, starting_point, no_of_variables, A1inv_b, A1inv_A2)
end


# Individual type to store an individual

type Individual
    column::Int
    dead::Bool

    function Individual(column::Int)
        new(column, false)
    end

end

function Individual{T <: FloatingPoint}(column::Int, chromosome::AbstractVector{T})
    ind = Individual(column)
    population_data = population_data_holder.population_data
    checkbounds(population_data, length(chromosome), column)
    @inbounds for i=1:length(chromosome)
        population_data[i, column] = chromosome[i]
    end
    ind
end

function Individual{T <: FloatingPoint}(column::Int, chromosome::AbstractVector{T}, fitness::T)
    ind = Individual(column, chromosome)
    set_fitness!(ind, fitness)
    ind
end


getindex(ind::Individual, x) = getindex(population_data_holder.population_data, x, ind.column)
setindex!(ind::Individual, v, x) = setindex!(population_data_holder.population_data, v, x, ind.column)

length(ind::Individual) = size(population_data_holder.population_data, 1)
==(ind1::Individual, ind2::Individual) = (ind1.column == ind2.column)

get_chromosome(ind::Individual) = population_data_holder.population_data[:, ind.column]
get_chromosome(ind::Individual, range) = population_data_holder.population_data[range, ind.column]
set_chromosome!(ind::Individual, chromosome) = (population_data_holder.population_data[:, ind.column] = chromosome)
set_chromosome!(ind::Individual, chromosome, range) = (population_data_holder.population_data[range, ind.column] = chromosome)
get_fitness(ind::Individual) = population_data_holder.fitness_data[ind.column]
set_fitness!(ind::Individual, fitness::FloatingPoint) = population_data_holder.fitness_data[ind.column] = fitness

function copy_into(dest::Individual, src::Individual)
    copy_into(dest, src, 1:size(population_data_holder.population_data, 1))
end

function copy_into(dest::Individual, src::Individual, range::UnitRange{Int})
    if dest == src; return; end
    population_data = population_data_holder.population_data
    checkbounds(population_data, range, dest.column)
    checkbounds(population_data, range, src.column)
    @inbounds for i in range
        population_data[i, dest.column] = population_data[i, src.column]
    end
end

# Generation type to represent a generation

type Generation
    number::Integer
    population::Vector{Individual}
    cumulative_probabilities::Vector{Float64}
    operator_applications_left::Vector{Int16}

    function Generation(number::Integer, population::Vector{Individual}, operator_applications_left::Vector{Int16})
        gen = new()
        gen.number = number
        gen.population = population
        gen.operator_applications_left = operator_applications_left
        return gen
    end
end


