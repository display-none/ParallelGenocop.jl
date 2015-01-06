
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

    chromosome = get_feasible_chromosome(spec)
    if chromosome == nothing
        @error "No feasible chromosome was found in $_population_initialization_tries tries. \
                You can try again with starting point specified in the GenocopSpec"
        error("no feasible chromosome found")
    end
    fitness = evaluate_and_return_fitness(chromosome, spec)
    initialize_population_data_with_point(chromosome, fitness)
    return Individual[Individual(i) for i=1:spec.population_size]
end

function initialize_population_specified_point{T <: FloatingPoint}(spec::InternalSpec{T})
    @debug "beginning to initialize single point population from specified starting point"
    starting_point = spec.starting_point
    no_of_removed_variables = length(spec.R1inv_c)
    permutated = Array(T, length(spec.permutation_vector))
    permutated[spec.permutation_vector] = spec.starting_point
    chromosome = permutated[no_of_removed_variables+1 : end]
    if !is_feasible(chromosome, spec)
        @error "The point specified in GenocopSpec is not feasible"
        error("starting point not feasible")
    end
    fitness = evaluate_and_return_fitness(chromosome, spec)
    initialize_population_data_with_point(chromosome, fitness)
    return Individual[Individual(i) for i=1:spec.population_size]
end

function initialize_population_data_with_point{T <: FloatingPoint}(chromosome::Vector{T}, fitness::T)
    population_data = population_data_holder.population_data
    rows = size(population_data, 1)
    cols = size(population_data, 2)
    rows == length(chromosome) || BoundsError()
    @inbounds for c=1:cols
        for r=1:rows
            population_data[r, c] = chromosome[r]
        end
    end

    fitness_data = population_data_holder.fitness_data
    @inbounds for i = 1:length(fitness_data)
        fitness_data[i] = fitness
    end
end

function initialize_population_multipoint{T <: FloatingPoint}(spec::InternalSpec{T})
    @debug "beginning to initialize multi point population"

    population = Array(Individual, spec.population_size)
    @inbounds for i=1:spec.population_size
        chromosome = get_feasible_chromosome(spec)
        if chromosome == nothing
            @error "No feasible chromosome was found in $_population_initialization_tries tries. \
                    Before this failure we generated successfully $i chromosomes. \
                    You can try again with starting point specified in the GenocopSpec"
            error("no feasible individual found")
        end

        fitness = evaluate_and_return_fitness(chromosome, spec)
        population[i] = Individual(i, chromosome, fitness)
    end
    return population
end

function get_feasible_chromosome{T <: FloatingPoint}(spec::InternalSpec{T})

    for i = 1:_population_initialization_tries

        random_chromosome = get_random_chromosome_within_bounds(spec)

        if is_feasible(random_chromosome, spec)
            return random_chromosome
        end
    end

    return nothing
end

function get_random_chromosome_within_bounds{T <: FloatingPoint}(spec::InternalSpec{T})
    chromosome = Array(T, spec.no_of_variables)
    @inbounds for i in 1:spec.no_of_variables
        low = spec.lower_bounds[i]
        upp = spec.upper_bounds[i]
        chromosome[i] = get_random_float(low, upp)
    end

    @debug "generated a random chromosome: $chromosome"
    return chromosome
end
