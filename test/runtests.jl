tests = ["genocop_test.jl", "utils_test.jl"]

println("Running tests:")
for test in tests
  include(test)
end
