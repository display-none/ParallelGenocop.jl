
function evaluate_population!{T <: FloatingPoint}(population::Vector{Individual{T}}, evaluation_func::Function)
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
        if isa(ex, TypeError)
            @error "The evaluation function you provided threw a TypeError, check the function signature. (the function should take one Vector{$T} argument)"
        else
            @error "The evaluation function you provided threw an exception"
        end
        rethrow(ex)
    end
end
