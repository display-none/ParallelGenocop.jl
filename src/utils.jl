
# utilities

function verifydimensions(matrix::Matrix, vector::Vector)
    h_matrix = size(matrix, 1)
    h_vector = size(vector, 1)
    if h_matrix != h_vector
       throw(ArgumentError("dimensions of matrix and vector do not match"))
    end
end

function verifysamesize(vector1::Vector, vector2::Vector)
    if size(vector1, 1) != size(vector2, 1)
       throw(ArgumentError("vector sizes do not match"))
    end
end
