


#proportional
function compute_probabilities_old!{T <: FloatingPoint}(population::Vector{Individual{T}})
    probabilities = Array(Float64, length(population))
    total_fitness = sum((ind -> ind.fitness), population)
    for i in 1:length(population)
        probabilities[i] = population[i].fitness / total_fitness
    end
    return probabilities
end

# the probabilities are basically Q, Q*(1-Q), Q*(1-Q)^2, ..., Q*(1-Q)^n
# it's just slightly modified to sum to 1
function compute_probabilities!{T <: FloatingPoint}(population::Vector{Individual{T}}, cumulative_prob_coeff)
    probabilities = Array(Float64, length(population))
    Q = cumulative_prob_coeff
    Q1 = Q / (1 - (1 - Q)^length(population))
    for i in 1:length(population)
        probabilities[i] = Q1 * (1 - Q)^(i-1)
    end
    return probabilities
end


# parent selection for unary operators with uniform selection
function select_parents{T <: FloatingPoint}(operator::UniformSelectionUnaryOperator, generation::Generation{T})
    individual = select_random_individual(generation.population)
    individual.dead = true
    return Array{T, 1}[individual.chromosome]
end

# parent selection for binary operators with fitness-based selection
function select_parents{T <: FloatingPoint}(operator::FitnessBasedSelectionBinaryOperator, generation::Generation{T})
    first_parent = select_parent(generation)
    second_parent = select_parent(generation)
    kill_somebody(generation)
    kill_somebody(generation)
    return Array{T, 1}[first_parent.chromosome, second_parent.chromosome]
end

# parent selection for that HeuristicCrossover weirdo
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
