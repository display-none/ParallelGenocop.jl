
custom_suite("initialization tests")

get_chromosome = ParallelGenocop.get_chromosome

custom_test("get_random_chromosome_within_bounds should return a chromosome within bounds") do
    #given
    lower_bounds = Float64[1.0, 0.0, -2.1, 0.0]
    upper_bounds = Float64[8.0, 8.0, 3.1, 4.4]
    spec = get_sample_spec(lower_bounds = lower_bounds, upper_bounds = upper_bounds)

    #when
    chromosome = ParallelGenocop.get_random_chromosome_within_bounds(spec)

    #then
    for i=1:4
        @test lower_bounds[i] <= chromosome[i] <= upper_bounds[i]
    end
end


custom_test("get_feasible_chromosome should return a chromosome") do
    #given
    spec = get_spec_with_all_individuals_feasible()

    #when
    chromosome = ParallelGenocop.get_feasible_chromosome(spec)

    #then
    @test chromosome != nothing
end



custom_test("get_feasible_chromosome should return nothing if feasible chromosome is not found") do
    #given
    spec = get_spec_with_all_individuals_infeasible()

    #when
    chromosome = ParallelGenocop.get_feasible_chromosome(spec)

    #then
    @test chromosome == nothing
end



custom_test("initialize_population_multipoint should return population that consists of different individuals") do
    #given
    spec = get_spec_with_all_individuals_feasible()

    #when
    population = ParallelGenocop.initialize_population_multipoint(spec)

    #then
    @test get_chromosome(population[1]) != get_chromosome(population[2])
end


custom_test("initialize_population_multipoint should return population with correct length") do
    #given
    spec = get_spec_with_all_individuals_feasible()

    #when
    population = ParallelGenocop.initialize_population_multipoint(spec)

    #then
    @test length(population) == spec.population_size
end


custom_test("initialize_population_multipoint should throw ErrorException when feasible individual was not found") do
    #given
    spec = get_spec_with_all_individuals_infeasible()

    #when & then
    @test_throws ErrorException ParallelGenocop.initialize_population_multipoint(spec)
end



custom_test("initialize_population_single_point should return different individuals with the same chromosome") do
    #given
    spec = get_spec_with_all_individuals_feasible()

    #when
    population = ParallelGenocop.initialize_population_single_point(spec)

    #then
    @test get_chromosome(population[1]) == get_chromosome(population[2])
    @test population[1].column != population[2].column
end


custom_test("initialize_population_single_point should return population with correct length") do
    #given
    spec = get_spec_with_all_individuals_feasible()

    #when
    population = ParallelGenocop.initialize_population_single_point(spec)

    #then
    @test length(population) == spec.population_size
end


custom_test("initialize_population_single_point should throw ErrorException when feasible individual was not found") do
    #given
    spec = get_spec_with_all_individuals_infeasible()

    #when & then
    @test_throws ErrorException ParallelGenocop.initialize_population_single_point(spec)
end



custom_test("initialize_population should return single point population if single point population set in spec") do
    #given
    spec = get_spec_with_all_individuals_feasible(single_point_start_pop)

    #when
    population = ParallelGenocop.initialize_population(spec)

    #then
    @test get_chromosome(population[1]) == get_chromosome(population[2])
end


custom_test("initialize_population should return multi point population if multi point population set in spec") do
    #given
    spec = get_spec_with_all_individuals_feasible(multi_point_start_pop)

    #when
    population = ParallelGenocop.initialize_population(spec)

    #then
    @test get_chromosome(population[1]) != get_chromosome(population[2])
end
