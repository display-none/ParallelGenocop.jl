
# GenocopSpec for specification of the problem and parameters

immutable type GenocopSpec{T <: FloatingPoint}
    equalities::Matrix{T}
    equalities_right::Vector{T}
    inequalities::Matrix{T}
    inequalities_right::Vector{T}
    lower_bounds::Vector{T}
    upper_bounds::Vector{T}
    population_size::Integer
    max_iterations::Integer
    operator_frequency::Vector{Integer}
    cumulative_prob_coeff::FloatingPoint
    minmax::MinMaxType
    starting_population_type::StartPopType

    no_of_variables::Int

    function GenocopSpec{T}(equalities::Matrix{T},
        equalities_right::Vector{T},
        inequalities::Matrix{T},
        inequalities_right::Vector{T},
        lower_bounds::Vector{T},
        upper_bounds::Vector{T},
        population_size::Integer,
        max_iterations::Integer,
        operator_frequency::Vector{Integer},
        cumulative_prob_coeff::FloatingPoint,
        minmax::MinMaxType,
        starting_population_type::StartPopType)

        verify_dimensions_rows(equalities, equalities_right, "dimensions of equalities and its right hand side do not match")
        verify_dimensions_rows(inequalities, inequalities_right, "dimensions of inequalities and its right hand side do not match")
        verify_dimensions_columns(equalities, lower_bounds, "dimensions of equalities and lower bounds do not match")
        verify_dimensions_columns(inequalities, upper_bounds, "dimensions of inequalities and upper bounds do not match")
        verify_same_size(lower_bounds, upper_bounds)
        @assert population_size > 0 "population size must be a positive integer"
        @assert max_iterations > 0 "max iterations must be a positive integer"
        @assert size(operator_frequency, 1) == 7 "operator frequency must specify exactly 7 integers"
        @assert sum(operator_frequency) <= population_size "sum of all parents needed for reproduction cannot exceed population size"

        if sum(operator_frequency) > population_size/2
            @warn "sum of all parents needed for reproduction should not exceed half of population size"
        end

        no_of_variables = length(lower_bounds)

        new(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
                upper_bounds, population_size, max_iterations, operator_frequency,
                cumulative_prob_coeff, minmax, starting_population_type, no_of_variables)
    end
end


function GenocopSpec{T <: FloatingPoint}(
        equalities::Matrix{T},
        equalities_right::Vector{T},
        inequalities::Matrix{T},
        inequalities_right::Vector{T},
        lower_bounds::Vector{T},
        upper_bounds::Vector{T};
        population_size::Integer=_default_population_size,
        max_iterations::Integer=_default_max_iter,
        operator_frequency::Vector{Integer}=_default_operator_frequency,
        cumulative_prob_coeff::FloatingPoint=_default_cumulative_prob_coeff,
        minmax::MinMaxType=_default_minmax_type,
        starting_population_type::StartPopType=_default_starting_population)

        GenocopSpec{T}(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
                            upper_bounds, population_size, max_iterations, operator_frequency,
                            cumulative_prob_coeff, minmax, starting_population_type)
end


# Individual type to store an individual

type Individual{T <: FloatingPoint}
   chromosome::Vector{T}


end

