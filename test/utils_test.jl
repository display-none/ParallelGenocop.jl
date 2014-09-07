

custom_suite("utils test")


custom_test("verify_dimensions_rows should throw error when no of rows in a matrix does not match vector length") do
    matrix = [2.0 1.0 0.0 -3.5]
    vector = [1.0, 3.2]
    @test_throws ArgumentError ParallelGenocop.verify_dimensions_rows(matrix, vector)
end

custom_test("verify_dimensions_rows should do nothing when no of rows matches vector length") do
    matrix = [2.0 1.0 0.0 -3.5
              2.4 3.4 0.3 -1.2]
    vector = [1.0, 4.3]
    ParallelGenocop.verify_dimensions_rows(matrix, vector)
end

custom_test("verify_dimensions_columns should throw error when no of columns in a matrix does not match vector length") do
    matrix = [2.0 1.0 0.0 -3.5]
    vector = [1.0, 3.2]
    @test_throws ArgumentError ParallelGenocop.verify_dimensions_columns(matrix, vector)
end

custom_test("verify_dimensions_columns should do nothing when no of columns matches vector length") do
    matrix = [2.0 1.0 0.0 -3.5
              2.4 3.4 0.3 -1.2]
    vector = [1.0, 4.3, 2.6, -4.3]
    ParallelGenocop.verify_dimensions_columns(matrix, vector)
end

custom_test("verify_same_size should throw error when vectors sizes do not match") do
    vector1 = [2, 5, 4]
    vector2 = [3, 6]
    @test_throws ArgumentError ParallelGenocop.verify_same_size(vector1, vector2)
end

custom_test("verify_same_size should do nothing when vectors sizes match") do
    vector1 = [2, 5, 4]
    vector2 = [3, 6, 8]
    ParallelGenocop.verify_same_size(vector1, vector2)
end
