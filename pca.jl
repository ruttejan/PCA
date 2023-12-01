using Pkg

Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("LinearAlgebra")
Pkg.add("Statistics")
Pkg.add("Printf")
Pkg.add("Plots")


using CSV
using DataFrames
using LinearAlgebra
using Statistics
using Printf
using Plots

# path to our dataset (.csv file)
file_path = joinpath(pwd(), "data","turkiye-student-evaluation_R_Specific.csv")

# read data as a DataFrame
df = CSV.read(file_path, header=true, DataFrame)


# our dataset has an index at the first column and the data starts from the second column
# we need to extract the right data and rename it so it is right
column_names_before = names(df)[1:end]
column_names = column_names_before[1:end-1]
data = df[:, 2:end]
rename!(data, Symbol.(column_names))

# we check that there are no missing values
if all(ismissing, eachcol(df))
    error("DataFrame have some Missing values!")
end

# we check that we are using only numerical values
if !all(t <: Number for t in eltype.(eachcol(df)))
    error("DataFrame has non-Numeric values!")
end

# we center and scale our data and create a covariance matrix
data_matrix = Matrix(data)'
N, M = size(data_matrix)
centered_scaled_data = (data_matrix .- mean(data_matrix, dims=2)) ./ std(data_matrix, dims=2)
cov_data = centered_scaled_data * centered_scaled_data' / (M-1)
df_cov = DataFrame(cov_data, column_names)
insertcols!(df_cov, 1, :Names => column_names)

# show(df_cov, allcols=true, allrows=true)
show(df_cov)

# calculate eigen values and eigen vectors
λ, V = eigen(cov_data)
# reverse them so the eigen values are in descending order
λ = reverse(λ)
V = reverse(V, dims = 2)

function print_info(λ)
    comp_sum = sum(λ)
    var_proportion = λ ./ comp_sum
    cum_proportion = cumsum(var_proportion)

    println("\t\teigenvalue\t\tvariance.percent\tcummulative.variance.percent")
    println("-------------------------------------------------------------------------------------")
    for i in eachindex(λ)
        print("Dim.", i, "  ")
        @printf(" \t%.6f\t\t%.6f\t\t%.6f\n", λ[i], var_proportion[i], cum_proportion[i])
    end
end

print_info(λ)

function print_components(λ)
    comp_sum = sum(λ)
    println("Importance of components:")

    for i in eachindex(λ)
        print("PC", i, ":\t")
    end
    println("")
    standart_deivation = sqrt.(λ)
    print("Standart deviation:  ")
    for i in eachindex(λ)
        @printf("%.6f\t", standart_deivation[i])
    end
    println("")

    var_proportion = λ ./ comp_sum
    print("Prportion of Variance: ")
    for i in eachindex(λ)
        @printf("%.6f\t", var_proportion[i])
    end
    println("")

    cumsum_proportion = cumsum(var_proportion)
    println("Cummulative proportion: ")
    for i in eachindex(λ)
        @printf("%.6f\t", cumsum_proportion[i])
    end
    println("")

end

print_components(λ)

dim2V = V[:, 1:2]

t = dim2V' * centered_scaled_data

t[:, 1:10]'

plotly()
scatter(t[1, 1:10], t[2, 1:10], legend=nothing)




