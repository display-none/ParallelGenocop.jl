using ParallelGenocop
using Base.Test

include("testing_utilities.jl")

@Logging.configure(level=OFF)

tests = ["evaluation_test.jl", "genocop_test.jl", "initialization_test.jl", "optimization_test.jl", "types_test.jl", "utils_test.jl"]

println("Running tests:")
for test in tests
  include(test)
end
