module ParallelGenocop
using Distributions
using Logging
import Base.copy

export
    #main function
    genocop,

    #constants
    minimization, maximization,
    multi_point_start_pop, single_point_start_pop,

    #operators
    Operator,
    UniformMutation, BoundaryMutation,
    ArithmeticalCrossover, SimpleCrossover,

    #types
    GenocopSpecification, Individual

@Logging.configure(level=DEBUG)

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

#evaluation_function must be a function accepting one argument: a Vector{T}

# TODO: maybe it's possible to accept Numbers instead of FloatingPoints
function genocop{T <: FloatingPoint}(specification::GenocopSpecification{T})
    @debug "genocop starting"
    internal_spec = reduce_equalities(specification)
    population::Vector{Individual{T}} = initialize_population(internal_spec)
    best_individual = optimize!(population, internal_spec)

    best_extended = extend_with_reduced_variables(best_individual.chromosome, internal_spec)
    @info "best individual: $best_extended"
    feasible = is_feasible(best_individual.chromosome, internal_spec)
    @info "individual feasible: $feasible"
    return best_individual.chromosome
end



end # module
