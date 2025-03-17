using CSV
using DataFrames
using StatsPlots

# Read the CSV file
data = CSV.read("../dane_demograficzne_2024.csv", DataFrame; ignorerepeated=true, delim=',')

# Ensure the Population column can handle missing values
data.Population = convert(Vector{Union{String, Missing}}, data.Population)

# Replace 'X' with missing in the Population column
data.Population = replace(data.Population, "X" => missing)

# Drop rows with missing Population
dropmissing!(data, :Population)

# Convert Population to float, handling missing values
data.Population = parse.(Float64, data.Population)

# Create a pivot table to compare deaths between men and women
pivot_table = combine(groupby(data, :Category), :Deaths => sum => :TotalDeaths)
comparison = filter(row -> row.Category in ["Men", "Women"], pivot_table)

# Plot the comparison using a bar chart
@df comparison bar(:Category, :TotalDeaths, legend=false, title="Comparison of Deaths between Men and Women", xlabel="Gender", ylabel="Number of Deaths")
savefig("comparison_deaths_men_women.png")