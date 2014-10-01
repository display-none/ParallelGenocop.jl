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
    GenocopSpec, Individual

@Logging.configure(level=DEBUG)

include("operator_types.jl")
include("constants.jl")
include("types.jl")
include("utils.jl")

include("evaluation.jl")
include("initialization.jl")
include("operators_impl.jl")
include("selection.jl")
include("optimization.jl")



#all inequalities assume that left hand side is LESS OR EQUAL to the right hand side

#evaluation_function must be a function accepting one argument: a Vector{T}

# TODO: maybe it's possible to accept Numbers instead of FloatingPoints
function genocop{T <: FloatingPoint}(specification::GenocopSpec{T})
    @debug "genocop starting"
    population::Vector{Individual{T}} = initialize_population(specification)
    best_individual = optimize!(population, specification)

    @info "best individual: $(best_individual.chromosome)"
    feasible = is_feasible(best_individual.chromosome, specification)
    @info "individual feasible: $feasible"
    return best_individual.chromosome
end



end # module
