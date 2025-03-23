using CSV
using DataFrames
using Statistics
using Plots
using GLM

# load data
df = CSV.read("../prognoza.csv", DataFrame)

# missing values
missing_counts = map(col -> sum(ismissing, col), eachcol(df))

# describe data frame
describe(df)

# Plot population over time
areas = unique(df.Area)
population_plot = plot(xlabel="Year", ylabel="Population", title="Population Over Time")
for area in areas
    area_data = df[df.Area .== area, :]
    plot!(population_plot, area_data.Year, area_data.Population_31_XII, label=area)
end
savefig(population_plot, "./graphs/population_over_time.png")

# births and deaths over time
births_plot = plot(xlabel="Year", ylabel="Count", title="Births over time")
deaths_plot = plot(xlabel="Year", ylabel="Count", title="Deaths over time")
for area in areas
    area_data = df[df.Area .== area, :]
    plot!(births_plot, area_data.Year, area_data.Births, label="$area Births")
    plot!(deaths_plot, area_data.Year, area_data.Deaths, label="$area Deaths")
end
savefig(births_plot, "./graphs/births_over_time.png")
savefig(deaths_plot, "./graphs/deaths_over_time.png")

# average population change
df.Population_Change = [0; diff(df.Population_31_XII)]
average_population_change = combine(groupby(df, :Area), :Population_Change => mean => :Average_Population_Change)

average_population_change_bar = bar(average_population_change.Area, average_population_change.Average_Population_Change, legend=false)
savefig(average_population_change_bar, "./graphs/average_population_change.png")