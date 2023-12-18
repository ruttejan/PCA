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

include("print_funcs.jl")

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

centered_data = data_matrix .- mean(data_matrix, dims=2)
centered_scaled_data = centered_data ./ std(data_matrix, dims=2)

cov_matrix = centered_data * centered_data' / (M-1)
corr_matrix = centered_scaled_data * centered_scaled_data' / (M-1)

df_corr = DataFrame(corr_matrix, column_names)
insertcols!(df_corr, 1, :Names => column_names)

show(df_corr)

# calculate eigen values and eigen vectors
λ, V = eigen(cov_matrix)
# reverse them so the eigen values are in descending order
λ = reverse(λ)
V = reverse(V, dims = 2)

print_info(λ)

print_components(λ)

dim2V = V[:, 1:2]

t = dim2V' * centered_data






mean_of_Q_answers = mean(data_matrix[6:end, :], dims=1)'

num_of_mean_1 = size(findall(x -> isapprox(x, 1, atol=0.1), mean_of_Q_answers))[1]
num_of_mean_2 = size(findall(x -> isapprox(x, 2, atol=0.1), mean_of_Q_answers))[1]
num_of_mean_3 = size(findall(x -> isapprox(x, 3, atol=0.1), mean_of_Q_answers))[1]
num_of_mean_4 = size(findall(x -> isapprox(x, 4, atol=0.1), mean_of_Q_answers))[1]
num_of_mean_5 = size(findall(x -> isapprox(x, 5, atol=0.1), mean_of_Q_answers))[1]

sum_of_num_of_means = num_of_mean_1 + num_of_mean_2 + num_of_mean_3 + num_of_mean_4 + num_of_mean_5

percent_of_mean_1 = num_of_mean_1 / M * 100
percent_of_mean_2 = num_of_mean_2 / M * 100
percent_of_mean_3 = num_of_mean_3 / M * 100
percent_of_mean_4 = num_of_mean_4 / M * 100
percent_of_mean_5 = num_of_mean_5 / M * 100

total_percent = sum_of_num_of_means / M * 100

function get_color(x)
    if isapprox(x, 1, atol=0.1)
        return :red
    elseif isapprox(x, 2, atol=0.1)
        return :purple
    elseif isapprox(x, 3, atol=0.1)
        return :green
    elseif isapprox(x, 4, atol=0.1)
        return :yellow
    elseif isapprox(x, 5, atol=0.1)
        return :orange
    else
        return :blue
    end
end

colors = [get_color(x) for x in mean_of_Q_answers]

scatter(t[1, :], t[2, :],color=colors, legend=nothing)

indices_1 = findall(x -> x == :red, colors)
indices_2 = findall(x -> x == :purple, colors)
indices_3 = findall(x -> x == :green, colors)
indices_4 = findall(x -> x == :yellow, colors)
indices_5 = findall(x -> x == :orange, colors)
indices_other = findall(x -> x == :blue, colors)
scatter(t[1, indices_1], t[2, indices_1],color=:red, label="1")
scatter!(t[1, indices_2], t[2,indices_2], color=:purple, label="2")
scatter!(t[1, indices_3], t[2,indices_3], color=:green, label="3")
scatter!(t[1, indices_4], t[2,indices_4], color=:yellow, label="4")
scatter!(t[1, indices_5], t[2,indices_5], color=:orange, label="5")
scatter!(t[1, indices_other], t[2,indices_other], color=:blue, label="other")
## red - 1, purple - 2, green - 3, yellow - 4, orange - 5, blue - other
## the number associated with the color is the mean of the answers for the 28 quality questions
## for each color we can see that almost all the answers were the same 


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