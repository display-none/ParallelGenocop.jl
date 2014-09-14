
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



function get_sample_spec(;
                equalities = Float64[2.0 1.0 0.0 -3.5],
                equalities_right = Float64[1.0],

                inequalities = Float64[0.0 1.0 1.0 0.0;
                                       1.0 -2.0 0.0 0.0],
                inequalities_right = Float64[3.0, 0.0],

                lower_bounds = Float64[1.0, 0.0, -2.1, 0.0],
                upper_bounds = Float64[8.0, 8.0, 3.1, 4.4])

    GenocopSpec(equalities, equalities_right, inequalities, inequalities_right,
                    lower_bounds, upper_bounds)
end
