using CSV
using Plots
using Dates

data = CSV.File("fifa.csv")

teams = Dict()

for row in data
    country = row.country_abrv
    if !haskey(teams, country)
        teams[country] = []
    end
    push!(teams[country], (row.rank_date, row.total_points))
end


p = plot(legend = :none)
for (name, value) in teams
    if true
        plot!((x -> x[1]).(value), (x -> x[2]).(value), label = name)
    end
end

#peak = reduce(teams["CHI"], (a, b) -> if a[2] > b[2] a else b end)
#println(peak)

savefig(p, "plot.svg")
