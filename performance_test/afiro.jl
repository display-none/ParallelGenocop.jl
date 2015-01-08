@everywhere using ParallelGenocop
@everywhere @Logging.configure(level=INFO)



function test()
###
println("afiro - netlib lp")


@everywhere begin
lower_bounds = Float32[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
upper_bounds = Float32[Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf]


equalities = readdlm("afiro_eq", Float32)
equalities_right = Float32[0, 0, 0, 0, 0, 0, 0, 44.]

# equalities = Array(Float64, 0, 0)
# equalities_right = Array(Float64, 0)

inequalities = readdlm("afiro_ineq", Float32)
inequalities_right = Float32[80., 0, 80., 0, 0, 0, 500., 0, 500., 0, 0, 0, 0, 0, 0, 0, 0, 310., 300.]


starting_point = Float32[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44]

eval_func = function(X::Vector{Float32})
                return -.4*X[2]-.32*X[13]-.6*X[17]-.48*X[29]+10.*X[32]
            end

operators = Dict{Operator,Integer}(UniformMutation() => 20,
                                BoundaryMutation() => 20,
                                NonUniformMutation() => 20,
                                WholeNonUniformMutation() => 20,
                                ArithmeticalCrossover() => 20,
                                SimpleCrossover() => 20,
                                HeuristicCrossover() => 20)


spec_dummy = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 3,
                        starting_population_type=single_point_start_pop, minmax = minimization, starting_point = starting_point, epsilon = 1e-5)
end
spec = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 6000,
                        starting_population_type=single_point_start_pop, operator_mapping=operators, population_size=320, minmax = minimization, starting_point = starting_point, epsilon = 1e-5)

#genocop(spec_dummy)
best = @time genocop(spec)
#println("best: $best")
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