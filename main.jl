using CSV
using Plots
using Polynomials
using Dates

struct Game
	date
	home
	away
	homeGoals
	awayGoals
	tournament
end

function expectedScore(playerR, enemyR)
	return 1/(1 + 10^((enemyR - playerR)/400))
end

function kFactor(rating)
	return 1 + 18/(1 + 2^((rating - 1500)/63))
end

function newRatings(player, enemy, result, factor)
	expectedPlayer = expectedScore(player, enemy)

	return player + factor*kFactor(player)*(result - expectedPlayer), enemy - factor*kFactor(enemy)*(result - expectedPlayer)
end

function readCSV()
	local games = []
	for row in CSV.File("results.csv")
		if row.home_score == "NA"
			continue
		end
		game = Game(
			row.date,
			row.home_team,
			row.away_team,
			parse(Int64, row.home_score),
			parse(Int64, row.away_score),
			row.tournament,
		)
		push!(games, game)
	end
	return games
end

function calculateGoalMultiplier(homeGoals, awayGoals)
	diff = abs(homeGoals - awayGoals)
	if diff < 2
		return 1
	elseif diff == 2
		return 1.5
	else
		return (11 + diff)/8
	end
end

function calculateResult(homeGoals, awayGoals)
	if homeGoals == awayGoals
		return 0.5
	elseif homeGoals > awayGoals
		return 1
	else
		return 0
	end
end

function calculateElos(games)
	local elos = Dict()
	local elohistory = Dict()

	for game in games
		if !haskey(elos, game.home)
			elos[game.home] = 1500
			elohistory[game.home] = []
		end
		if !haskey(elos, game.away)
			elos[game.away] = 1500
			elohistory[game.away] = []
		end

		tournamentMultiplier = if game.tournament == "Friendly" 0.5 else 1 end
		goalMultiplier = calculateGoalMultiplier(game.homeGoals, game.awayGoals)

		result = calculateResult(game.homeGoals, game.awayGoals)

		newHome, newAway = newRatings(elos[game.home], elos[game.away], result, 20*goalMultiplier*tournamentMultiplier)
		elos[game.home] = newHome
		elos[game.away] = newAway

		push!(elohistory[game.home], (game.date, newHome))
		push!(elohistory[game.away], (game.date, newAway))
	end

	return elos, elohistory
end

function dateToDays(date)
	return (date - Date(1900, 1, 1)).value
end

function daysToDate(days)
	return Date(1900, 1, 1) + Day(days)
end

function functionFromPoints(xs, ys)
	return function(x)
		for (i, ) in enumerate(xs[1:end-1])
			if x >= xs[i] && x <= xs[i+1]
				if i == length(xs)
					return ys[i]
				end
				return (ys[i+1] - ys[i])*(x - xs[i])/(xs[i+1] - xs[i]) + ys[i]
			end
		end
		if x < xs[1]
			return ys[1]
		else
			return ys[end]
		end
	end
end

function main()
	games = readCSV()
	elos, elohistory = calculateElos(games)

	elohistory = sort(collect(elohistory), lt=((a, b)->(!isless(elos[a[1]], elos[b[1]]))))

	p = plot(legend=:outerright, legend_column=3, legend_font_pointsize=4, size=(5000, 2500), yticks=200:100:2500)
	for (team, elohist) in elohistory
		if length(elohist) < 30
			continue
		end

		plot!((x -> x[1]).(elohist), (x -> x[2]).(elohist), label=team)

		println(team, ": ", elos[team])
	end

	savefig(p, "plot.pdf")
end

main()
