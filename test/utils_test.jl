
begin #verifydimensions should throw error when matrix dimensions do not match vector dimensions
    matrix = [2.0 1.0 0.0 -3.5]
    vector = [1.0, 3.2]
    @test_throws ArgumentError ParallelGenocop.verifydimensions(matrix, vector)
end

begin #verifydimensions should do nothing when matrix dimensions match vector dimensions
    matrix = [2.0 1.0 0.0 -3.5
              2.4 3.4 0.3 -1.2]
    vector = [1.0, 4.3]
    ParallelGenocop.verifydimensions(matrix, vector)
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
