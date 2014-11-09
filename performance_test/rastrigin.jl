using ParallelGenocop
@everywhere @Logging.configure(level=ERROR)



###
println("Rastrigin’s function")


lower_bounds = Float64[-5.12 for i=1:100]
upper_bounds = Float64[5.12 for i=1:100]

eval_func = function(X::Vector{Float64})
                total = 0.0
                for i=1:100
                    total += X[i]^2 - 10*cos(2*pi*X[i])
                end
                return 10*100 + total
            end


spec = GenocopSpecification(eval_func, lower_bounds, upper_bounds; max_iterations = 10000,
                        starting_population_type=single_point_start_pop, minmax = minimization)


best = @time genocop(spec)
println("best: $best")
best_eval = eval_func(best)
println("best fitness: $best_eval")

print("\n\n\n")
