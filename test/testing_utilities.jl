
function custom_test(content::Function, name::String)
    print("Test: ")
    println(name)
    content()
    println("     Passed")
end

function custom_suite(name::String)
    println("\n\n  ---------------------------------------  ")
    println("   suite: $name")
    println("  ---------------------------------------  \n\n")
end



function get_sample_spec(starting_population_type = single_point_start_pop;

                inequalities = Float64[0.0 1.0 1.0 0.0;
                                       1.0 -2.0 0.0 1.0],
                inequalities_upper = Float64[3.0, 0.0],

                lower_bounds = Float64[1.0, 0.0, -2.1, 0.0],
                upper_bounds = Float64[8.0, 8.0, 3.1, 4.4],

                evaluation_func = ( x -> x ))

                inequalities_lower = Float64[-Inf, -Inf]

    ParallelGenocop.InternalSpec(evaluation_func, Int[], inequalities, inequalities_lower, inequalities_upper,
                    lower_bounds, upper_bounds, 70, 500, ParallelGenocop._default_operator_mapping, 0.1,
                    maximization, starting_population_type, length(lower_bounds), Float64[], Float64[1.0 2.0; 2.0 3.0])
end


function get_spec_with_all_individuals_feasible(starting_population_type = single_point_start_pop)
    inequalities_upper = Float64[30.0, 30.0]        #all individuals feasible

    get_sample_spec(starting_population_type, inequalities_upper = inequalities_upper)
end

function get_spec_with_all_individuals_infeasible(starting_population_type = single_point_start_pop)
    inequalities_upper = Float64[-30.0, 0.0]        #impossible to find feasible individual

    get_sample_spec(starting_population_type, inequalities_upper = inequalities_upper)
end


function get_individual_with_fitness(fitness)
    ind = Individual([.1, .2])
    ind.fitness = fitness
    return ind
end

function get_dead_individual()
    ind = Individual([.1, .2])
    ind.dead = true
    return ind
end

function get_generation(population, cum_prob)
    gen = ParallelGenocop.Generation(1, population, Int16[4])
    gen.cumulative_probabilities = cum_prob
    return gen
end
