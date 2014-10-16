
custom_suite("optimization tests")


custom_test("find_best_individual should return individual with greater fitness when maximization problem") do
    #given
    ind1 = get_individual_with_fitness(2.0)
    ind2 = get_individual_with_fitness(3.0)

    #when
    best = ParallelGenocop.find_best_individual(ind1, ind2, maximization, 0)

    #then
    @test best == ind2
end

custom_test("find_best_individual should return individual with greater fitness when maximization problem") do
    #given
    ind1 = get_individual_with_fitness(5.0)
    ind2 = get_individual_with_fitness(3.0)

    #when
    best = ParallelGenocop.find_best_individual(ind1, ind2, maximization, 0)

    #then
    @test best == ind1
end


custom_test("find_best_individual should return individual with greater fitness when minimization problem") do
    #given
    ind1 = get_individual_with_fitness(2.0)
    ind2 = get_individual_with_fitness(3.0)

    #when
    best = ParallelGenocop.find_best_individual(ind1, ind2, minimization, 0)

    #then
    @test best == ind1
end

custom_test("find_best_individual should return individual with greater fitness when minimization problem") do
    #given
    ind1 = get_individual_with_fitness(5.0)
    ind2 = get_individual_with_fitness(3.0)

    #when
    best = ParallelGenocop.find_best_individual(ind1, ind2, minimization, 0)

    #then
    @test best == ind2
end
