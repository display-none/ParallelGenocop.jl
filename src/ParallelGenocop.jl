module ParallelGenocop
using Distributions: Uniform
using Logging
using NumericExtensions
import Base.copy, Base.length

export
    #main function
    genocop,

    #constants
    minimization, maximization,
    multi_point_start_pop, single_point_start_pop,

    #operators
    Operator,
    UniformMutation, BoundaryMutation,
    NonUniformMutation, WholeNonUniformMutation,
    ArithmeticalCrossover, SimpleCrossover,
    HeuristicCrossover,

    #types
    GenocopSpecification, Individual

@Logging.configure(level=DEBUG)
# blas_set_num_threads(2)


include("operator_types.jl")
include("constants.jl")
include("types.jl")
include("utils.jl")

include("evaluation.jl")
include("initialization.jl")
include("operators_impl.jl")
include("reduction.jl")
include("selection.jl")
include("optimization.jl")



#all inequalities assume that left hand side is LESS OR EQUAL to the right hand side

#evaluation_function must be a function accepting one argument: an AbstractVector{T}

# TODO: maybe it's possible to accept Numbers instead of FloatingPoints
function genocop{T <: FloatingPoint}(specification::GenocopSpecification{T})
    @debug "genocop starting"
    internal_spec = reduce_equalities(specification)
    population_data, fitness_data = initialize_population_data(internal_spec)

    for process in procs()
        @fetchfrom process (set_spec(internal_spec);set_population_data(population_data, fitness_data))
    end

    population::Vector{Individual} = initialize_population(internal_spec)
    best_individual = optimize!(population, internal_spec)

    best_extended = extend_with_reduced_variables(best_individual, internal_spec)
    best_real = typeof(best_extended) <: Vector ? best_extended : [best_extended[i] for i=1:length(best_extended)]
    @info "best individual: $best_real"
    feasible = is_feasible(best_individual, internal_spec)
    @info "individual feasible: $feasible"
    return best_real
end



end # module
