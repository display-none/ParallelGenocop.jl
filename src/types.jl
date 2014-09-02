
# GenocopSpec for specification of the problem and parameters

type GenocopSpec{T <: FloatingPoint}
    equalities::Matrix{T}
    equalities_right::Vector{T}
    inqualities::Matrix{T}
    inequalities_right::Vector{T}
    lower_bounds::Vector{T}
    upper_bounds::Vector{T}
    population_size::Integer
    max_iterations::Integer
    operator_frequency::Vector{FloatingPoint}
    cumulative_prob_coeff::FloatingPoint
    minmax::MinMaxType
    starting_population_type::StartPopType

    function GenocopSpec(equalities::Matrix{T},
        equalities_right::Vector{T},
        inequalities::Matrix{T},
        inequalities_right::Vector{T},
        lower_bounds::Vector{T},
        upper_bounds::Vector{T},
        population_size::Integer,
        max_iterations::Integer,
        operator_frequency::Vector{FloatingPoint},
        cumulative_prob_coeff::FloatingPoint,
        minmax::MinMaxType,
        starting_population_type::StartPopType)

        verifydimensions(equalities, equalities_right)
        verifydimensions(inequalities, inequalities_right)

        new(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
                upper_bounds, population_size, max_iterations, operator_frequency,
                cumulative_prob_coeff, minmax, starting_population_type)
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
        operator_frequency::Vector{FloatingPoint}=_default_operator_frequency,
        cumulative_prob_coeff::FloatingPoint=_default_cumulative_prob_coeff,
        minmax::MinMaxType=_default_minmax_type,
        starting_population_type::StartPopType=_default_starting_population)

        GenocopSpec{T}(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
                            upper_bounds, population_size, max_iterations, operator_frequency,
                            cumulative_prob_coeff, minmax, starting_population_type)
end
