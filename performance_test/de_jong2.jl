using ParallelGenocop
@everywhere @Logging.configure(level=ERROR)



###
println("De Jong second function, Rosenbrock’s valley")


lower_bounds = Float64[-2.048 for i=1:10]
upper_bounds = Float64[2.048 for i=1:10]

eval_func = function(X::Vector{Float64})
                total = 0.0
                for i=1:9
                    total += 100 * (X[i+1] - X[i]^2)^2 + (1 - X[i])^2
                end
                return total
            end


spec = GenocopSpecification(eval_func, lower_bounds, upper_bounds; max_iterations = 500,
                        starting_population_type=single_point_start_pop, minmax = minimization)


best = @time genocop(spec)
println("best: $best")
best_eval = eval_func(best)
println("best fitness: $best_eval")

print("\n\n\n")
