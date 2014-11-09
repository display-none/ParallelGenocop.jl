
function initialize_population{T <: FloatingPoint}(spec::InternalSpec{T})
    if spec.starting_population_type == single_point_start_pop
        if spec.starting_point == nothing
            return initialize_population_single_point(spec)
        else
            return initialize_population_specified_point(spec)
        end
    else
        return initialize_population_multipoint(spec)
    end
end

function initialize_population_single_point{T <: FloatingPoint}(spec::InternalSpec{T})
    @debug "beginning to initialize single point population"

    individual = get_feasible_individual(spec)
    if individual == nothing
        @error "No feasible individual was found in $_population_initialization_tries tries. \
                You can try again with starting point specified in the GenocopSpec"
        error("no feasible individual found")
    end

    return Individual{T}[deepcopy(individual) for i=1:spec.population_size]
end

function initialize_population_specified_point{T <: FloatingPoint}(spec::InternalSpec{T})
    @debug "beginning to initialize single point population from specified starting point"
    chromosome = spec.starting_point
    if !is_feasible(chromosome, spec)
        @error "The point specified in GenocopSpec is not feasible"
        error("starting point not feasible")
    end
	new_chromosome_shared = SharedArray(T, length(chromosome))
    @inbounds for i=1:length(chromosome)
        new_chromosome_shared[i] = chromosome[i]
    end

    return Individual{T}[Individual(copy(new_chromosome_shared)) for i=1:spec.population_size]
end

function initialize_population_multipoint{T <: FloatingPoint}(spec::InternalSpec{T})
    @debug "beginning to initialize multi point population"

    population = Array(Individual{T}, spec.population_size)
    for i=1:spec.population_size
        individual = get_feasible_individual(spec)
        if individual == nothing
            @error "No feasible individual was found in $_population_initialization_tries tries. \
                    Before this failure we generated successfully $i individuals. \
                    You can try again with starting point specified in the GenocopSpec"
            error("no feasible individual found")
        end

        population[i] = individual
    end
    return population
end

function get_feasible_individual{T <: FloatingPoint}(spec::InternalSpec{T})

    for i = 1:_population_initialization_tries

        random_chromosome = get_random_chromosome_within_bounds(spec)

        if is_feasible(random_chromosome, spec)
			new_chromosome_shared = SharedArray(T, length(random_chromosome))
            @inbounds for i=1:length(random_chromosome)
                new_chromosome_shared[i] = random_chromosome[i]
            end
            return Individual(new_chromosome_shared)
        end
    end

    return nothing
end

function get_random_chromosome_within_bounds{T <: FloatingPoint}(spec::InternalSpec{T})
    chromosome = Array(T, spec.no_of_variables)
    for i in 1:spec.no_of_variables
        low = spec.lower_bounds[i]
        upp = spec.upper_bounds[i]
        chromosome[i] = get_random_float(low, upp)
    end

    @debug "generated a random chromosome: $chromosome"
    return chromosome
end
