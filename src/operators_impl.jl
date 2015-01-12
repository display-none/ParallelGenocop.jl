
# Uniform Mutation - unary operator uniformly mutating a chromosome

function apply_operator!{T <: FloatingPoint}(operator::UniformMutation, parents::Vector{Individual}, children::Vector{Individual}, spec::InternalSpec{T}, iteration::Integer)
    parent = parents[1]
    child = children[1]
    @debug "applying uniform mutation on $parent"
    position = rand(1:length(parent))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(parent, position, spec)

    copy_into(child, parent)
    child[position] = get_random_float(lower_limit, upper_limit)
end



# BoundaryMutation

function apply_operator!{T <: FloatingPoint}(operator::BoundaryMutation, parents::Vector{Individual}, children::Vector{Individual}, spec::InternalSpec{T}, iteration::Integer)
    parent = parents[1]
    child = children[1]
    @debug "applying boundary mutation on $parent"
    position = rand(1:length(parent))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(parent, position, spec)

    copy_into(child, parent)
    child[position] = rand(Bool) ? lower_limit : upper_limit
end


# Non-Uniform Mutation

function apply_operator!{T <: FloatingPoint}(operator::NonUniformMutation, parents::Vector{Individual}, children::Vector{Individual}, spec::InternalSpec{T}, iteration::Integer)
    parent = parents[1]
    child = children[1]
    @debug "applying non-uniform mutation on $parent"
    position = rand(1:length(parent))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(parent, position, spec)

    copy_into(child, parent)
    current_value = child[position]
    factor = (1 - (iteration / spec.max_iterations) ) ^ operator.degree_of_non_uniformity
    child[position] = find_new_non_uniform_value(current_value, lower_limit, upper_limit, factor)
end


# Whole Non-Uniform Mutation

function apply_operator!{T <: FloatingPoint}(operator::WholeNonUniformMutation, parents::Vector{Individual}, children::Vector{Individual}, spec::InternalSpec{T}, iteration::Integer)
    parent = parents[1]
    child = children[1]
    @debug "applying whole non-uniform mutation on $parent"

    child_chromosome = get_chromosome(parent)
    factor = (1 - (iteration / spec.max_iterations) ) ^ operator.degree_of_non_uniformity
    for position in randperm(length(child_chromosome))
        # TODO: optimize finding limits so that all limits are found in one call
        # update: probably not possible since with every position changed limits change
        @debug "whole non-uniform on position $position"
        current_value = child_chromosome[position]
        child_chromosome[position] = 0.0
        inequalities_evaluated = At_mul_B(spec.ineq, child_chromosome)
    
        lower_limit, upper_limit = find_limits_for_chromosome_mutation(inequalities_evaluated, position, spec, current_value)

        child_chromosome[position] = find_new_non_uniform_value(current_value, lower_limit, upper_limit, factor)
        # if !is_feasible(child_chromosome, spec)
        #     @info "$lower_limit, $upper_limit"
        #     @info "$position"
        #     @info "$(child_chromosome[position])"
        #     error("kolejna dupa")
        # end

    end

    set_chromosome!(child, child_chromosome)
end

function find_new_non_uniform_value{T <: FloatingPoint}(current_value::T, lower_limit::T, upper_limit::T, factor::Float64)
    if rand(Bool)
        y = current_value - lower_limit
        return current_value - y * rand() * factor
    else
        y = upper_limit - current_value
        return current_value + y * rand() * factor
    end
end

function find_limits_for_chromosome_mutation{T <: FloatingPoint}(individual::Individual, position::Integer, spec::InternalSpec{T})
    chromosome = get_chromosome(individual)
    current_value = chromosome[position]
    chromosome[position] = 0.0
    inequalities_evaluated = At_mul_B(spec.ineq, chromosome)
    chromosome[position] = current_value
    find_limits_for_chromosome_mutation(inequalities_evaluated, position, spec, current_value)
end

function find_limits_for_chromosome_mutation{T <: FloatingPoint}(inequalities_evaluated::Vector{T}, position::Integer, spec::InternalSpec{T}, default::T)
    lower_limit::T = -Inf        #initialize limits to initial variable bounds
    upper_limit::T = Inf
    (length(inequalities_evaluated) == length(spec.inequalities_lower)) || BoundsError()
    
    @inbounds for i = 1:length(spec.inequalities_lower)
        #if abs(spec.inequalities[i, position]) < eps(T)
        if spec.inequalities[i, position] == 0.0
            continue
        end

        new_lower_limit = (spec.inequalities_lower[i] - inequalities_evaluated[i]) / spec.inequalities[i, position]
        new_upper_limit = (spec.inequalities_upper[i] - inequalities_evaluated[i]) / spec.inequalities[i, position]

        if spec.inequalities[i, position] < 0         #when dividing by a negative number the inequalities are swapped
            new_lower_limit, new_upper_limit = new_upper_limit, new_lower_limit
        end

        lower_limit = max(lower_limit, new_lower_limit)
        upper_limit = min(upper_limit, new_upper_limit)
        # if upper_limit < -1
        #     @info "oooooo $i, $position"
        #     @info "$(spec.inequalities[i, position])"
        #     @info "$(spec.inequalities_upper)"
        #     @info "$(spec.inequalities_lower)"
        #     @info "$chromosome"
        #     @info "$total"
        #     @info "$upper_limit"
        #     error()
        # end
    end

    lower_limit = max(lower_limit, spec.lower_bounds[position])
    upper_limit = min(upper_limit, spec.upper_bounds[position])

    # if lower_limit < 0
    #     @info "$(spec.lower_bounds[position])"
    #     @info "$position"
    # end

    # if upper_limit < 0
    #     @info "przegięcie"
    #     @info "$(spec.lower_bounds[position])"
    #     @info "$position"
    # end

    lower_limit, upper_limit = replace_infinities(lower_limit, upper_limit)

    # val = chromosome[position]
    # chromosome[position] = lower_limit
    # if !is_feasible_pseudo(chromosome, spec)
    #     @info "nope1 $chromosome"
    #     @info "$position"
    #     @info "$lower_limit"
    #     error()
    # end
    # chromosome[position] = upper_limit
    # if !is_feasible_pseudo(chromosome, spec)
    #     @info "nope2 $chromosome"
    #     @info "$position"
    #     @info "$upper_limit"
    #     error()
    # end
    # chromosome[position] = val

    if lower_limit > upper_limit
        # if lower_limit - upper_limit > 10
        #     @info "kurwa $lower_limit, $upper_limit"
        #     @info "$position"
        #     error()
        # end
        # @warn "Computed range for variable is negative. You may be running into numerical problems. \
        #        Results of the algorithm may not be feasible"
        return default, default
    end

    return lower_limit, upper_limit
