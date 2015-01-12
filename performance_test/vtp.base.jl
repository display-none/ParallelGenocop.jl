@everywhere using ParallelGenocop
@everywhere @Logging.configure(level=INFO)


function test()
###
println("vtp.base - netlib lp")
## cond 750548.6188318386

@everywhere begin

function loosen_it(plus_minus, parameter, vector)
	result = similar(vector)
	for i=1:length(vector)
		if abs(vector[i]) < 1
			result[i] = plus_minus(vector[i], parameter)
		else
			result[i] = plus_minus(vector[i], abs(vector[i])*parameter)
		end
	end
	return result
end

blas_set_num_threads(16)

lower_bounds = Float64[0,0,-Inf,0,0,0,0,0.,0.,0.,1.,1300.,600.,110.,900.,300.,100.,100.,100.,300.,100.,100.,100.,300.,100.,100.,100.,300.,100.,100.,100.,300.,100.,100.,100.,300.,100.,100.,100.,300.,100.,100.,100.,300.,100.,100.,100.,-300.,-100.,-100.,-100.,-300.,-100.,-100.,-100.,-300.,-100.,-100.,-100.,-300.,-100.,-100.,-100.,-300.,-100.,-100.,-100.,-300.,-100.,-100.,-100.,-300.,-100.,-100.,-100.,-300.,-100.,-100.,-100.,0.,0,0,0,0,0,0,0,180.,0,0,0,0,0,0,0,0,1.,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.,0,0,0,0,0,0,0,0,0,0,0,1.,0,0,0,0,0,0,0,0,1.,0,0,0,0,0,0,0,0,0,0,1.,0,0,0,0,0,1.,0,0,0,0,0,0,0,0,0,0,1.,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.,0,0]
upper_bounds = Float64[Inf,Inf,Inf,Inf,Inf,Inf,1.,0.,0.,0.,1.,1300.,600.,110.,900.,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,Inf,Inf,Inf,Inf,Inf,Inf,Inf,180.,1.,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf,1.,Inf,Inf]

equalities = readdlm("vtp.base_eq", Float64)
equalities_right = Float64[0,0,0,0,0,0,0,0,0,0,1.,0,0,0,0,0,1.,0,0,0,0,0,1.,0,0,0,0,0,1.,0,0,0,0,0,1.,0,0,0,0,0,1.,0,0,0,0,0,1.,0,0,0,0,0,1.,0,1.]

inequalities = readdlm("vtp.base_ineq", Float64)
inequalities_right = Float64[0,0,0,0,4000.,0,0,0,280.,4000.,0,0,0,280.,4000.,0,0,0,280.,4000.,0,0,0,280.,4000.,0,0,0,280.,4000.,-771.28205,-315.64103,-337.30769,-346.66667,-261.11111,-375.55556,0,0,4000.,0,0,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,-251.28205,-207.30769,-337.94872,0,0,4000.,0,0,0,0,0,0,4000.,0,0,0,4000.,0,0,0,4000.,0,0,0,4000.,0,0,0,4000.,0,0,0,4000.,-202.22222,0,0,0,4000.,0,0,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.,0,0,4000.]

param = 1e-4
lower_bounds = loosen_it(-, param, lower_bounds)
upper_bounds = loosen_it(+, param, upper_bounds)
inequalities_right = loosen_it(+, param, inequalities_right)

starting_point = Float64[128601.094772, 266250.0, 6842.127556, 0, 0, 21500.0, 0, 0, 0, 0, 1.0, 1300.0, 600.0, 110.0, 900.0, 1333.269231, 353.25, 1226.923077, 679.923077, 1274.371381, 804.432796, 1079.678453, 609.245658, 1124.154024, 609.150231, 704.13506, 1760.984517, 2765.732191, 295.0, 100.0, 1470.999688, 2615.732191, 100.0, 650.0, 1290.999688, 2483.232191, 1140.0, 318.75, 1131.999688, 1883.232191, 360.0, 2368.75, 411.999688, 1383.232191, 100.0, 1868.75, 171.999688, -300.0, -100.0, -100.0, -100.0, -300.0, -100.0, -100.0, -100.0, -300.0, -100.0, -100.0, -100.0, -300.0, -100.0, -100.0, -100.0, -300.0, -100.0, -100.0, -100.0, -300.0, -100.0, -100.0, -100.0, -300.0, -100.0, -100.0, -100.0, 0, -100.0, -100.0, -100.0, 0, 26.673077, 32.562862, 47.584598, 71.75, 86.75, 100.0, 160.0, 180.0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0, 3000.0, 24.165402, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0, 3000.0, 5.889785, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0, 3000.0, 13.25, 0, 0, 0, 0, 0, 0, 1.0, 26.673077, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0, 3000.0, 15.0, 0, 0, 0, 1.0, 4000.0, 60.0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0, 3000.0, 15.021736, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0, 2500.0, 20.0]

eval_func = function(X::Vector{Float64})
                return 1.*X[1]+1.*X[2]+1.*X[3]+1.*X[4]+1.*X[5]+1.*X[6]
            end

operators = Dict{Operator,Integer}(UniformMutation() => 20,
                                BoundaryMutation() => 20,
                                NonUniformMutation() => 20,
                                WholeNonUniformMutation() => 20,
                                ArithmeticalCrossover() => 40,
                                SimpleCrossover() => 40,
                                HeuristicCrossover() => 40)


spec_dummy = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 3,
                        starting_population_type=single_point_start_pop, minmax = minimization, starting_point = starting_point, epsilon = 1e-3)
end
spec = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 6000, cumulative_prob_coeff = 0.018,
                        starting_population_type=single_point_start_pop, operator_mapping=operators, population_size=400, minmax = minimization, starting_point = starting_point, epsilon = 0.0)

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






