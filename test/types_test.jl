import ParallelGenocop
using Base.Test


begin #GenocopSpec constructor should assert population size is positive
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1], [.1];population_size=-4)
end

begin #GenocopSpec constructor should assert max iterations is positive
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1], [.1];max_iterations=-4)
end

begin #GenocopSpec constructor should throw exception when operator frequency vector does not have 7 values
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1], [.1]
                                                                ;operator_frequency=Integer[1, 2, 3, 4, 5])
end

begin #GenocopSpec constructor should not throw exception when operator frequency vector does not have 7 values
    ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1], [.1]
                                                                ;operator_frequency=Integer[1, 2, 3, 4, 5, 6, 7])
end

begin #GenocopSpec constructor should throw exception when sum of parents for reproduction exceeds population size
    @test_throws ErrorException ParallelGenocop.GenocopSpec([.1 .2], [.1], [.1 .2], [.1], [.1], [.1]
                                                                ;operator_frequency=Integer[1, 2, 3, 4, 5, 6, 7],
                                                                population_size=4)
end


