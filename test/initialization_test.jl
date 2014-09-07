
custom_suite("initialization tests")

function get_sample_spec(;
                equalities = Float64[2.0 1.0 0.0 -3.5],
                equalities_right = Float64[1.0],

                inequalities = Float64[0.0 1.0 1.0 0.0;
                                       1.0 -2.0 0.0 0.0],
                inequalities_right = Float64[3.0, 0.0],

                lower_bounds = Float64[1.0, 0.0, -2.1, 0.0],
                upper_bounds = Float64[8.0, 8.0, 3.1, 4.4])

    GenocopSpec(equalities, equalities_right, inequalities, inequalities_right,
                    lower_bounds, upper_bounds)
end

custom_test("is_feasible should return false if any row is infeasible") do
    infeasible_inequalities_right = Float64[-Inf, -Inf]
    spec = get_sample_spec(inequalities_right = infeasible_inequalities_right)


    @test false == ParallelGenocop.is_feasible(ParallelGenocop.Individual(Float64[1.3, 2.3, 1.2, 3.3]), spec)
end


custom_test("is_feasible should return false if first row is feasible, but second is infeasible") do
    mixed_inequalities_right = Float64[Inf, -Inf]
    spec = get_sample_spec(inequalities_right = mixed_inequalities_right)


    @test false == ParallelGenocop.is_feasible(ParallelGenocop.Individual(Float64[1.3, 2.3, 1.2, 3.3]), spec)
end


custom_test("is_feasible should return true when all rows are feasible") do
    mixed_inequalities_right = Float64[Inf, Inf]
    spec = get_sample_spec(inequalities_right = mixed_inequalities_right)


    @test true == ParallelGenocop.is_feasible(ParallelGenocop.Individual(Float64[1.3, 2.3, 1.2, 3.3]), spec)
end


custom_test("get_random_individual_within_bounds should return an individual within bounds") do
    lower_bounds = Float64[1.0, 0.0, -2.1, 0.0]
    upper_bounds = Float64[8.0, 8.0, 3.1, 4.4]
    spec = get_sample_spec(lower_bounds = lower_bounds, upper_bounds = upper_bounds)

    individual = ParallelGenocop.get_random_individual_within_bounds(spec)
    for i=1:4
        @test lower_bounds[i] <= individual.chromosome[i] <= upper_bounds[i]
    end
end
