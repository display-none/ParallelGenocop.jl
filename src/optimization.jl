

function optimize!{T <: FloatingPoint}(initial_population::Vector{Individual{T}}, spec::InternalSpec{T})
    @debug "Beginning optimization"
    best_individual::Individual{T} = initial_population[1]
    new_population = initial_population
    evaluate_population!(new_population, spec)
    iteration = 1


    total_total = 0.0
    total_computation = 0.0

    while iteration < spec.max_iterations
        generation = Generation(iteration, new_population, copy(spec.operator_frequency))

        population = generation.population
        #evaluate_population!(population, spec)
        sort_population!(population, spec.minmax)
        generation.cumulative_probabilities = cumsum(compute_probabilities!(population, spec.cumulative_prob_coeff))    #can be changed to cumsum_kbn for increased accuracy
        best_individual = find_best_individual(best_individual, population[1], spec.minmax, iteration)

        new_population, total, computation = apply_operators_to_create_new_population!(generation, spec)
        total_total += total
        total_computation += computation
        iteration += 1
    end

    #evaluate_population!(new_population, spec)
    sort_population!(new_population, spec.minmax)
    best_individual = find_best_individual(best_individual, new_population[1], spec.minmax, spec.max_iterations)

    println("\n\nTime of call + computation: $total_total.\nTime of computation: $total_computation\n")
    println("Communication overhead: $(total_total / total_computation * 100)%\n\n")

    @debug "best individual found with fitness $(best_individual.fitness)"
    return best_individual
end


function aaapply_operators_to_create_new_population!{T <: FloatingPoint}(generation::Generation{T}, spec::InternalSpec{T})
    @debug "applying operators"
    new_population::Vector{Individual{T}} = []
    operator_applications_left = generation.operator_applications_left
    while sum(operator_applications_left) > 0
        random = rand(1:length(spec.operators))

        if operator_applications_left[random] > 0
            operator = spec.operators[random]

            parent_chromosomes = select_parents(operator, generation)
            new_individuals, time = apply_operator(operator, parent_chromosomes, generation.number)
            append!(new_population, new_individuals)

            operator_applications_left[random] -= 1
        end
    end

    append!(new_population, filter((ind -> !ind.dead), generation.population))
    return new_population, 0, 0
end

#parallel
function aaaaaaaapply_operators_to_create_new_population!{T <: FloatingPoint}(generation::Generation{T}, spec::InternalSpec{T})
    @debug "applying operators"
    new_population::Vector{Individual{T}} = []

    total_total = 0.0
    total_computation = 0.0

    operator_applications_left = generation.operator_applications_left
    remote_references = RemoteRef[]

    while sum(operator_applications_left) > 0
        random = rand(1:length(spec.operators))

        if operator_applications_left[random] > 0
            operator = spec.operators[random]

            parent_chromosomes = select_parents(operator, generation)
            tic()
            ref = @spawn apply_operator(operator, parent_chromosomes, generation.number)
            push!(remote_references, ref)
            total_total += toq()

            operator_applications_left[random] -= 1
        end
    end

    for ref in remote_references
        tic()
        new_individuals, time = fetch(ref)
        total_total += toq()
        append!(new_population, new_individuals)
        total_computation += time
    end

    append!(new_population, filter((ind -> !ind.dead), generation.population))


    return new_population, total_total, total_computation
end

function apply_operators_to_create_new_population!{T <: FloatingPoint}(generation::Generation{T}, spec::InternalSpec{T})
    @debug "applying operators"
    new_population::Vector{Individual{T}} = []

    total_total = 0.0
    total_computation = 0.0

    operator_applications_left = generation.operator_applications_left
    remote_references = RemoteRef[]
    todos = (Vector{AbstractVector{T}}, Operator)[]

    while sum(operator_applications_left) > 0
        random = rand(1:length(spec.operators))

        if operator_applications_left[random] > 0
            operator = spec.operators[random]

            parent_chromosomes = select_parents(operator, generation)
            push!(todos, (parent_chromosomes, operator))


            operator_applications_left[random] -= 1
        end
    end

    tic()
#    procs = nprocs()
#    if procs == 1
#        new_individuals, time = fuckin_apply(todos, generation.number)
#        new_population = new_individuals
#    else
#        starting_index = 1
#        todos_length = length(todos)
#        for proc = 1:procs-1
#            range = starting_index : starting_index + div(todos_length-starting_index, procs-proc)
#            todos_part = todos[range]
#            ref = @spawn fuckin_apply(todos_part, generation.number)
#            push!(remote_references, ref)
#            starting_index = range[end]+1
#        end

#        for ref in remote_references
#            new_individuals, time = fetch(ref)
#            append!(new_population, new_individuals)
#            total_computation += time
#        end

        function red(one::(Array, FloatingPoint), two::(Array, FloatingPoint))
            return ([one[1];two[1]], one[2]+two[2])
        end
        generation_number = generation.number
        new_population, time = @parallel (red) for i=1:length(todos)
            apply_operator(todos[i][2], todos[i][1], generation_number)
        end
        total_computation += time
#    end
    total_total += toq()

    append!(new_population, filter((ind -> !ind.dead), generation.population))


    return new_population, total_total, total_computation
end

function fuckin_apply{T <: FloatingPoint}(todos::Vector{(Vector{Vector{T}}, Operator)}, generation_number::Int)
    new_chromosomes = Individual{T}[]
    total_time = 0.0
    for (chromosomes, operator) in todos
       new_individuals, time = apply_operator(operator, chromosomes, generation_number)
       total_time += time
       append!(new_chromosomes, new_individuals)
    end
    return new_chromosomes, total_time
end


function apply_operator{T <: FloatingPoint}(operator::Operator, parent_chromosomes::Vector{AbstractVector{T}}, generation_number::Int)
    tic()
    spec = spec_holder.spec
    new_chromosomes = apply_operator(operator, parent_chromosomes, spec, generation_number)
    new_individuals = [Individual(chromosome) for chromosome in new_chromosomes]
    for new_individual in new_individuals
        new_individual.fitness = evaluate_and_return_fitness(new_individual, spec)
    end
    return new_individuals, toq()
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
