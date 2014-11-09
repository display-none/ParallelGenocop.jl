
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


function get_random_float{T <: FloatingPoint}(start::T, stop::T)
    start in [-Inf, Inf] && stop in [-Inf, Inf] && @error "infinities"      #todo: use realmin and realmax
    if start == stop
        return start
    end
    return rand(Uniform(start, stop))
end

function same(first::Individual, second::Individual)
    return first.fitness != second.fitness && first.chromosome != second.chromosome
end

function evaluate_row{T <: FloatingPoint}(matrix::Matrix{T}, vector::AbstractVector{T}, row_number)
#    matrix_row = sub(matrix, row_number, :)
#    products = T[vector[i] * matrix_row[i] for i = 1:length(vector)]
#    return sum_kbn(products)
    matrix_row = vec(matrix[row_number, :])
    return dot(matrix_row, vector)
end

function evaluate_row_skip_position{T <: FloatingPoint}(matrix::Matrix{T}, vector::AbstractVector{T}, row_number, position)
#    matrix_row = sub(matrix, row_number, :)
#    matrix_row = matrix[row_number, :]
#    products = T[vector[i] * matrix_row[i] for i = 1:length(vector)]
#    products[position] = 0.0
#    return sum_kbn(products)
    return evaluate_row(matrix, vector, row_number) - matrix[row_number, position]*vector[position]
end


function is_feasible{T <: FloatingPoint}(chromosome::AbstractVector{T}, spec::InternalSpec{T})
    ineq = spec.inequalities
    ineq_lower = spec.inequalities_lower
    ineq_upper = spec.inequalities_upper
    for i in 1:size(ineq, 1)
        value = evaluate_row(ineq, chromosome, i)

        if value > ineq_upper[i] || value < ineq_lower[i]
            return false
        end
    end
    return true
end

function is_within_bounds{T <: FloatingPoint}(chromosome::AbstractVector{T}, spec::InternalSpec{T})
    upper = spec.upper_bounds
    lower = spec.lower_bounds
    for i in 1:length(chromosome)
        value = chromosome[i]
        if value < lower[i] || value > upper[i]
            return false
        end
    end
    return true
end


function sort_population!{T <: FloatingPoint}(population::Vector{Individual{T}}, minmax::MinMaxType)
    @debug "sorting population"
    reverse = (minmax == maximization ? true : false)
    sort!(population, alg=QuickSort, by=(ind -> ind.fitness), rev=reverse)
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

