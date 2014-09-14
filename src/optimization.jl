

function optimize!{T <: FloatingPoint}(initial_population::Vector{Individual{T}}, spec::GenocopSpec{T}, evaluate_func::Function)
    @debug "Beginning optimization"
    best_individual::Individual{T} = initial_population[1]
    generation = Generation(initial_population, copy(spec.operator_frequency))

    for i = 1:(spec.max_iterations-1)
        population = generation.population
        evaluate_population!(population, evaluate_func)
        sort_population!(population, spec.minmax)
        generation.cumulative_probabilities = cumsum(compute_probabilities!(population))    #can be changed to cumsum_kbn for increased accuracy
        best_individual = find_best_individual(best_individual, population[1], spec.minmax, i)

        new_population = apply_operators_to_create_new_population!(generation, spec)

        generation = Generation(new_population, copy(spec.operator_frequency))
    end

    evaluate_population!(generation.population, evaluate_func)
    sort_population!(generation.population, spec.minmax)
    best_individual = find_best_individual(best_individual, generation.population[1], spec.minmax, spec.max_iterations)


    @debug "best individual found with fitness $(best_individual.fitness)"
    return best_individual
end


function compute_probabilities!{T <: FloatingPoint}(population::Vector{Individual{T}})
    probabilities = Array(Float64, length(population))
    total_fitness = sum((ind -> ind.fitness), population)
    for i in 1:length(population)
        probabilities[i] = population[i].fitness / total_fitness
    end
    return probabilities
end

function apply_operators_to_create_new_population!{T <: FloatingPoint}(generation::Generation{T}, spec::GenocopSpec{T})
    @debug "applying operators"
    new_population::Vector{Individual{T}} = []
    operator_applications_left = generation.operator_applications_left
    while sum(operator_applications_left) > 0
        random = rand(1:length(spec.operators))

        if operator_applications_left[random] > 0
            operator = spec.operators[random]

            if operator.arity == 1
                new_individual = apply_unary_operator(operator, generation, spec)
                push!(new_population, new_individual)
            elseif operator.arity == 2
                first_new_individual, second_new_individual = apply_binary_operator(operator, generation, spec)
                push!(new_population, first_new_individual)
                push!(new_population, second_new_individual)
            else
                error("only unary and binary operators are currently supported")
            end

            operator_applications_left[random] -= 1
        end
    end

    append!(new_population, filter((ind -> !ind.dead), generation.population))
    return new_population
end


function apply_unary_operator{T <: FloatingPoint}(operator::Operator, generation::Generation{T}, spec::GenocopSpec{T})
    individual = select_random_individual(generation.population)
    individual.dead = true
    new_chromosome = apply_operator(operator, individual.chromosome, spec)
    return Individual(new_chromosome)
end

function apply_binary_operator{T <: FloatingPoint}(operator::Operator, generation::Generation{T}, spec::GenocopSpec{T})
    first_parent = select_parent(generation)
    second_parent = select_parent(generation)
    kill_somebody(generation)
    kill_somebody(generation)
    if !same(first_parent, second_parent)
        first_chromosome, second_chromosome = apply_operator(operator, first_parent.chromosome, second_parent.chromosome, spec)
        return Individual(first_chromosome), Individual(second_chromosome)
    else
        @debug "same parents, binary operator application not needed"
        return Individual(copy(first_parent.chromosome)), Individual(copy(first_parent.chromosome))
    end
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

function find_best_individual(current::Individual, new::Individual, minmax::MinMaxType, generation_no)
    @debug "checking for new best individual"
    if minmax == minimization
        if new.fitness < current.fitness
            @info "Solution improved. Generation $generation_no, value $(new.fitness)"
            return new
        else
            return current
        end
    else
        if current.fitness < new.fitness
            @info "Solution improved. Generation $generation_no, value $(new.fitness)"
            return new
        else
            return current
        end
    end
end
