
function reduce_equalities{T <: FloatingPoint}(spec::GenocopSpecification{T})
    num_of_equalities = length(spec.equalities_right)

    if num_of_equalities == 0
        return convert_no_equalities_spec_into_internal(spec)
    end

    permutation_vector, R1inv_c, R1inv_R2 = qr_factorize(spec)

    internal_spec = reduce_and_create_spec(permutation_vector, R1inv_c, R1inv_R2, spec)
    @info "$(length(R1inv_c)) variables were reduced"
    return internal_spec
end


# my naming is as follows: R1 := R11, R2 := [R12 R13]
function qr_factorize{T <: FloatingPoint}(spec::GenocopSpecification{T})
    A = spec.equalities
    b = spec.equalities_right

    qr = qrfact(A, pivot=true)
    k = determine_rank(qr[:R], A)

    c = At_mul_B(full(qr[:Q]), b)

    verify_consistency(c, b, k)

    R1inv = inv(qr[:R][1:k, 1:k])
    R2 = qr[:R][1:k, k+1:end]

    R1inv_c = R1inv * c[1:k]
    R1inv_R2 = R1inv * R2

    return qr[:p], R1inv_c, R1inv_R2
end


function determine_rank{T <: FloatingPoint}(R::Matrix{T}, A::Matrix{T})
    norm_A = norm(A, Inf)
    tau = eps(T)*norm_A
    k = 0
    rows = size(R, 1)
    cols = size(R, 2)
    while k < rows && k < cols
        if abs(R[k+1, k+1]) < tau
            break
        end
        k += 1
    end
    @info "rank $k"
    return k
end

function verify_consistency{T <: FloatingPoint}(c::Vector{T}, b::Vector{T}, k::Int)
    if k == length(c)
        return
    end

    if norm(c[k+1:end], 2) > eps(T)*norm(b, 2)
        error("The equations are not consistent. No solution exists")
    end
end 

# due to quite complex math done here it's hard to divide this code into smaller methods, it's all kinda connected
# I'll try to do some heavy commenting so that it's understandable

# all that is done here is nicely described in section 7.1 of Evolution Programs by Zbigniew Michalewicz
# variable names are mostly meaningless since they reference the names in the book

# we get:
#   the permutation vector indicating which variables will be reduced
#   the inverse of R1 multiplied by c
#   the inverse of R1 multiplied by R2
function reduce_and_create_spec{T <: FloatingPoint}(permutation_vector::Vector, R1inv_c::Vector{T}, R1inv_R2::Matrix{T}, spec::GenocopSpecification{T})

    num_of_equalities = length(R1inv_c)

    variables_to_reduce, remaining_variables = permutation_vector[1 : num_of_equalities], permutation_vector[num_of_equalities+1 : end]

    # original inequalities get divided into W1 and W2
    num_of_inequalities = length(spec.inequalities_lower)
    W1 = getindex(spec.inequalities, 1:num_of_inequalities, variables_to_reduce)
    W2 = getindex(spec.inequalities, 1:num_of_inequalities, remaining_variables)
    # new inequalities computed (math behind this is in the thesis)
    new_inequalities = W2 - W1 * R1inv_R2

    # to complete the inequalities reduction we subtract W1_R1inv_c (math in the thesis)
    W1_R1inv_c = W1 * R1inv_c
    new_inequalities_lower = spec.inequalities_lower - W1_R1inv_c
    new_inequalities_upper = spec.inequalities_upper - W1_R1inv_c

    # upper and lower bounds for variables are separated
    lower_bounds_reduce = getindex(spec.lower_bounds, variables_to_reduce)
    new_lower_bounds = getindex(spec.lower_bounds, remaining_variables)

    upper_bounds_reduce = getindex(spec.upper_bounds, variables_to_reduce)
    new_upper_bounds = getindex(spec.upper_bounds, remaining_variables)

    # the reduced variables are additionally bounded by upper and lower bounds so we convert these into inequalities
    new_inequalities = vcat(new_inequalities, -R1inv_R2)
    append!(new_inequalities_lower, lower_bounds_reduce - R1inv_c)
    append!(new_inequalities_upper, upper_bounds_reduce - R1inv_c)

    # now the number of variables the algorithm is going to work on is smaller
    no_of_variables = length(new_lower_bounds)

    # packing it all into the spec and voila
    return InternalSpec(spec.evaluation_function,
                        permutation_vector,
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
                        spec.starting_point,
                        spec.epsilon,
                        no_of_variables,
                        R1inv_c,
                        R1inv_R2)
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
    no_of_variables = length(spec.lower_bounds)
    permutation_vector = Int[i for i=1:no_of_variables]
    R1inv_c = Array(T, 0)
    R1inv_R2 = Array(T, 0, 0)

    return InternalSpec(spec.evaluation_function,
                        permutation_vector,
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
                        spec.starting_point,
                        spec.epsilon,
                        no_of_variables,
                        R1inv_c,
                        R1inv_R2)
end
