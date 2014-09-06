
# utilities

function verifydimensionsrows(matrix::Matrix, vector::Vector, msg::String="")
    h_matrix = size(matrix, 1)
    h_vector = size(vector, 1)
    if h_matrix != h_vector
        @error(msg)
        throw(ArgumentError("no of rows of matrix and length vector do not match"))
    end
end

function verifydimensionscolumns(matrix::Matrix, vector::Vector, msg::String="")
    w_matrix = size(matrix, 2)
    h_vector = size(vector, 1)
    if w_matrix != h_vector
        @error(msg)
        throw(ArgumentError("no of columns of matrix and length vector do not match"))
    end
end

function verifysamesize(vector1::Vector, vector2::Vector, msg::String="")
    if size(vector1, 1) != size(vector2, 1)
        @error(msg)
        throw(ArgumentError("vector sizes do not match"))
    end
end
