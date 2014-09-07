
function custom_test(content::Function, name::String)
    print("Test: ")
    println(name)
    content()
    println("     Passed")
end

function custom_suite(name::String)
    println("\n\n  ---------------------------------------  ")
    println("   suite: $name")
    println("  ---------------------------------------  \n\n")
end
