@everywhere using ParallelGenocop
@everywhere @Logging.configure(level=INFO)


function test()
###
println("gsg_0001 - gams globallib")


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

lower_bounds = Float64[12.735,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf]
upper_bounds = Float64[12.735,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,140,0.1,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,0.2,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,0.01,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,0,400,400,400,400,400,400,400,400,400,400]

equalities = readdlm("gsg_0001_eq", Float64)
equalities_right = Float64[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]

inequalities = readdlm("gsg_0001_ineq", Float64)
inequalities_right = Float64[0.18523,0.2442,0.30729,0.41698,0.52802,0.65155,0.81675,0.98667,1.15501,1.33561,0.18523,0.2442,0.30729,0.41698,0.52802,0.65155,0.81675,0.98667,1.15501,1.33561,0.18523,0.2442,0.30729,0.41698,0.52802,0.65155,0.81675,0.98667,1.15501,1.33561,-12.735,-18.523,-24.42,-30.729,-41.698,-52.802,-65.155,-81.675,-98.667,-115.501,-133.561,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0,-0.0]

param = 1e-4
lower_bounds = loosen_it(-, param, lower_bounds)
upper_bounds = loosen_it(+, param, upper_bounds)
inequalities_right = loosen_it(+, param, inequalities_right)

starting_point = Float64[12.735,9.476036,7.051061,5.246651,3.904001,2.904944,2.161551,1.608397,1.196798,0.89053,0.662638,2.215433,9.046964,17.368939,25.482349,37.793999,49.897056,62.993449,80.066603,97.470202,114.61047,132.898362,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.1,111.15518,193.790664,255.279224,301.032488,335.077213,360.409686,379.259425,393.285401,403.722044,411.487887,0.2,56.511987,188.591504,402.847943,719.229679,1157.684954,1722.137482,2437.437743,3325.121767,4385.525123,5623.06928,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.0,18.888537,32.943383,43.401508,51.183335,56.973745,61.282354,64.488364,66.873936,68.649026,69.96986]

eval_func = function(X::Vector{Float64})
                return - (15*(5*X[45])^(-0.1)*X[12] + 130*(100*X[56])^(-0.3)*X[23] + 30*X[12] + 30*X[23]+ 0.613913253540759*(15*(5*X[46])^(-0.1)*X[13] + 130*(100*X[57])^(-0.3)*X[24]+ 30*X[13] + 30*X[24]) + 0.376889482873*(15*(5*X[47])^(-0.1)*X[14] + 130*(100*X[58])^(-0.3)*X[25] + 30*X[14] + 30*X[25]) + 0.231377448655858*(15*(5*X[48])^(-0.1)*X[15] + 130*(100*X[59])^(-0.3)*X[26] + 30*X[15] + 30*X[26]) + 0.142045682300278*(15*(5*X[49])^(-0.1)*X[16] + 130*(100*X[60])^(-0.3)*X[27] + 30*X[16] + 30*X[27]) + 0.0872037269723804*(15*(5*X[50])^(-0.1)*X[17] + 130*(100*X[61])^(-0.3)*X[28] + 30*X[17] + 30*X[28]) + 0.0535355237464941*(15*(5*X[51])^(-0.1)*X[18] + 130*(100*X[62])^(-0.3)*X[29] + 30*X[18] + 30*X[29]) + 0.0328661675632188*(15*(5*X[52])^(-0.1)*X[19] + 130*(100*X[63])^(-0.3)*X[30]+ 30*X[19] + 30*X[30]) + 0.0201769758601514*(15*(5*X[53])^(-0.1)*X[20] + 130*(100*X[64])^(-0.3)*X[31] + 30*X[20] + 30*X[31]) + 0.0123869128969189*(15*(5*X[54])^(-0.1)*X[21] + 130*(100*X[65])^(-0.3)*X[32] + 30*X[21] + 30*X[32]) + 0.00760448999787347*(15*(5*X[55])^(-0.1)*X[22] + 130*(100*X[66])^(-0.3)*X[33]+ 30*X[22] + 30*X[33])) - 40*X[1] - 24.5565301416304*X[2] - 15.07557931492*X[3]- 9.25509794623431*X[4] - 5.6818272920111*X[5] - 3.48814907889522*X[6]- 2.14142094985976*X[7] - 1.31464670252875*X[8] - 0.807079034406055*X[9]- 0.495476515876756*X[10] - 0.304179599914939*X[11]
            end

operators = Dict{Operator,Integer}(UniformMutation() => 20,
                                BoundaryMutation() => 20,
                                NonUniformMutation() => 20,
                                WholeNonUniformMutation() => 20,
                                ArithmeticalCrossover() => 40,
                                SimpleCrossover() => 40,
                                HeuristicCrossover() => 40)


spec_dummy = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 2, cumulative_prob_coeff = 0.018,
                        starting_population_type=single_point_start_pop, operator_mapping=operators, population_size=400, minmax = maximization, starting_point = starting_point, epsilon = 0.0)
end
spec = GenocopSpecification(eval_func, equalities, equalities_right, inequalities, inequalities_right, lower_bounds, upper_bounds; max_iterations = 6000, cumulative_prob_coeff = 0.018,
                        starting_population_type=single_point_start_pop, operator_mapping=operators, population_size=400, minmax = maximization, starting_point = starting_point, epsilon = 0.0)

genocop(spec_dummy)
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






