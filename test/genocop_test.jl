
custom_suite("genocop tests")

#equalities = Float64[2.0 1.0 0.0 -3.5]
#equalities_right = Float64[1.0]

#inequalities = Float64[3.0 1.0 1.0 4.0;
#                1.0 -2.0 -7.0 2.0]
#inequalities_right = Float64[33.3, 10.0]

#lower_bounds = Float64[1.0, -10.0, -2.1, 0.0]
#upper_bounds = Float64[28.0, 8.0, 13.1, 43.4]

#spec = GenocopSpec(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
#upper_bounds; starting_population_type=single_point_start_pop)

#eval_func = function(arg::Vector{Float64})
#                return arg[1] + 2*arg[2] + 3*arg[3] + 4*arg[4]
#            end

#custom_test("genocop shouldReturnNothing") do
#    genocop(spec, eval_func) == nothing
#end





equalities = Float64[1.0 1.0 -1.0;
                    -1.0 1.0 -1.0;
                    12.0 5.0 12.0;
                    12.0 12.0 7.0
                    -6.0 1.0 1.0]
equalities_right = Float64[1.0, -1.0, 34.8, 29.1, -4.1]

inequalities = Float64[1.0 1.0 -1.0;
                        -1.0 1.0 -1.0;
                        12.0 5.0 12.0;
                        12.0 12.0 7.0
                        -6.0 1.0 1.0]
inequalities_right = Float64[1.0, -1.0, 34.8, 29.1, -4.1]

lower_bounds = Float64[0.0, 0.0, 0.0]
upper_bounds = Float64[4.0, 4.0, 4.0]

spec = GenocopSpec(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
upper_bounds; starting_population_type=multi_point_start_pop, minmax = maximization)

eval_func = function(arg::Vector{Float64})
                return (arg[1] + 10.0*arg[2])*(arg[1] + 10.0*arg[2]) +
                              5.0*(arg[3])*(arg[3]) + (arg[2] - 2.0*arg[3])*(arg[2] -
                              2.0*arg[3])*(arg[2] - 2.0*arg[3])*(arg[2] - 2.0*arg[3]) + 10.0*(arg[1])*(arg[1])*(arg[1])*(arg[1])
            end

custom_test("genocop shouldReturnNothing") do
    genocop(spec, eval_func) == nothing
end






#equalities = Float32[1.0 1.0 -1.0;
#                    -1.0 1.0 -1.0;
#                    12.0 5.0 12.0;
#                    12.0 12.0 7.0
#                    -6.0 1.0 1.0]
#equalities_right = Float32[1.0, -1.0, 34.8, 29.1, -4.1]

#inequalities = Float32[1.0 1.0 -1.0;
#                        -1.0 1.0 -1.0;
#                        12.0 5.0 12.0;
#                        12.0 12.0 7.0
#                        -6.0 1.0 1.0]
#inequalities_right = Float32[1.0, -1.0, 34.8, 29.1, -4.1]

#lower_bounds = Float32[0.0, 0.0, 0.0]
#upper_bounds = Float32[4.0, 4.0, 4.0]

#spec = GenocopSpec(equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
#upper_bounds; starting_population_type=multi_point_start_pop, minmax = maximization)

#eval_func = function(arg::Vector{Float32})
#                return (arg[1] + 10.0*arg[2])*(arg[1] + 10.0*arg[2]) +
#                              5.0*(arg[3])*(arg[3]) + (arg[2] - 2.0*arg[3])*(arg[2] -
#                              2.0*arg[3])*(arg[2] - 2.0*arg[3])*(arg[2] - 2.0*arg[3]) + 10.0*(arg[1])*(arg[1])*(arg[1])*(arg[1])
#            end

#custom_test("genocop shouldReturnNothing") do
#    genocop(spec, eval_func) == nothing
#end
