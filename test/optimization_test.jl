
custom_suite("optimization tests")

function get_individual_with_fitness(fitness)
    ind = Individual([.1, .2])
    ind.fitness = fitness
    return ind
end

function get_dead_individual()
    ind = Individual([.1, .2])
    ind.dead = true
    return ind
end

custom_test("assign_probabilities should assign probabilities to all individuals") do
    ind1 = get_individual_with_fitness(2.0)
    ind2 = get_individual_with_fitness(3.0)
    ind3 = get_individual_with_fitness(5.0)
    population = [ind1, ind2, ind3]

    probabilities = ParallelGenocop.compute_probabilities!(population)

    @test_approx_eq 0.2 probabilities[1]
    @test_approx_eq 0.3 probabilities[2]
    @test_approx_eq 0.5 probabilities[3]
end




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


custom_test("kill_somebody should kill the second individual when the first has 1 probability") do
    #given
    ind1 = get_individual_with_fitness(5.0)
    ind2 = get_individual_with_fitness(0.0)
    cum_prob = [1.0, 1.0]

    generation = ParallelGenocop.Generation([ind1, ind2], Integer[4])
    generation.cumulative_probabilities = cum_prob

    #when
    ParallelGenocop.kill_somebody(generation)

    #then
    @test ind2.dead == true
end


custom_test("kill_somebody should kill only the individuals that are not dead") do
    #given
    ind1 = get_dead_individual()
    ind2 = get_dead_individual()
    ind3 = get_individual_with_fitness(2.0)
    cum_prob = [0.3, 0.99, 1.0]

    generation = ParallelGenocop.Generation([ind1, ind2, ind3], Integer[4])
    generation.cumulative_probabilities = cum_prob

    #when
    ParallelGenocop.kill_somebody(generation)

    #then
    @test ind3.dead == true
end


custom_test("kill_somebody should throw ErrorException when everybody in a population is already dead") do
    #given
    ind1 = get_dead_individual()
    ind2 = get_dead_individual()
    ind3 = get_dead_individual()
    cum_prob = [0.3, 0.99, 1.0]

    generation = ParallelGenocop.Generation([ind1, ind2, ind3], Integer[4])
    generation.cumulative_probabilities = cum_prob

    #when & then
    @test_throws ErrorException ParallelGenocop.kill_somebody(generation)
end
