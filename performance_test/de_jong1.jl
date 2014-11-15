using ParallelGenocop
@everywhere @Logging.configure(level=ERROR)


###
println("De Jong first function")

lower_bounds = Float64[-5.12, -5.12, -5.12, -5.12, -5.12, -5.12, -5.12, -5.12, -5.12, -5.12]
upper_bounds = Float64[5.12, 5.12, 5.12, 5.12, 5.12, 5.12, 5.12, 5.12, 5.12, 5.12]

eval_func = function(arg::Vector{Float64})
                total = 0.0
                for i=1:10
                    total += arg[i] * arg[i]
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

