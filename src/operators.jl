
# Uniform Mutation - unary operator uniformly mutating a chromosome

immutable type UniformMutation <: Operator
    arity::Integer
    UniformMutation() = new(1)
end

const _uniform_mutation = UniformMutation()

function apply_operator{T <: FloatingPoint}(operator::UniformMutation, chromosome::Vector{T}, spec::GenocopSpec{T})
    @debug "applying uniform mutation on $chromosome"
    position = rand(1:length(chromosome))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(chromosome, position, spec)

    new_chromosome = copy(chromosome)
    new_chromosome[position] = get_random_float(lower_limit, upper_limit)
    return new_chromosome
end



# BoundaryMutation

immutable type BoundaryMutation <: Operator
    arity::Integer
    BoundaryMutation() = new(1)
end

const _boundary_mutation = BoundaryMutation()

function apply_operator{T <: FloatingPoint}(operator::BoundaryMutation, chromosome::Vector{T}, spec::GenocopSpec{T})
    @debug "applying boundary mutation on $chromosome"
    position = rand(1:length(chromosome))
    lower_limit, upper_limit = find_limits_for_chromosome_mutation(chromosome, position, spec)

    new_chromosome = copy(chromosome)
    new_chromosome[position] = randbool() ? lower_limit : upper_limit
    return new_chromosome
end


function find_limits_for_chromosome_mutation{T <: FloatingPoint}(chromosome::Vector{T}, position::Integer, spec::GenocopSpec{T})
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

immutable type ArithmeticalCrossover <: Operator
    arity::Integer
    ArithmeticalCrossover() = new(2)
end

const _arithmetical_crossover = ArithmeticalCrossover()

function apply_operator{T <: FloatingPoint}(operator::ArithmeticalCrossover, first_chromosome::Vector{T},
                                            second_chromosome::Vector{T}, spec::GenocopSpec{T})
    @debug "applying arithmetical crossover on $first_chromosome and $second_chromosome"
    a = get_random_a()
    first_new = Array(T, length(first_chromosome))
    second_new = Array(T, length(first_chromosome))

    combine_chromosomes!(first_chromosome, second_chromosome, first_new, second_new, a)

    return first_new, second_new
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

immutable type SimpleCrossover <: Operator
    arity::Integer
    step::Integer
    SimpleCrossover() = new(2, _default_simple_crossover_step)
end

const _simple_crossover = SimpleCrossover()

function apply_operator{T <: FloatingPoint}(operator::SimpleCrossover, first_chromosome::Vector{T},
                                            second_chromosome::Vector{T}, spec::GenocopSpec{T})
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
    return first_new, second_new
end

function combine_chromosomes!(first_old::AbstractArray, second_old::AbstractArray,
                                first_new::AbstractArray, second_new::AbstractArray, a)
    for i = 1:length(first_old)
        first_new[i] = first_old[i] * a + second_old[i] * (1-a)
        second_new[i] = first_old[i] * (1-a) + second_old[i] * a
    end
end


_dummy = UniformMutation()

const _operators = [UniformMutation(), BoundaryMutation(), _dummy, ArithmeticalCrossover(), SimpleCrossover()]
