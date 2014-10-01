

function select_parents{T <: FloatingPoint}(operator::UniformSelectionUnaryOperator, generation::Generation{T})
    individual = select_random_individual(generation.population)
    individual.dead = true
    return Array{T, 1}[individual.chromosome]
end

function select_parents{T <: FloatingPoint}(operator::FitnessBasedSelectionBinaryOperator, generation::Generation{T})
    first_parent = select_parent(generation)
    second_parent = select_parent(generation)
    kill_somebody(generation)
    kill_somebody(generation)
    return Array{T, 1}[first_parent.chromosome, second_parent.chromosome]
end

function select_parents{T <: FloatingPoint}(operator::HeuristicCrossover, generation::Generation{T})
    first_parent = select_parent(generation)
    second_parent = select_parent(generation)
    kill_somebody(generation)
    if first_parent.fitness > second_parent.fitness
        first_parent, second_parent = second_parent, first_parent
    end
    return Array{T, 1}[first_parent.chromosome, second_parent.chromosome]
end


function select_random_individual{T <: FloatingPoint}(population::Vector{Individual{T}})
    for i = 1:length(population)
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


function select_parent{T <: FloatingPoint}(generation::Generation{T})
    population = generation.population
    for i = 1:length(population)
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
    for i = 1:length(population)
        rand_prob = rand()
        index = findfirst((prob -> prob >= rand_prob), generation.cumulative_probabilities)

        if !population[end - index + 1].dead
            population[end - index + 1].dead = true
            return
        end
    end

    if length(filter((ind -> !ind.dead), population)) == 0
        error("Everybody's dead, something went wrong")
    end
    kill_somebody(generation)
end
