import ParallelGenocop
using Base.Test


begin #GenocopSpec constructor should assert population size is positive
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1, .2], [.1, .2];population_size=-4)
end

begin #GenocopSpec constructor should assert max iterations is positive
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1, .2], [.1, .2];max_iterations=-4)
end

begin #GenocopSpec constructor should throw exception when operator frequency vector does not have 7 values
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1, .2], [.1, .2]
                                                                ;operator_frequency=Integer[1, 2, 3, 4, 5])
end

begin #GenocopSpec constructor should not throw exception when operator frequency vector does not have 7 values
    ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1, .2], [.1, .2]
                                                                ;operator_frequency=Integer[1, 2, 3, 4, 5, 6, 7])
end

begin #GenocopSpec constructor should throw exception when sum of parents for reproduction exceeds population size
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1, .2], [.1, .2]
                                                                ;operator_frequency=Integer[1, 2, 3, 4, 5, 6, 7],
                                                                population_size=4)
end

begin #GenocopSpec constructor should set passed values and defaults in the object
    spec = ParallelGenocop.GenocopSpec([.1 .2], [.3], [.4 .5], [.6], [.7, .8], [.9, .10])

    @test spec.equalities == [.1 .2]
    @test spec.equalities_right == [.3]
    @test spec.inequalities == [.4 .5]
    @test spec.inequalities_right == [.6]
    @test spec.lower_bounds == [.7, .8]
    @test spec.upper_bounds == [.9, .10]
    @test spec.population_size == ParallelGenocop._default_population_size
    @test spec.max_iterations == ParallelGenocop._default_max_iter
    @test spec.operator_frequency == ParallelGenocop._default_operator_frequency
    @test spec.cumulative_prob_coeff == ParallelGenocop._default_cumulative_prob_coeff
    @test spec.minmax == ParallelGenocop._default_minmax_type
    @test spec.starting_population_type == ParallelGenocop._default_starting_population
end

begin #GenocopSpec constructor should set passed optional values in the object
    spec = ParallelGenocop.GenocopSpec([.1 .2], [.3], [.4 .5], [.6], [.7, .8], [.9, .10];
                                            population_size = 69,
                                            max_iterations = 666,
                                            operator_frequency = Integer[1, 2, 3, 4, 5, 6, 7],
                                            cumulative_prob_coeff = 0.32,
                                            minmax = Max,
                                            starting_population_type=SinglePointStartPop)

    @test spec.population_size == 69
    @test spec.max_iterations == 666
    @test spec.operator_frequency == Integer[1, 2, 3, 4, 5, 6, 7]
    @test spec.cumulative_prob_coeff == 0.32
    @test spec.minmax == Max
    @test spec.starting_population_type == SinglePointStartPop
end
