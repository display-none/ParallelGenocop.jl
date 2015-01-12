


#proportional
function compute_probabilities_old!(population::Vector{Individual})
    probabilities = Array(Float64, length(population))
    total_fitness = sum(get_fitness, population)
    for i in 1:length(population)
        probabilities[i] = get_fitness(population[i]) / total_fitness
    end
    return probabilities
end

# the probabilities are basically Q, Q*(1-Q), Q*(1-Q)^2, ..., Q*(1-Q)^n
# it's just slightly modified to sum to 1
function compute_probabilities!(population_size::Int, cumulative_prob_coeff)
    probabilities = Array(Float64, population_size)
    Q = cumulative_prob_coeff
    Q1 = Q / (1 - (1 - Q)^population_size)
    @inbounds for i in 1:population_size
        probabilities[i] = Q1 * (1 - Q)^(i-1)
    end
    return probabilities
end


# parent selection for unary operators with uniform selection
function select_parents_and_dead(operator::UniformSelectionUnaryOperator, generation::Generation)
    individual = select_random_individual(generation.population)
    individual.dead = true
    return Individual[individual], Individual[individual]
end

# parent selection for binary operators with fitness-based selection
function select_parents_and_dead(operator::FitnessBasedSelectionBinaryOperator, generation::Generation)
    first_parent = select_parent(generation)
    second_parent = select_parent(generation)
    first_dead = kill_somebody(generation)
    second_dead = kill_somebody(generation)
    return Individual[first_parent, second_parent], Individual[first_dead, second_dead]
end

# parent selection for that HeuristicCrossover weirdo
function select_parents_and_dead(operator::HeuristicCrossover, generation::Generation)
    first_parent = select_parent(generation)
    second_parent = select_parent(generation)
    dead = kill_somebody(generation)
    if get_fitness(first_parent) > get_fitness(second_parent)
        first_parent, second_parent = second_parent, first_parent
    end
    return Individual[first_parent, second_parent], Individual[dead]
end


function select_random_individual(population::Vector{Individual})
    @inbounds for i = 1:length(population)
        rand_int = rand(2:length(population))       #we don't want to touch the best individual
        if !population[rand_int].dead
            return population[rand_int]
        end
    end

    if length(filter((ind -> !ind.dead), population)) == 0
        error("Everybody's dead, something went wrong")
    end
    select_random_individual(population)
end


function select_parent(generation::Generation)
    population = generation.population
    @inbounds for i = 1:length(population)
        rand_prob = rand()
        index = findfirst((prob -> prob >= rand_prob), generation.cumulative_probabilities)

        if !population[index].dead
            return population[index]
        end
    end

    if length(filter((ind -> !ind.dead), population)) == 0
        error("Everybody's dead, something went wrong")
    end
    select_parent(generation)
end

function kill_somebody(generation::Generation)
    population = generation.population
    @inbounds for i = 1:length(population)
        rand_prob = rand()
        index = findfirst((prob -> prob >= rand_prob), generation.cumulative_probabilities)

        if !population[end - index + 1].dead
            population[end - index + 1].dead = true
            return population[end - index + 1]
        end
    end

    if length(filter((ind -> !ind.dead), population)) == 0
        error("Everybody's dead, something went wrong")
    end
    kill_somebody(generation)
end
