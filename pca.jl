using Pkg

Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("LinearAlgebra")
Pkg.add("Statistics")
Pkg.add("Printf")
Pkg.add("Plots")

include("print_funcs.jl")

using CSV
using DataFrames
using LinearAlgebra
using Statistics
using Printf
using Plots

# path to our dataset (.csv file)
file_path = joinpath(pwd(), "data","turkiye-student-evaluation_generic.csv")

# read data as a DataFrame
df = CSV.read(file_path, header=true, DataFrame)

# select the names of the columns for future use
column_names = names(df)

# we check that there are no missing values
if all(ismissing, eachcol(df))
    error("DataFrame have some Missing values!")
else 
    println("Nothing is missing")
end

# we check that we are using only numerical values
if !all(t <: Number for t in eltype.(eachcol(df)))
    error("DataFrame has non-Numeric values!")
else
    println("All values are numeric")
end

show(df[1:3, 1:8])
show(df[1:3, 9:17])
show(df[1:3, 18:26])
show(df[1:3, 27:end])

# we center and scale our data and create a covariance matrix
data_matrix = Matrix(df)'
N, M = size(data_matrix)
centered_scaled_data = (data_matrix .- mean(data_matrix, dims=2)) ./ std(data_matrix, dims=2)
cov_data = centered_scaled_data * centered_scaled_data' / (M-1)
df_cov = DataFrame(cov_data, column_names)
insertcols!(df_cov, 1, :Names => column_names)

show(df_cov)

# calculate eigen values and eigen vectors
λ, V = eigen(cov_data)
# reverse them so the eigen values are in descending order
λ = reverse(λ)
V = reverse(V, dims = 2)

print_info(λ)

print_components(λ)

dim2V = V[:, 1:2]

t = dim2V' * centered_scaled_data


scatter(t[1, 1:10], t[2, 1:10], legend=nothing)

dim5V = V[:, 1:5]
d = dim5V' * centered_scaled_data

d[:, 1:10]'

cov_data2 = centered_scaled_data' * centered_scaled_data / (M-1);

λ2, V2 = eigen(cov_data2);
# reverse them so the eigen values are in descending order
λ2 = reverse(λ2);
V2 = reverse(V2, dims = 2);

dim2V2 = V2[:, 1:2];
t2 = centered_scaled_data * dim2V2;
size(t2)
x = t2[:, 1]';
y = t2[:, 2]';
scatter(x, y, legend=nothing)
annotate!([(xi, yi, text(name, :bottom, 8)) for (xi, yi, name) in zip(x, y, column_names)])