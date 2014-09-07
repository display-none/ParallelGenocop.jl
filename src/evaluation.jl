
function evaluate!{T <: FloatingPoint}(individual::Individual{T}, spec::GenocopSpec{T}, evaluation_func::Function)
    chromosome = individual.chromosome
    try
        ev = evaluation_function(chromosome)
        individual.evaluation = ev
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
