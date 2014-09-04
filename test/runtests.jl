using ParallelGenocop
using Base.Test

@Logging.configure(level=OFF)

tests = ["genocop_test.jl", "types_test.jl", "utils_test.jl"]

println("Running tests:")
for test in tests
  include(test)
end
