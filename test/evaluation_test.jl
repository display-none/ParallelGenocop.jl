
custom_suite("evaluation tests")

custom_test("evaluate_and_return_fitness should call evaluation function with appropriate arguments") do
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
    ParallelGenocop.evaluate_and_return_fitness(chromosome, get_sample_spec(evaluation_func = eval_func))

    #then
    @test called == true
    @test called_with_appropriate_arguments == true
end


custom_test("evaluate_and_return_fitness should return the value returned by evaluation function") do
    #given
    chromosome = [3.2, 4.3]
    fitness = 666.9
    function eval_func(ch::Vector)
        return fitness
    end

    #when
    returned = ParallelGenocop.evaluate_and_return_fitness(chromosome, get_sample_spec(evaluation_func = eval_func))

    #then
    @test returned == fitness
end


custom_test("evaluate_and_return_fitness should rethrow MethodError when evaluation function supplied with wrong signature") do
    #given
    chromosome = [3.2, 4.3]
    function eval_func(ch::Vector{Integer})

    end

    #when & then
    @test_throws MethodError ParallelGenocop.evaluate_and_return_fitness(chromosome, get_sample_spec(evaluation_func = eval_func))
end

custom_test("evaluate_and_return_fitness should rethrow an exception thrown by the evaluation function") do
    #given
    chromosome = [3.2, 4.3]
    function eval_func(ch::Vector)
        throw(InexactError())
    end

    #when & then
    @test_throws InexactError ParallelGenocop.evaluate_and_return_fitness(chromosome, get_sample_spec(evaluation_func = eval_func))
end

