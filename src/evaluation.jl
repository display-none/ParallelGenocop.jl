
function evaluate_population!{T <: FloatingPoint}(population::Vector{Individual{T}}, spec::InternalSpec{T})
    @debug "evaluating population"
    for individual in population
        if individual.fitness == nothing
            evaluate!(individual, spec)
        end
    end
end

function evaluate!{T <: FloatingPoint}(individual::Individual{T}, spec::InternalSpec{T})
    chromosome = individual.chromosome
    extended_chromosome = extend_with_reduced_variables(chromosome, spec)
    ev::T = call_evaluation_function(extended_chromosome, spec.evaluation_function)
    individual.fitness = ev
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

    x1_iter = start(x1)
    x2_iter = start(x2)

    total_length = length(x1) + length(x2)

    new_chromosome = Array(T, total_length)

    for i in 1:total_length
        if reduced_variables_index <= reduced_variables_length && i == reduced_variables[reduced_variables_index]
            (value, x1_iter) = next(x1, x1_iter)
            new_chromosome[i] = value
            reduced_variables_index += 1
        else
            (value, x2_iter) = next(x2, x2_iter)
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
            @error "Julia couldn't find the method to accept one Vector{$T} argument while calling evaluation function. Check what you supplied"
        else
            @error "The evaluation function you provided threw an exception"
        end
        rethrow(ex)
    end
end
