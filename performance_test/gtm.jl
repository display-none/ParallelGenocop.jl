@everywhere using ParallelGenocop
@everywhere @Logging.configure(level=ERROR)



function test()
###
println("gtm.gms : International Gas Trade Model - Gams models")


@everywhere begin

blas_set_num_threads(16)

lower_bounds = Float64[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2.2,0.2,1.47,1.38,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2]
upper_bounds = Float64[Inf,0.067,0.067,0.067,0.067,0.033,Inf,Inf,0.3,0.15,0.1,Inf,Inf,Inf,Inf,Inf,Inf,Inf,0.34,0.35,Inf,1.39,1.06,2,2.62,3.73,0.62,2.3,1.03,0.12,1.45,1.46,0.48,0.14,Inf,0.1,Inf,0.48,0.8,2.475,3.7125,0.297,0.7128,9.6525,2.5245,1.7028,1.4256,0.5148,99,2.2,0.2,1.47,1.38,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf]

equalities = Array(Float64, 0, 0)
equalities_right = Array(Float64, 0)

inequalities = Float64[1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	1	1	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	1	1	1	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0;
0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	-1	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0;
0	-1	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0;
0	0	-1	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	-1	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0;
0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0;
0	0	0	0	-1	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	-1	0	0	0	0	-1	0	-1	0	0	-1	0	0	-1	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	-1	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0;
0	0	0	0	0	-1	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	-1	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0;
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1;
]
inequalities_right = Float64[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

starting_point = Float64[2.21,0.03,0.06,0.06,0.06,0.03,1.471,1.381,0.2,0.1,0.05,0.01,0.01,0.01,0.01,0.01,0.21,0.01,0.2,0.1,0.2,0.8,0.8,1,1,1,0.3,1,0.7,0.1,0.6,0.7,0.3,0.1,0.2,0.05,0.2,0.3,0.6,2.47,3.5,0.24,0.4,6,2.2,1.6,1.1,0.4,4,2.2,0.2,1.47,1.38,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2]

eval_func = function(X::Vector{Float64})
                return -(- (-4.84*X[50]^(-1) - 0.14*X[51]^(-1) - 6.4827*X[52]^(-1) - 6.6654*X[53]^(-1) - 8.89583741831423*X[54]^(-0.666666666666667) - 20.7788808225955*X[55]^(-0.515151515151515) - 12.8222379289592*X[56]^(-0.538461538461538) - 112.274462577384*X[57]^(-0.123595505617978) - 78.984522912416*X[58]^(-0.538461538461538) - 325.606233858943*X[59]^(-0.19047619047619) - 19.9925533406708*X[60]^(-0.492537313432836) - 20.2959676146409*X[61]^(-0.851851851851852) - 34.6492709112034*X[62]^(-1.32558139534884) - 2.07326743881507*X[63]^(-0.754385964912281) - (0.0372*X[44] - 6.47537234042553*log(1 - 0.102564102564103*X[44]) - 0.489999999999999*log(1 - 1.38888888888889*X[43]) - 1.68*log(1 - 0.392156862745098*X[45]) + (-1.2271875*log(1 - 0.581395348837209*X[46])) - 0.2187*X[46] - 0.979999999999999*log(1 - 0.694444444444444*X[47]) - 0.35*log(1 - 1.92307692307692*X[48]))) + 0.25*X[1] + 2.29*X[2] + 2.22*X[3] + 2.03*X[4] + 1.96*X[5] + 2.13*X[6] + 0.4*X[7] + 0.9*X[8] + 1.15*X[9] + 1.1*X[10] + 1.1*X[11] + 0.8*X[12] + 0.8*X[13] + 0.65*X[14] + 0.7*X[15] + 0.65*X[16] + 1.5*X[18] + 0.72*X[19] + 0.46*X[20] + 2.12*X[21] + 1.08*X[22] + 1.01*X[23] + 0.82*X[24] + 0.75*X[25] + 0.04*X[26] + 0.86*X[27] + 0.14*X[28] + 0.64*X[29] + 0.77*X[30] + 0.05*X[31] + 0.94*X[32] + 0.53*X[33] + 0.31*X[34] + 0.58*X[35] + 0.7*X[36] + 1.91*X[37] + 0.43*X[38] + 6*X[39] + 2*X[49])
            end

operators = (Operator=>Integer)[UniformMutation() => 20,
                                BoundaryMutation() => 20,
                                NonUniformMutation() => 20,
                                WholeNonUniformMutation() => 20,
                                ArithmeticalCrossover() => 20,
                                SimpleCrossover() => 20,
                                HeuristicCrossover() => 20]


spec_dummy = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 3,
                        starting_population_type=single_point_start_pop, minmax = maximization, starting_point=starting_point)
end
spec = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 6000, cumulative_prob_coeff = 0.018,
                        starting_population_type=single_point_start_pop, operator_mapping=operators, population_size=400, minmax = maximization, starting_point=starting_point)

genocop(spec_dummy)
best = @time genocop(spec)
println("best: $best")
best_eval = eval_func(best)
println("best fitness: $best_eval")


# @profile genocop(spec_dummy)

# Profile.clear()
# Profile.init(10^7, 0.001)
# @profile (genocop(spec))
# using ProfileView
# ProfileView.view()

# readline(STDIN)


print("\n\n\n")

end

test()