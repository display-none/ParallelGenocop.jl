
custom_suite("optimization tests")

function get_individual_with_fitness(fitness)
    ind = Individual([.1, .2])
    ind.fitness = fitness
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
