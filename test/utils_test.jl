
begin #verifydimensionsrows should throw error when no of rows in a matrix does not match vector length
    matrix = [2.0 1.0 0.0 -3.5]
    vector = [1.0, 3.2]
    @test_throws ArgumentError ParallelGenocop.verifydimensionsrows(matrix, vector)
end

begin #verifydimensionsrows should do nothing when no of rows matches vector length
    matrix = [2.0 1.0 0.0 -3.5
              2.4 3.4 0.3 -1.2]
    vector = [1.0, 4.3]
    ParallelGenocop.verifydimensionsrows(matrix, vector)
end

begin #verifydimensionscolumns should throw error when no of columns in a matrix does not match vector length
    matrix = [2.0 1.0 0.0 -3.5]
    vector = [1.0, 3.2]
    @test_throws ArgumentError ParallelGenocop.verifydimensionscolumns(matrix, vector)
end

begin #verifydimensionscolumns should do nothing when no of columns matches vector length
    matrix = [2.0 1.0 0.0 -3.5
              2.4 3.4 0.3 -1.2]
    vector = [1.0, 4.3, 2.6, -4.3]
    ParallelGenocop.verifydimensionscolumns(matrix, vector)
end

begin #verifysamesize should throw error when vectors sizes do not match
    vector1 = [2, 5, 4]
    vector2 = [3, 6]
    @test_throws ArgumentError ParallelGenocop.verifysamesize(vector1, vector2)
end

begin #verifysamesize should do nothing when vectors sizes match
    vector1 = [2, 5, 4]
    vector2 = [3, 6, 8]
    ParallelGenocop.verifysamesize(vector1, vector2)
end
