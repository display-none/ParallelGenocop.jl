
# utilities

function verify_dimensions_rows(matrix::Matrix, vector::Vector, msg::String="")
    h_matrix = size(matrix, 1)
    h_vector = size(vector, 1)
    if h_matrix != h_vector
        @error(msg)
        throw(ArgumentError("no of rows of matrix and length vector do not match"))
    end
end

function verify_dimensions_columns(matrix::Matrix, vector::Vector, msg::String="")
    w_matrix = size(matrix, 2)
    h_vector = size(vector, 1)
    if w_matrix != h_vector
        @error(msg)
        throw(ArgumentError("no of columns of matrix and length vector do not match"))
    end
end

function verify_same_size(vector1::Vector, vector2::Vector, msg::String="")
    if size(vector1, 1) != size(vector2, 1)
        @error(msg)
        throw(ArgumentError("vector sizes do not match"))
    end
end

function has_rows(matrix::Matrix)
    return size(matrix, 1) != 0
end

function replace_infinities{T <: FloatingPoint}(start::T, stop::T)
    if start == Inf
        start = _infinity_for_distributions
    elseif start == -Inf
        start = -_infinity_for_distributions
    end
    if stop == Inf
        stop = _infinity_for_distributions
    elseif stop == -Inf
        stop = -_infinity_for_distributions
    end
    return start, stop
end

function get_random_float{T <: FloatingPoint}(start::T, stop::T)
    if stop-start == Inf
        start, stop = replace_infinities(start, stop)
    end

    if start == stop
        return start
    end
    return rand(Uniform(start, stop))
end

function evaluate_row{T <: FloatingPoint}(matrix::Matrix{T}, vector::Vector{T}, row_number)
    (length(vector) == size(matrix, 2) && 1 <= row_number <= size(matrix, 1)) || BoundsError()
    s = 0.0
    @inbounds for i=1:length(vector)
        s += matrix[row_number, i] * vector[i]
    end
    return s
end

function evaluate_row{T <: FloatingPoint}(matrix::Matrix{T}, individual::Individual, row_number)
    population_data = population_data_holder.population_data
    col = individual.column
    (length(individual) == size(matrix, 2) && 1 <= row_number <= size(matrix, 1) && 1 <= col <= size(population_data, 2)) || BoundsError()
    s = 0.0
    @inbounds for i=1:length(individual)
        s = s + matrix[row_number, i] * population_data[i, col]
    end
    return s
end

function evaluate_row_skip_position{T <: FloatingPoint}(matrix::Matrix{T}, individual::Individual, row_number, position)
    return evaluate_row(matrix, individual, row_number) - matrix[row_number, position]*individual[position]
end

function evaluate_row1{T <: FloatingPoint}(matrix::Matrix{T}, chromosome::Vector{T}, row_number)
    (length(chromosome) == size(matrix, 1) && 1 <= row_number <= size(matrix, 2)) || BoundsError()
    s = 0.0
    @inbounds for i=1:length(chromosome)
        s = s + matrix[i, row_number] * chromosome[i]
    end
    return s
end

function evaluate_row_skip_position1{T <: FloatingPoint}(matrix::Matrix{T}, chromosome::Vector{T}, row_number, position)
    chromosome[position] = 0.0
    return evaluate_row1(matrix, chromosome, row_number)
end

function is_feasible_pseudo{T <: FloatingPoint}(individual::Individual, spec::InternalSpec{T})
    chromosome = get_chromosome(individual)
    is_feasible(chromosome, spec)
end

function is_feasible_pseudo{T <: FloatingPoint}(chromosome::Vector{T}, spec::InternalSpec{T})
    ineq = spec.inequalities
    ineq_lower = spec.inequalities_lower
    ineq_upper = spec.inequalities_upper
    dupa = At_mul_B(spec.ineq, chromosome)
    @inbounds for i in 1:size(ineq, 1)
#        value = evaluate_row(ineq, individual, i)
        value = dupa[i]

        tolerance_upper = ineq_upper[i] != 0.0 ? spec.epsilon * abs(ineq_upper[i]) : spec.epsilon
        tolerance_lower = ineq_lower[i] != 0.0 ? spec.epsilon * abs(ineq_lower[i]) : spec.epsilon
        if value > ineq_upper[i] + tolerance_upper || value < ineq_lower[i] - tolerance_lower
            return false
        end
    end
    return true
end

function is_feasible{T <: FloatingPoint}(individual::Individual, spec::InternalSpec{T})
    chromosome = get_chromosome(individual)
    is_feasible(chromosome, spec)
end

function is_feasible{T <: FloatingPoint}(chromosome::Vector{T}, spec::InternalSpec{T})
    ineq = spec.inequalities
    ineq_lower = spec.inequalities_lower
    ineq_upper = spec.inequalities_upper
    dupa = At_mul_B(spec.ineq, chromosome)
    @inbounds for i in 1:size(ineq, 1)
#        value = evaluate_row(ineq, individual, i)
        value = dupa[i]

        if value > ineq_upper[i] || value < ineq_lower[i]
            return false
        end
    end
    return true
end

function is_within_bounds{T <: FloatingPoint}(individual::Individual, spec::InternalSpec{T})
    upper = spec.upper_bounds
    lower = spec.lower_bounds
    (length(upper) == length(individual)) || BoundsError()
    @inbounds for i in 1:length(individual)
        value = individual[i]
        if value < lower[i] || value > upper[i]
            return false
        end
    end
    return true
end


function sort_population!(population::Vector{Individual}, minmax::MinMaxType)
    @debug "sorting population"
    reverse = (minmax == maximization ? true : false)
    sort!(population, alg=QuickSort, by=get_fitness, rev=reverse)
end


function initialize_population_data{T <: FloatingPoint}(spec::InternalSpec{T})
    return SharedArray(T, spec.no_of_variables, spec.population_size), SharedArray(T, spec.population_size)
end







type SpecHolder
    spec::InternalSpec
    SpecHolder() = new()
end

const spec_holder = SpecHolder()

function set_spec(spec::InternalSpec)
    spec_holder.spec = spec
end



type GenerationHolder
    generation::Generation
    GenerationHolder() = new()
end

const generation_holder = GenerationHolder()

function set_generation(generation::Generation)
    generation_holder.generation = generation
end

type PopulationDataHolder
    population_data::SharedArray
    fitness_data::SharedArray
    PopulationDataHolder() = new()
end

const population_data_holder = PopulationDataHolder()

function set_population_data(population_data, fitness_data)
    population_data_holder.population_data = population_data
    population_data_holder.fitness_data = fitness_data
end
