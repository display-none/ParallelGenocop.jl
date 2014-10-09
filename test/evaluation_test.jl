
custom_suite("evaluation tests")

custom_test("evaluate! should call evaluation function with appropriate arguments") do
    #given
    chromosome = [3.2, 4.3]
    called = false
    called_with_appropriate_arguments = false
    function eval_func(ch::Vector)
        called = true
        if ch == chromosome
            called_with_appropriate_arguments = true
        end
    end

    #when
    ParallelGenocop.evaluate!(Individual(chromosome), get_sample_spec(evaluation_func = eval_func))

    #then
    @test called == true
    @test called_with_appropriate_arguments == true
end


custom_test("evaluate! should call set the value returned by evaluation function in individual") do
    #given
    individual = Individual([3.2, 4.3])
    fitness = 666.9
    function eval_func(ch::Vector)
        return fitness
    end

    #when
    ParallelGenocop.evaluate!(individual, get_sample_spec(evaluation_func = eval_func))

    #then
    @test individual.fitness == fitness
end


custom_test("evaluate! should rethrow MethodError when evaluation function supplied with wrong signature") do
    #given
    chromosome = [3.2, 4.3]
    function eval_func(ch::Vector{Integer})

    end

    #when & then
    @test_throws MethodError ParallelGenocop.evaluate!(Individual(chromosome), get_sample_spec(evaluation_func = eval_func))
end

custom_test("evaluate! should rethrow an exception thrown by the evaluation function") do
    #given
    chromosome = [3.2, 4.3]
    function eval_func(ch::Vector)
        throw(InexactError())
    end

    #when & then
    @test_throws InexactError ParallelGenocop.evaluate!(Individual(chromosome), get_sample_spec(evaluation_func = eval_func))
end


custom_test("evaluate_population! should evaluate only individuals not already evaluated") do
    #given
    individual1 = Individual([1.0, 1.0])
    individual2 = Individual([2.0, 2.0])
    individual2.fitness = 2.0
    individual3 = Individual([3.0, 3.0])

    called1 = false
    called2 = false
    called3 = false
    function eval_func(ch::Vector)
        ch == [1.0, 1.0] ? called1 = true :
        ch == [2.0, 2.0] ? called2 = true :
        ch == [3.0, 3.0] ? called3 = true : nothing
    end

    #when
    ParallelGenocop.evaluate_population!([individual1, individual2, individual3], get_sample_spec(evaluation_func = eval_func))

    #then
    @test called1 == true
    @test called2 == false
    @test called3 == true
end
