

# due to quite complex math done here it's hard to divide this code into smaller methods, it's all kinda connected
# I'll try to do some heavy commenting so that it's understandable

# all that is done here is nicely described in section 7.1 of Evolution Programs by Zbigniew Michalewicz
# variable names are mostly meaningless since they reference the names in the book
function reduce_equalities{T <: FloatingPoint}(spec::GenocopSpecification{T})

    num_of_equalities = length(spec.equalities_right)

    if num_of_equalities == 0
        return convert_no_equalities_spec_into_internal(spec)
    end

    variables_to_reduce, remaining_variables = choose_variables_to_reduce(num_of_equalities, length(spec.lower_bounds))

    # original matrix of equalities is separated into A1 and A2, the first one is to be reduced
    A1 = getindex(spec.equalities, 1:num_of_equalities, variables_to_reduce)
    A2 = getindex(spec.equalities, 1:num_of_equalities, remaining_variables)

    # computing A1inv_b = product of inverse of A1 and b (right hand side of equations
    A1inv = inv(A1)
    A1inv_b = A1inv * spec.equalities_right

    # computing A1inv_A2 = product of inverse of A1 and A2
    A1inv_A2 = A1inv * A2

    # original inequalities get divided into C1 and C2
    num_of_inequalities = length(spec.inequalities_lower)
    C1 = getindex(spec.inequalities, 1:num_of_inequalities, variables_to_reduce)
    C2 = getindex(spec.inequalities, 1:num_of_inequalities, remaining_variables)
    # new inequalities computed (math behind this is in the book)
    new_inequalities = C2 - C1 * A1inv_A2

    # to complete the inequalities reduction we subtract C1_A1inv_b (math in the book)
    C1_A1inv_b = C1 * A1inv_b
    new_inequalities_lower = spec.inequalities_lower - C1_A1inv_b
    new_inequalities_upper = spec.inequalities_upper - C1_A1inv_b

    # upper and lower bounds for variables are separated
    lower_bounds_reduce = getindex(spec.lower_bounds, variables_to_reduce)
    new_lower_bounds = getindex(spec.lower_bounds, remaining_variables)

    upper_bounds_reduce = getindex(spec.upper_bounds, variables_to_reduce)
    new_upper_bounds = getindex(spec.upper_bounds, remaining_variables)

    # the reduced variables are additionally bounded by upper and lower bounds so we convert these into inequalities
    new_inequalities = vcat(new_inequalities, -A1inv_A2)
    append!(new_inequalities_lower, lower_bounds_reduce - A1inv_b)
    append!(new_inequalities_upper, upper_bounds_reduce - A1inv_b)

    # now the number of variables the algorithm is going to work on is smaller
    no_of_variables = length(new_lower_bounds)

    # packing it all into the spec and voila
    return InternalSpec(spec.evaluation_function,
                        variables_to_reduce,
                        new_inequalities,
                        new_inequalities_lower,
                        new_inequalities_upper,
                        new_lower_bounds,
                        new_upper_bounds,
                        spec.population_size,
                        spec.max_iterations,
                        spec.operator_mapping,
                        spec.cumulative_prob_coeff,
                        spec.minmax,
                        spec.starting_population_type,
                        no_of_variables,
                        A1inv_b,
                        A1inv_A2)
end

function choose_variables_to_reduce(num_of_equalities::Int, num_of_variables::Int)
#    random_perm = randperm(length(spec.lower_bounds))
    random_perm = [2, 4, 1, 3, 5, 6, 7, 8]
    variables_to_reduce = random_perm[1 : num_of_equalities]
    remaining_variables = random_perm[num_of_equalities+1 : end]
    sort!(variables_to_reduce)

    return variables_to_reduce, remaining_variables
end

function convert_no_equalities_spec_into_internal{T <: FloatingPoint}(spec::GenocopSpecification{T})
    variables_to_reduce = Int[]
    no_of_variables = length(lower_bounds)
    A1inv_b = T[]
    A1inv_A2 = T[]

    return InternalSpec(spec.evaluation_function,
                        variables_to_reduce,
                        spec.inequalities,
                        spec.inequalities_lower,
                        spec.inequalities_upper,
                        spec.lower_bounds,
                        spec.upper_bounds,
                        spec.population_size,
                        spec.max_iterations,
                        spec.operator_mapping,
                        spec.cumulative_prob_coeff,
                        spec.minmax,
                        spec.starting_population_type,
                        no_of_variables,
                        A1inv_b,
                        A1inv_A2)
end
