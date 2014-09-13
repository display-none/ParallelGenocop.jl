
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

function evaluate_row{T <: FloatingPoint}(matrix::Matrix{T}, vector::Vector{T}, row_number)
    matrix_row = sub(matrix, row_number, :)
    products = T[vector[i] * matrix_row[i] for i = 1:length(vector)]
    return sum_kbn(products)
end

function evaluate_row_skip_position{T <: FloatingPoint}(matrix::Matrix{T}, vector::Vector{T}, row_number, position)
    matrix_row = sub(matrix, row_number, :)
    products = T[vector[i] * matrix_row[i] for i = 1:length(vector)]
    products[position] = 0.0
    return sum_kbn(products)
end

function sort_population!{T <: FloatingPoint}(population::Vector{Individual{T}}, minmax::MinMaxType)
    @debug "sorting population"
    reverse = (minmax == maximization ? true : false)
    sort!(population, alg=QuickSort, by=(ind -> ind.fitness), rev=reverse)
end
