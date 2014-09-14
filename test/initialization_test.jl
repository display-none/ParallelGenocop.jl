
custom_suite("initialization tests")

custom_test("get_random_chromosome_within_bounds should return a chromosome within bounds") do
    lower_bounds = Float64[1.0, 0.0, -2.1, 0.0]
    upper_bounds = Float64[8.0, 8.0, 3.1, 4.4]
    spec = get_sample_spec(lower_bounds = lower_bounds, upper_bounds = upper_bounds)

    chromosome = ParallelGenocop.get_random_chromosome_within_bounds(spec)
    for i=1:4
        @test lower_bounds[i] <= chromosome[i] <= upper_bounds[i]
    end
end
