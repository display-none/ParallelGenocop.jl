

function optimize!{T <: FloatingPoint}(initial_population::Vector{Individual}, spec::InternalSpec{T})
    @debug "Beginning optimization"
    best_individual::Individual = initial_population[1]
    new_population = initial_population
    iteration = 1

    cumulative_probabilities = cumsum(compute_probabilities!(spec.population_size, spec.cumulative_prob_coeff))    #can be changed to cumsum_kbn for increased accuracy

    total_total = 0.0
    total_computation = 0.0

    while iteration < spec.max_iterations
        generation = Generation(iteration, new_population, copy(spec.operator_frequency))
        generation.cumulative_probabilities = cumulative_probabilities

        population = generation.population
        sort_population!(population, spec.minmax)
        best_individual = find_best_individual(best_individual, population[1], spec.minmax, iteration)

        new_population, total, computation = apply_operators_to_create_new_population!(generation, spec)
        total_total += total
        total_computation += computation
        iteration += 1
        @info "generation $iteration"
    end

    sort_population!(new_population, spec.minmax)
    best_individual = find_best_individual(best_individual, new_population[1], spec.minmax, spec.max_iterations)

    println("\n\nTime of call + computation: $total_total.\nTime of computation: $total_computation\n")
    println("Communication overhead: $(total_total / total_computation * 100)%\n\n")

    @debug "best individual found with fitness $(get_fitness(best_individual))"
    return best_individual
end


function aaapply_operators_to_create_new_population!{T <: FloatingPoint}(generation::Generation, spec::InternalSpec{T})
    @debug "applying operators"
    new_population::Vector{Individual} = []
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
function aaaaaaaapply_operators_to_create_new_population!{T <: FloatingPoint}(generation::Generation, spec::InternalSpec{T})
    @debug "applying operators"
    new_population::Vector{Individual} = []

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

function apply_operators_to_create_new_population!{T <: FloatingPoint}(generation::Generation, spec::InternalSpec{T})
    @debug "applying operators"
    new_population::Vector{Individual} = []

    total_total = 0.0
    total_computation = 0.0

    operator_applications_left = generation.operator_applications_left
    jobs = ASCIIString[]

    while sum(operator_applications_left) > 0
        random = rand(1:length(spec.operators))

        if operator_applications_left[random] > 0
            operator = spec.operators[random]

            parents, dead = select_parents_and_dead(operator, generation)
            children = prepare_children_from_dead(dead)
            push!(jobs, serialize_job(parents, children, operator, spec))
            append!(new_population, children)


            operator_applications_left[random] -= 1
        end
    end

    tic()
    generation_number = generation.number
    time = @parallel (+) for i=1:length(jobs)
        apply_operator!(jobs[i], generation_number)
    end
    total_computation += time
    total_total += toq()

    append!(new_population, filter((ind -> !ind.dead), generation.population))


    return new_population, total_total, total_computation
end

function serialize_job{T <: FloatingPoint}(parents::Vector{Individual}, children::Vector{Individual}, operator::Operator, spec::InternalSpec{T})
	p = join([string(ind.column) for ind in parents], ',')
	c = join([string(ind.column) for ind in children], ',')
	o = string(findfirst(spec.operators, operator))
	return "$p;$c;$o"
end

function deserialize_job{T <: FloatingPoint}(job::ASCIIString, spec::InternalSpec{T})
	p, c, o = split(job, ';')
	parents = [Individual(int(i)) for i in split(p, ',')]
	children = [Individual(int(i)) for i in split(c, ',')]
	operator = spec.operators[int(o)]
	return parents, children, operator
end

function apply_operator!(job::ASCIIString, generation_number::Int)
	spec = spec_holder.spec
	parents, children, operator = deserialize_job(job, spec)
	return apply_operator!(operator, parents, children, generation_number, spec)
end

function apply_operator!{T <: FloatingPoint}(operator::Operator, parents::Vector{Individual}, children::Vector{Individual}, generation_number::Int, spec::InternalSpec{T})
    tic()
    apply_operator!(operator, parents, children, spec, generation_number)
    for child in children
        set_fitness!(child, evaluate_and_return_fitness(child, spec))
    end


    # for child in children
    #     if is_feasible(child, spec)
    #         @info "fuck yeah!"
    #         @info "$child"
    #         error()
    #     end
    # end

    return toq()
end

function prepare_children_from_dead(dead::Vector{Individual})
    return [Individual(d.column) for d in dead]
end

function find_best_individual(current::Individual, new::Individual, minmax::MinMaxType, generation_no)
    @debug "checking for new best individual"
    if minmax == minimization
        if get_fitness(new) < get_fitness(current)
            @info "Solution improved. Generation $generation_no, value $(get_fitness(new))"
            return new
        else
            return current
        end
    else
        if get_fitness(current) < get_fitness(new)
            @info "Solution improved. Generation $generation_no, value $(get_fitness(new))"
            return new
        else
            return current
        end
    end
end
