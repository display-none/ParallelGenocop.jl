

function optimize!{T <: FloatingPoint}(initial_population::Vector{Individual{T}}, spec::GenocopSpec{T}, evaluate_func::Function)
    @debug "Beginning optimization"
    best_individual::Individual{T} = initial_population[1]
    new_population = initial_population
    iteration = 1

    while iteration < spec.max_iterations
        generation = Generation(iteration, new_population, copy(spec.operator_frequency))

        population = generation.population
        evaluate_population!(population, evaluate_func)
        sort_population!(population, spec.minmax)
        generation.cumulative_probabilities = cumsum(compute_probabilities!(population))    #can be changed to cumsum_kbn for increased accuracy
        best_individual = find_best_individual(best_individual, population[1], spec.minmax, iteration)

        new_population = apply_operators_to_create_new_population!(generation, spec)
        iteration += 1
    end

    evaluate_population!(new_population, evaluate_func)
    sort_population!(new_population, spec.minmax)
    best_individual = find_best_individual(best_individual, new_population[1], spec.minmax, spec.max_iterations)


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

            new_individuals = apply_operator(operator, generation, spec)
            append!(new_population, new_individuals)

            operator_applications_left[random] -= 1
        end
    end

    append!(new_population, filter((ind -> !ind.dead), generation.population))
    return new_population
end


function apply_operator{T <: FloatingPoint}(operator::Operator, generation::Generation{T}, spec::GenocopSpec{T})
    parent_chromosomes = select_parents(operator, generation)
    new_chromosomes = apply_operator(operator, parent_chromosomes, spec, generation.number)
    return [Individual(chromosome) for chromosome in new_chromosomes]
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
