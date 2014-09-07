
custom_suite("genocop tests")

equalities = Float64[2.0 1.0 0.0 -3.5]
equalities_right = Float64[1.0]

inequalities = Float64[0.0 1.0 1.0 0.0;
                1.0 -2.0 0.0 0.0]
inequalities_right = Float64[3.0, 0.0]

lower_bounds = Float64[1.0, 0.0, -2.1, 0.0]
upper_bounds = Float64[8.0, 8.0, 3.1, 4.4]

spec = GenocopSpec(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
upper_bounds; starting_population_type=single_point_start_pop)

eval_func = function(arg::Float64)
                return 40
            end

custom_test("genocop shouldReturnNothing") do
    genocop(spec, eval_func) == nothing
end
