
equalities = [2.0 1.0 0.0 -3.5]
equalities_right = [1.0]

inequalities = [0.0 1.0 1.0 0.0;
                1.0 -2.0 0.0 0.0]
inequalities_right = [3.0, 0.0]

lower_bounds = [1.0, 0.0, -2.1, 0.0]
upper_bounds = [8.0, 8.0, 3.1, 4.4]

const _default_population_size=70
const _default_max_iter=500
const _default_operator_frequency=FloatingPoint[0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
const _default_cumulative_prob_coeff=0.1
const _default_minmax_type=Min
const _default_starting_population=RandomStartPop


spec = GenocopSpec(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
upper_bounds)


begin #genocop shouldReturnNothing
    @test genocop(spec) == nothing
end
