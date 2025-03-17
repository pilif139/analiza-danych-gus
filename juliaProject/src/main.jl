using CSV
using DataFrames
using StatsPlots
using Printf

# Read the CSV file
data = CSV.read("../dane_demograficzne_2024.csv", DataFrame; ignorerepeated = true, delim = ',')

data.Population = convert(Vector{Union{String, Missing}}, data.Population)

data.Population = replace(data.Population, "X" => missing)

dropmissing!(data, :Population)

data.Population = parse.(Float64, data.Population)

data.Population = [@sprintf("%.0f", pop) for pop in data.Population]

# Create a pivot table to compare deaths between men and women
pivot_table = combine(groupby(data, :Category), :Deaths => sum => :TotalDeaths)
comparison = filter(row -> row.Category in ["Men", "Women"], pivot_table)

# Plot the comparison using a bar chart
bar_plot = @df comparison bar(
    :Category, 
    :TotalDeaths, 
    legend=false, 
    title="Comparison of Deaths between Men and Women", 
    xlabel="Gender", 
    ylabel="Number of Deaths",
    size=(800, 800),
    color=:red,
)

bar_plot = plot!(bar_plot, yformatter=x->@sprintf("%.0f",x))

for i in 1:nrow(comparison)
	annotate!(bar_plot, i - 100, comparison.TotalDeaths[i] + 100, text(string(comparison.TotalDeaths[i]), :center, 10))
end

savefig(bar_plot, "comparison_deaths_men_women.png")