end




# Arithmetical Crossover - binary operator that combines two chromosomes (c1, c2) to produce
# a * c1 + (1-a) * c2   and
# (1-a) * c1 + a * c2
# where a is a random number from range (0, 1)

function apply_operator!{T <: FloatingPoint}(operator::ArithmeticalCrossover, parents::Vector{Individual}, children::Vector{Individual}, spec::InternalSpec{T}, iteration::Integer)
    first_parent = parents[1]
    second_parent = parents[2]
    first_child = children[1]
    second_child = children[2]
    @debug "applying arithmetical crossover on $first_parent and $second_parent"
    a = get_random_a()

    combine_chromosomes!(first_parent, second_parent, first_child, second_child, a)
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

function apply_operator!{T <: FloatingPoint}(operator::SimpleCrossover, parents::Vector{Individual}, children::Vector{Individual}, spec::InternalSpec{T}, iteration::Integer)
    first_parent = parents[1]
    second_parent = parents[2]
    first_child = children[1]
    second_child = children[2]
    # @debug "applying simple crossover on $first_parent and $second_parent"

    cut_point = rand(1:length(first_parent))
    cross_range::UnitRange
    copy_range::UnitRange
    if rand(Bool)
        cross_range = 1:cut_point
        copy_range = cut_point+1 : length(first_parent)
    else
        copy_range = 1:cut_point
        cross_range = cut_point+1 : length(first_parent)
    end
    copy_into(first_child, first_parent, copy_range)
    copy_into(second_child, second_parent, copy_range)
    for i = 1:operator.step
        a = i / operator.step
        combine_chromosomes!(first_parent, second_parent, first_child, second_child, a, cross_range)
        if is_feasible(first_child, spec) && is_feasible(second_child, spec)
            break
        end
    end
end

function combine_chromosomes!(first_parent::Individual, second_parent::Individual,
                                first_child::Individual, second_child::Individual, a::Float64)
    combine_chromosomes!(first_parent, second_parent, first_child, second_child, a, 1:length(first_parent))
end

type CombineFunctor <: Functor{2}
    a::Float64
end
NumericExtensions.result_type{T <: FloatingPoint}(::CombineFunctor, ::Type{T}, ::Type{T}) = T
NumericExtensions.evaluate(cf::CombineFunctor, x, y) = cf.a * x + (1-cf.a) * y

function combine_chromosomes!(first_parent::Individual, second_parent::Individual,
                                first_child::Individual, second_child::Individual, a::Float64, range::UnitRange)
    (first(range) >= 1 && last(range) <= min(length(first_parent), length(second_parent), length(first_child), length(second_child))) || BoundsError()
    first_chromosome = get_chromosome(first_parent, range)
    second_chromosome = get_chromosome(second_parent, range)
    first_child_chromosome = map(CombineFunctor(a), first_chromosome, second_chromosome)
    second_child_chromosome = map(CombineFunctor(a), second_chromosome, first_chromosome)
    set_chromosome!(first_child, first_child_chromosome, range)
    set_chromosome!(second_child, second_child_chromosome, range)
end


# Heuristic Crossover - returns

function apply_operator!{T <: FloatingPoint}(operator::HeuristicCrossover, parents::Vector{Individual}, children::Vector{Individual}, spec::InternalSpec{T}, iteration::Integer)
    worse_parent = parents[1]
    better_parent = parents[2]
    child = children[1]
    @debug "applying heuristic crossover on $worse_parent and $better_parent"

    a = get_random_a()
    for i = 1:operator.tries
        combine_better_worse_parents(better_parent, worse_parent, child, a)
        if is_within_bounds(child, spec) && is_feasible(child, spec)
            return
        end
    end

    copy_into(child, better_parent)
end

function combine_better_worse_parents(better_parent::Individual, worse_parent::Individual, child::Individual, a)
    better_chromosome = get_chromosome(better_parent)
    worse_chromosome = get_chromosome(worse_parent)
    @inbounds for i = 1:length(better_parent)
        child[i] = a * (better_chromosome[i] - worse_chromosome[i]) + better_chromosome[i]
    end
end

