
# Uniform Mutation - unary operator uniformly mutating a chromosome

function apply_operator{T <: FloatingPoint}(operator::UniformMutation, parents::Vector{Vector{T}}, spec::InternalSpec{T}, iteration::Integer)
    chromosome = parents[1]
    @debug "applying uniform mutation on $chromosome"
    position = rand(1:length(chromosome))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(chromosome, position, spec)

    new_chromosome = copy(chromosome)
    new_chromosome[position] = get_random_float(lower_limit, upper_limit)
    return Array{T, 1}[new_chromosome]
end



# BoundaryMutation

function apply_operator{T <: FloatingPoint}(operator::BoundaryMutation, parents::Vector{Vector{T}}, spec::InternalSpec{T}, iteration::Integer)
    chromosome = parents[1]
    @debug "applying boundary mutation on $chromosome"
    position = rand(1:length(chromosome))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(chromosome, position, spec)

    new_chromosome = copy(chromosome)
    new_chromosome[position] = randbool() ? lower_limit : upper_limit
    return Array{T, 1}[new_chromosome]
end


# Non-Uniform Mutation

function apply_operator{T <: FloatingPoint}(operator::NonUniformMutation, parents::Vector{Vector{T}}, spec::InternalSpec{T}, iteration::Integer)
    chromosome = parents[1]
    @debug "applying non-uniform mutation on $chromosome"
    position = rand(1:length(chromosome))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(chromosome, position, spec)

    new_chromosome = copy(chromosome)
    current_value = new_chromosome[position]
    factor = (1 - (iteration / spec.max_iterations) ) ^ operator.degree_of_non_uniformity
    new_chromosome[position] = find_new_non_uniform_value(current_value, lower_limit, upper_limit, factor)
    return Array{T, 1}[new_chromosome]
end


# Whole Non-Uniform Mutation

function apply_operator{T <: FloatingPoint}(operator::WholeNonUniformMutation, parents::Vector{Vector{T}}, spec::InternalSpec{T}, iteration::Integer)
    chromosome = parents[1]
    @debug "applying whole non-uniform mutation on $chromosome"
    new_chromosome = copy(chromosome)

    factor = (1 - (iteration / spec.max_iterations) ) ^ operator.degree_of_non_uniformity
    for position in randperm(length(chromosome))
        # TODO: optimize finding limits so that all limits are found in one call
        # update: probably not possible since with every position changed limits change
        lower_limit, upper_limit = find_limits_for_chromosome_mutation(new_chromosome, position, spec)

        current_value = new_chromosome[position]
        new_chromosome[position] = find_new_non_uniform_value(current_value, lower_limit, upper_limit, factor)
    end

    return Array{T, 1}[new_chromosome]
end

function find_new_non_uniform_value{T <: FloatingPoint}(current_value::T, lower_limit::T, upper_limit::T, factor::Float64)
    if randbool()
        y = current_value - lower_limit
        return current_value - y * rand() * factor
    else
        y = upper_limit - current_value
        return current_value + y * rand() * factor
    end
end


function find_limits_for_chromosome_mutation{T <: FloatingPoint}(chromosome::Vector{T}, position::Integer, spec::InternalSpec{T})
    lower_limit::T = spec.lower_bounds[position]        #initialize limits to initial variable bounds
    upper_limit::T = spec.upper_bounds[position]

    for i = 1:length(spec.inequalities_lower)
        if spec.inequalities[i, position] == 0
            continue
        end

        total = evaluate_row_skip_position(spec.inequalities, chromosome, i, position)

        new_lower_limit = (spec.inequalities_lower[i] - total) / spec.inequalities[i, position]
        new_upper_limit = (spec.inequalities_upper[i] - total) / spec.inequalities[i, position]

        if spec.inequalities[i, position] < 0         #when dividing by a negative number the inequalities are swapped
            new_lower_limit, new_upper_limit = new_upper_limit, new_lower_limit
        end

        lower_limit = max(lower_limit, new_lower_limit)
        upper_limit = min(upper_limit, new_upper_limit)
    end

    if lower_limit > upper_limit
        @warn "Computed range for variable is negative. You may be running into numerical problems. \
                Results of the algorithm may not be feasible"
        if lower_limit == spec.lower_bounds[position]
            return lower_limit, lower_limit
        elseif upper_limit == spec.upper_bounds[position]
            return upper_limit, upper_limit
        else
            return upper_limit, lower_limit
        end
    end

    return lower_limit, upper_limit
