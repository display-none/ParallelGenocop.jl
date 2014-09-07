module ParallelGenocop
using Distributions
using Logging

export
    #main function
    genocop,

    #constants
    minimization, maximization,
    random_start_pop, single_point_start_pop,

    #types
    GenocopSpec

@Logging.configure(level=DEBUG)

include("constants.jl")
include("types.jl")
include("utils.jl")

include("evaluation.jl")
include("initialization.jl")



#all inequalities assume that left hand side is LESS OR EQUAL to the right hand side

#evaluation_function must be a function accepting one argument: a Vector{T}

# TODO: maybe it's possible to accept Numbers instead of FloatingPoints
function genocop{T <: FloatingPoint}(specification::GenocopSpec{T}, evaluation_function::Function)
    @debug "genocop starting"
    initialize_population(specification)
    nothing
end



end # module
