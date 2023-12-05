# using Printf

function print_info(λ)
    comp_sum = sum(λ)
    var_proportion = λ ./ comp_sum
    cum_proportion = cumsum(var_proportion)

    println("\t\t\teigenvalue\t\tvariance.percent\tcummulative.variance.percent")
    println("------------------------------------------------------------------------------------")
    for i in eachindex(λ)
        print("Dim.", i, "  ")
        @printf(" \t%.6f\t\t%.6f\t\t\t\t%.6f\n", λ[i], var_proportion[i], cum_proportion[i])
    end
end

function print_components(λ)
    comp_sum = sum(λ)
    println("Importance of components:")
    l = length(λ)
    itr = 6
    step = convert(Int, floor(l/itr))
    beg = 1
    e = beg + step - 1
    for a in 1:itr + 1
        if a == itr + 1
            e = l
        end
        print("\t\t\t\t\t\t")
        for i in beg:e
            print("PC", i, ":\t\t")
        end
        println("")
        standart_deivation = sqrt.(λ)
        print("Standart deviation:\t\t")
        for i in beg:e
            @printf("%.6f\t", standart_deivation[i])
        end
        println("")

        var_proportion = λ ./ comp_sum
        print("Prportion of Variance:\t")
        for i in beg:e
            @printf("%.6f\t", var_proportion[i])
        end
        println("")

        cumsum_proportion = cumsum(var_proportion)
        print("Cummulative proportion:\t")
        for i in beg:e
            @printf("%.6f\t", cumsum_proportion[i])
        end
        println("")
        beg += step 
        e = beg + step - 1
    end
end