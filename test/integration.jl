
custom_suite("Integration Test")


#equalities = Float64[]
#equalities_right = Float64[]

#inequalities = Float64[1.0 1.0 -1.0;
#                        -1.0 1.0 -1.0;
#                        12.0 5.0 12.0;
#                        12.0 12.0 7.0
#                        -6.0 1.0 1.0]
#inequalities_right = Float64[1.0, -1.0, 34.8, 29.1, -4.1]

#lower_bounds = Float64[0.0, 0.0, 0.0]
#upper_bounds = Float64[4.0, 4.0, 4.0]

#eval_func = function(arg::Vector{Float64})
#                return (arg[1] + 10.0*arg[2])*(arg[1] + 10.0*arg[2]) +
#                              5.0*(arg[3])*(arg[3]) + (arg[2] - 2.0*arg[3])*(arg[2] -
#                              2.0*arg[3])*(arg[2] - 2.0*arg[3])*(arg[2] - 2.0*arg[3]) + 10.0*(arg[1])*(arg[1])*(arg[1])*(arg[1])
#            end


#spec = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
#upper_bounds; starting_population_type=multi_point_start_pop, minmax = maximization)


#custom_test("genocop integration test") do
#    genocop(spec)
#end




equalities = Float64[1.0    2.0   0.0    0.0   0.0   0.0   0.0   2.0;
                    0.0    0.0   1.0    1.0   0.0   0.0   0.0   0.0]
equalities_right = Float64[12.0, 5.0]

inequalities = Float64[1.0    0.0   0.0    1.0   0.0   1.0  1.0   2.0;
                        0.0    0.0   1.0    0.0   1.0   1.0  2.0   0.0;
                        0.0    1.0   0.0    1.0   1.0   2.0  0.0   0.0]
inequalities_right = Float64[20.0, 25.0, 11.0]

lower_bounds = Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
upper_bounds = Float64[8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0]

eval_func = function(arg::Vector{Float64})
                return (arg[1] + arg[2] + arg[3] + arg[4] + arg[5] + arg[6] + arg[7] + arg[8])
            end


spec = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds,
upper_bounds; starting_population_type=multi_point_start_pop, minmax = maximization)


custom_test("genocop integration test") do
    genocop(spec)
end


