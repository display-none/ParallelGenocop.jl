
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

function get_generation(population, cum_prob)
    gen = ParallelGenocop.Generation(1, population, Integer[4])
    gen.cumulative_probabilities = cum_prob
    return gen
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

    generation = get_generation([ind1, ind2], cum_prob)

    #when
    ParallelGenocop.kill_somebody(generation)

    #then
    @test ind2.dead == true
end


custom_test("kill_somebody should kill only the individuals that are not dead") do
    #given
    ind1 = get_individual_with_fitness(2.0)
    ind2 = get_dead_individual()
    ind3 = get_dead_individual()
    cum_prob = [0.3, 0.99, 1.0]

    generation = get_generation([ind1, ind2, ind3], cum_prob)

    #when
    ParallelGenocop.kill_somebody(generation)

    #then
    @test ind1.dead == true
end


custom_test("kill_somebody should throw ErrorException when everybody in a population is already dead") do
    #given
    ind1 = get_dead_individual()
    ind2 = get_dead_individual()
    ind3 = get_dead_individual()
    cum_prob = [0.3, 0.99, 1.0]

    generation = get_generation([ind1, ind2, ind3], cum_prob)

    #when & then
    @test_throws ErrorException ParallelGenocop.kill_somebody(generation)
end




custom_test("select_parent should select the first individual when it has 1 probability") do
    #given
    ind1 = get_individual_with_fitness(5.0)
    ind2 = get_individual_with_fitness(0.0)
    cum_prob = [1.0, 1.0]

    generation = get_generation([ind1, ind2], cum_prob)

    #when
    selected = ParallelGenocop.select_parent(generation)

    #then
    @test selected == ind1
end


custom_test("select_parent should return only the individuals that are not dead") do
    #given
    ind1 = get_dead_individual()
    ind2 = get_dead_individual()
    ind3 = get_individual_with_fitness(2.0)
    cum_prob = [0.3, 0.99, 1.0]

    generation = get_generation([ind1, ind2, ind3], cum_prob)

    #when
    selected = ParallelGenocop.select_parent(generation)

    #then
    @test selected == ind3
end


custom_test("select_parent should throw ErrorException when everybody in a population is already dead") do
    #given
    ind1 = get_dead_individual()
    ind2 = get_dead_individual()
    ind3 = get_dead_individual()
    cum_prob = [0.3, 0.6, 1.0]

    generation = get_generation([ind1, ind2, ind3], cum_prob)

    #when & then
    @test_throws ErrorException ParallelGenocop.select_parent(generation)
end





custom_test("select_random_individual should skip first individual") do
    #given
    ind1 = get_individual_with_fitness(5.0)
    ind2 = get_individual_with_fitness(6.0)

    population = [ind1, ind2]

    #when
    selected = ParallelGenocop.select_random_individual(population)

    #then
    @test selected == ind2
end


custom_test("select_random_individual should return only the individuals that are not dead") do
    #given
    ind1 = get_dead_individual()
    ind2 = get_dead_individual()
    ind3 = get_individual_with_fitness(2.0)
    ind4 = get_dead_individual()

    population = [ind1, ind2, ind3, ind4]

    #when
    selected = ParallelGenocop.select_random_individual(population)

    #then
    @test selected == ind3
end


custom_test("select_random_individual should throw ErrorException when everybody in a population is already dead") do
    #given
    ind1 = get_dead_individual()
    ind2 = get_dead_individual()
    ind3 = get_dead_individual()

    population = [ind1, ind2, ind3]

    #when & then
    @test_throws ErrorException ParallelGenocop.select_random_individual(population)
end

