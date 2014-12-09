
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

    if length(spec.permutation_vector) == 0
        return chromosome
    end

    # @info "chromosome: $chromosome"

    x1 = spec.R1inv_c - spec.R1inv_R2 * chromosome
    x2 = chromosome

    new_chromosome = Array(T, length(x1) + length(x2))
    new_chromosome[spec.permutation_vector] = [x1;x2]

    # @info "new: $new_chromosome"
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
