
function evaluate_population!{T <: FloatingPoint}(population::Vector{Individual{T}}, evaluation_func::Function)
    @debug "evaluating population"
    for individual in population
        if individual.fitness == nothing
            evaluate!(individual, evaluation_func)
        end
    end
end

function evaluate!{T <: FloatingPoint}(individual::Individual{T}, evaluation_func::Function)
    chromosome = individual.chromosome
    try
        ev::T = evaluation_func(chromosome)
        individual.fitness = ev
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
