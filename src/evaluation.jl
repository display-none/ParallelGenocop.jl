
function evaluate_and_return_fitness{T <: FloatingPoint}(individual::Individual, spec::InternalSpec{T})
    extended = extend_with_reduced_variables(individual, spec)
    ev::T = call_evaluation_function(extended, spec.evaluation_function)
    return ev
end

function evaluate_and_return_fitness{T <: FloatingPoint}(chromosome::Vector{T}, spec::InternalSpec{T})
    extended_chromosome = extend_with_reduced_variables(chromosome, spec)
    ev::T = call_evaluation_function(extended_chromosome, spec.evaluation_function)
    return ev
end

function extend_with_reduced_variables{T <: FloatingPoint}(individual::Individual, spec::InternalSpec{T})
    extend_with_reduced_variables(get_chromosome(individual), spec)
end

function extend_with_reduced_variables{T <: FloatingPoint}(chromosome::Vector{T}, spec::InternalSpec{T})

    if length(spec.removed_variables_indices) == 0
        return chromosome
    end

    reduced_variables = spec.removed_variables_indices
    reduced_variables_index = 1
    reduced_variables_length = length(reduced_variables)

    x1 = spec.A1inv_b - spec.A1inv_A2 * chromosome
    x2 = chromosome

    x1_iter = 1
    x2_iter = 1

    total_length = length(x1) + length(x2)

    new_chromosome = Array(T, total_length)

    for i in 1:total_length
        if reduced_variables_index <= reduced_variables_length && i == reduced_variables[reduced_variables_index]
            value = x1[x1_iter]
            x1_iter += 1
            new_chromosome[i] = value
            reduced_variables_index += 1
        else
            value = x2[x2_iter]
            x2_iter += 1
            new_chromosome[i] = value
        end
    end

    return new_chromosome
end

function call_evaluation_function{T <: FloatingPoint}(chromosome::Vector{T}, evaluation_func::Function)
    try
        return evaluation_func(chromosome)
    catch ex
        @error "evaluation of individual $chromosome failed"
        if isa(ex, MethodError)
            @error "Julia couldn't find the method to accept one argument while calling evaluation function. Check what you supplied"
        else
            @error "The evaluation function you provided threw an exception"
        end
        rethrow(ex)
    end
end
