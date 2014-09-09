
function optimize!{T <: FloatingPoint}(population::Vector{Individual{T}}, spec::GenocopSpec{T}, evaluate_func::Function)

    probabilities = compute_probabilities!(population)
    cumulative_probabilities = cumsum(probabilities)

    for i = 1:spec.max_iterations

    end
end


function compute_probabilities!{T <: FloatingPoint}(population::Vector{Individual{T}})
    probabilities = Array(Float64, length(population))
    total_fitness = sum((ind -> ind.fitness), population)
    for i in 1:length(population)
        probabilities[i] = population[i].fitness / total_fitness
    end
    return probabilities
end