end




# Arithmetical Crossover - binary operator that combines two chromosomes (c1, c2) to produce
# a * c1 + (1-a) * c2   and
# (1-a) * c1 + a * c2
# where a is a random number from range (0, 1)

function apply_operator{T <: FloatingPoint}(operator::ArithmeticalCrossover, parents::Vector{Vector{T}}, spec::InternalSpec{T}, iteration::Integer)
    first_chromosome = parents[1]
    second_chromosome = parents[2]
    @debug "applying arithmetical crossover on $first_chromosome and $second_chromosome"
    a = get_random_a()
    first_new = Array(T, length(first_chromosome))
    second_new = Array(T, length(first_chromosome))

    combine_chromosomes!(first_chromosome, second_chromosome, first_new, second_new, a)

    return Array{T, 1}[first_new, second_new]
end

function get_random_a()         # zero is not an interesting case, so we avoid it
    random_a = rand()
    while random_a == 0
        random_a = rand()
    end
    return random_a
end




# Simple Crossover - binary operator that combines two chromosomes similarly to arithmetical crossover,
# but part of the parent is copied into offspring

function apply_operator{T <: FloatingPoint}(operator::SimpleCrossover, parents::Vector{Vector{T}}, spec::InternalSpec{T}, iteration::Integer)
    first_chromosome = parents[1]
    second_chromosome = parents[2]
    @debug "applying simple crossover on $first_chromosome and $second_chromosome"

    first_new = copy(first_chromosome)
    second_new = copy(second_chromosome)
    cut_point = rand(1:length(first_chromosome))
    cross_range::UnitRange
    if randbool()
        cross_range = 1:cut_point
    else
        cross_range = cut_point+1 : length(first_chromosome)
    end
    for i = 1:operator.step
        a = i / operator.step
        combine_chromosomes!(sub(first_chromosome, cross_range), sub(second_chromosome, cross_range),
                                sub(first_new, cross_range), sub(second_new, cross_range), a)
        if is_feasible(first_new, spec) && is_feasible(second_new, spec)
            break
        end
    end
    return Array{T, 1}[first_new, second_new]
end

function combine_chromosomes!(first_old::AbstractArray, second_old::AbstractArray,
                                first_new::AbstractArray, second_new::AbstractArray, a)
    for i = 1:length(first_old)
        first_new[i] = first_old[i] * a + second_old[i] * (1-a)
        second_new[i] = first_old[i] * (1-a) + second_old[i] * a
    end
end


# Heuristic Crossover - returns

function apply_operator{T <: FloatingPoint}(operator::HeuristicCrossover, parents::Vector{Vector{T}}, spec::InternalSpec{T}, iteration::Integer)
    worse_chromosome = parents[1]
    better_chromosome = parents[2]
    @debug "applying heuristic crossover on $worse_chromosome and $better_chromosome"

    a = get_random_a()
    for i = 1:operator.tries
        new_chromosome = combine_better_worse_chromosomes(better_chromosome, worse_chromosome, a)
        if is_within_bounds(new_chromosome, spec) && is_feasible(new_chromosome, spec)
            return Array{T, 1}[new_chromosome]
        end
    end

    return Array{T, 1}[better_chromosome]
end

function combine_better_worse_chromosomes{T <: FloatingPoint}(better_chromosome::Vector{T}, worse_chromosome::Vector{T}, a)
    new_chromosome = Array(T, length(better_chromosome))
    for i = 1:length(better_chromosome)
        new_chromosome[i] = a * (better_chromosome[i] - worse_chromosome[i]) + better_chromosome[i]
    end
    return new_chromosome
end

