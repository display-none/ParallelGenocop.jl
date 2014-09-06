
function initialize_population{T <: FloatingPoint}(spec::GenocopSpec{T})

end


function get_feasible_individual{T <: FloatingPoint}(spec::GenocopSpec{T})

    lower_bounds = spec.lower_bounds
    upper_bounds = spec.upper_bounds

    for i = 1:_population_initialization_tries

        random_individual = get_random_individual_within_bounds(spec)
    end

end

function get_random_individual_within_bounds{T <: FloatingPoint}(spec::GenocopSpec{T})
    chromosome = Array(T, spec.no_of_variables)
    for i in 1:spec.no_of_variables
        low = spec.lower_bounds[i]
        upp = spec.upper_bounds[i]
        chromosome[i] = get_random_float(low, upp)
    end

    @debug "generated a random individual: $chromosome"
    return Individual{T}(chromosome)
end

function is_feasible{T <: FloatingPoint}(individual::Individual{T}, spec::GenocopSpec{T})
    ineq = spec.inequalities
    ineq_right = spec.inequalities_right
    chromosome = individual.chromosome
    for i in 1:size(ineq, 2)
        value = evaluate_row(ineq, chromosome, i)

        if value > ineq_right[i]
            return false
        end
    end
    return true
end
