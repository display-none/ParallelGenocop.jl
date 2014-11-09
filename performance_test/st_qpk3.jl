using ParallelGenocop
@everywhere @Logging.configure(level=ERROR)



###
println("st_qpk3.gms - Gams World")

@everywhere using ParallelGenocop

@everywhere begin
lower_bounds = Float64[0 for i=1:11]
upper_bounds = Float64[10 for i=1:11]

equalities = Array(Float64, 0, 0)
equalities_right = Array(Float64, 0)

inequalities = Float64[-1  -2  -3  -4	-5	-6	-7	-8	-9	-10	-11;
                       -2  -3  -4	-5	-6	-7	-8	-9	-10	-11  -1;
                       -3  -4	-5	-6	-7	-8	-9	-10	-11  -1  -2;
                       -4	-5	-6	-7	-8	-9	-10	-11  -1  -2  -3;
                       -5	-6	-7	-8	-9	-10	-11  -1  -2  -3  -4;
                       -6	-7	-8	-9	-10	-11  -1  -2  -3  -4	-5;
                       -7	-8	-9	-10	-11  -1  -2  -3  -4	-5	-6;
                       -8	-9	-10	-11  -1  -2  -3  -4	-5	-6	-7;
                       -9	-10	-11  -1  -2  -3  -4	-5	-6	-7	-8;
                       -10	-11  -1  -2  -3  -4	-5	-6	-7	-8	-9;
                       -11  -1  -2  -3  -4	-5	-6	-7	-8	-9	-10;
                       1  2  3  4	5	6	7	8	9	10	11;
                       2  3  4	5	6	7	8	9	10	11  1;
                       3  4	5	6	7	8	9	10	11  1  2;
                       4	5	6	7	8	9	10	11  1  2  3;
                       5	6	7	8	9	10	11  1  2  3  4;
                       6	7	8	9	10	11  1  2  3  4	5;
                       7	8	9	10	11  1  2  3  4	5	6;
                       8	9	10	11  1  2  3  4	5	6	7;
                       9	10	11  1  2  3  4	5	6	7	8;
                       10	11  1  2  3  4	5	6	7	8	9;
                       11  1  2  3  4	5	6	7	8	9	10;
                       ]

inequalities_right = [Float64[0 for i=1:11];Float64[66 for i=1:11]]

starting_point = Float64[0.1 for i=1:11]

eval_func = function(X::Vector{Float64})
                return 0.5*X[1]*X[2] - X[1]*X[1] + 0.5*X[2]*X[1] - X[2]*X[2] + 0.5*X[2]*X[3] + 0.5*X[3]*X[2] - X[3]*X[3] + 0.5*X[3]*X[4] + 0.5*X[4]*X[3] - X[4]*X[4] + 0.5*X[4]*X[5] + 0.5*X[5]*X[4] - X[5]*X[5] + 0.5*X[5] *X[6] + 0.5*X[6]*X[5] - X[6]*X[6] + 0.5*X[6]*X[7] + 0.5*X[7]*X[6] - X[7]*X[7] + 0.5*X[7]*X[8] + 0.5 *X[8]*X[7] - X[8]*X[8] + 0.5*X[8]*X[9] + 0.5*X[9]*X[8] - X[9]*X[9] + 0.5*X[9]*X[10] + 0.5*X[10]*X[9] - X[10]*X[10] + 0.5*X[10]*X[11] + 0.5*X[11]*X[10] - X[11]*X[11]
            end

operators = (Operator=>Integer)[UniformMutation() => 7,
                                BoundaryMutation() => 7,
                                NonUniformMutation() => 7,
                                WholeNonUniformMutation() => 7,
                                ArithmeticalCrossover() => 7,
                                SimpleCrossover() => 7,
                                HeuristicCrossover() => 7]


spec_dummy = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 3,
                        starting_population_type=single_point_start_pop, minmax = minimization, starting_point=starting_point)
end
spec = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 4000,
                        starting_population_type=single_point_start_pop, operator_mapping=operators, population_size=130, minmax = minimization, starting_point=starting_point)

@sync @everywhere genocop(spec_dummy)
best = @time genocop(spec)
println("best: $best")
best_eval = eval_func(best)
println("best fitness: $best_eval")


#@profile genocop(spec)

#Profile.clear()
#Profile.init(10^9, 0.001)
#@profile (for i=1:5; genocop(spec); end)
#using ProfileView
#ProfileView.view()

#readline(STDIN)


print("\n\n\n")
