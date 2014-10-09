
custom_suite("utils test")


function get_individual_with_fitness(fitness)
    ind = Individual([.1, .2])
    ind.fitness = fitness
    return ind
end


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

custom_test("sort_population! should sort supplied array") do
    ind1 = get_individual_with_fitness(.9)
    ind2 = get_individual_with_fitness(.2)
    ind3 = get_individual_with_fitness(.7)
    population = [ind1, ind2, ind3]

    ParallelGenocop.sort_population!(population, minimization)

    @test population == [ind2, ind3, ind1]
end



custom_test("is_feasible should return false if any row is infeasible") do
    infeasible_inequalities_right = Float64[-Inf, -Inf]
    spec = get_sample_spec(inequalities_upper = infeasible_inequalities_right)


    @test false == ParallelGenocop.is_feasible(Float64[1.3, 2.3, 1.2, 3.3], spec)
end


custom_test("is_feasible should return false if first row is feasible, but second is infeasible") do
    mixed_inequalities_right = Float64[Inf, -Inf]
    spec = get_sample_spec(inequalities_upper = mixed_inequalities_right)


    @test false == ParallelGenocop.is_feasible(Float64[1.3, 2.3, 1.2, 3.3], spec)
end


custom_test("is_feasible should return true when all rows are feasible") do
    mixed_inequalities_right = Float64[Inf, Inf]
    spec = get_sample_spec(inequalities_upper = mixed_inequalities_right)


    @test true == ParallelGenocop.is_feasible(Float64[1.3, 2.3, 1.2, 3.3], spec)
end



custom_test("is_within_bounds should return false when at least one position is out of lower bounds") do
    spec = get_sample_spec(upper_bounds=Float64[4.0, 4.0, 4.0, 4.0], lower_bounds=Float64[0.0, 0.0, 0.0, 0.0])


    @test false == ParallelGenocop.is_within_bounds(Float64[1.3, -0.3, 1.2, 3.3], spec)
end

custom_test("is_within_bounds should return false when at least one position is out of upper bounds") do
    spec = get_sample_spec(upper_bounds=Float64[4.0, 4.0, 4.0, 4.0], lower_bounds=Float64[0.0, 0.0, 0.0, 0.0])


    @test false == ParallelGenocop.is_within_bounds(Float64[1.3, 2.3, 4.2, 3.3], spec)
end

custom_test("is_within_bounds should return true when chromosome is within bounds") do
    spec = get_sample_spec(upper_bounds=Float64[4.0, 4.0, 4.0, 4.0], lower_bounds=Float64[0.0, 0.0, 0.0, 0.0])


    @test true == ParallelGenocop.is_within_bounds(Float64[1.3, 2.3, 1.2, 3.3], spec)
end

