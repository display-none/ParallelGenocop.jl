module ParallelGenocop

export
    #main function
    genocop,

    #constants
    Min, Max,
    RandomStartPop, SinglePointStartPop,

    #types
    GenocopSpec


include("constants.jl")
include("types.jl")
include("utils.jl")



#all inequalities assume that left hand side is LESS OR EQUAL to the right hand side

# TODO: maybe it's possible to accept Numbers instead of FloatingPoints
function genocop{T <: FloatingPoint}(specification::GenocopSpec{T})


end



end # module
