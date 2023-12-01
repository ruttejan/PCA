using Pkg

Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("LinearAlgebra")
Pkg.add("Statistics")
Pkg.add("MultivariateStats")
Pkg.add("Printf")
Pkg.add("Plots")


using CSV
using DataFrames
using LinearAlgebra
using Statistics
using MultivariateStats
using Printf
using Plots

# path to our dataset (.csv file)
file_path = joinpath(pwd(), "data","turkiye-student-evaluation_R_Specific.csv")

# read data as a DataFrame
df = CSV.read(file_path, header=true, DataFrame)

# our dataset has an index at the first column and the data starts from the second column
# we need to extract the right data and rename it so it is right
column_names = names(df)[1:end-1]
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
data_matrix = Matrix(data)
N, M = size(data_matrix)
centered_scaled_data = (data_matrix .- mean(data_matrix, dims=1)) ./ std(data_matrix, dims=1)
cov_data = centered_scaled_data' * centered_scaled_data / (N-1)
df_cov = DataFrame(cov_data, column_names)
insertcols!(df_cov, 1, :Names => column_names)

# show(df_cov, allcols=true, allrows=true)
show(df_cov)

# calculate eigen values and eigen vectors
λ, V = eigen(cov_data)
# reverse them so the eigen values are in descending order
λ = reverse(λ)
V = reverse(V, dims = 2)


var_sum = sum(λ)

print_info(λ)


println("Standart deviation:  ", standart_deivation)
println("Prportion of Variance: ", var_proportion)
println("Cummulative proportion: ", cum_proportion)


function print_info(λ)
    standart_deivation = sqrt.(λ)
    var_proportion = λ ./ var_sum
    cum_proportion = cumsum(var_proportion)

    println("\t\teigenvalue\t\tvariance.percent\tcummulative.variance.percent")
    println("-------------------------------------------------------------------------------------")
    for i in eachindex(λ)
        print("Dim.", i, "  ")
        @printf(" \t%.6f\t\t%.6f\t\t%.6f\n", λ[i], var_proportion[i], cum_proportion[i])
    end
end

data_matrix = convert(Matrix{Float64}, data_matrix)
pca_result = fit(PCA, data_matrix, maxoutdim=2)
var_importance = pca_result.prinvars


dim2V = V[:, 1:2]

t = centered_scaled_data * dim2V
t2 = dim2V' * data_matrix

t[1:10, :]

plotly()
scatter(t[:,1]', t[:,2]', legend=nothing)




