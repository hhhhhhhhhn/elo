# Probability team i wins to team j
function pWin(i, j)
	return 1/(1 + 10^((elos[j] - elos[i])/400))
end

competitors = [
("Países Bajos", 2297.436729159807),
("Estados Unidos", 2184.8904907705937),

("Argentina", 2339.9189178351485),
("Australia", 2144.1681858206675),

("Japón", 2194.8028279958016),
("Croacia", 2191.104356193789),

("Brasil", 2405.7935911757095),
("Korea", 2199.171878957707),

("Francia", 2285.1992026133057),
("Polonia", 2121.498406414251),

("Inglaterra", 2263.7577142924233),
("Senegal", 2145.2707926979533),

("Morruecos", 2210.019917013342),
("España", 2314.023465842314),

("Portugal", 2280.479507606292),
("Suiza", 2189.3855532182474),
]

elos = [competitor[2] for competitor in competitors]

function probabilities(phase)
	if phase == 0
		return [1. for i in competitors]
	end
	lastPhaseProbabilities = probabilities(phase - 1)
	newPhase = []

	for team in 1:length(lastPhaseProbabilities)
		phaseProbability = reduce(+, [lastPhaseProbabilities[enemy]*pWin(team, enemy) for enemy in enemiesInPhase(team, phase)])
		push!(newPhase, phaseProbability *  lastPhaseProbabilities[team])
	end

	return newPhase
end

function enemiesInPhase(i, phase)
	filtered = filter(j -> (!(j in possibleEnemies(i, phase-1))), possibleEnemies(i, phase))
	return filtered
end

function possibleEnemies(i, phase)
	if phase < 1
		return []
	end

	bracketStartIndex = Int64(floor((i-1)/(2^phase))) * 2^phase
	bracketEndIndex = bracketStartIndex + 2^phase

	bracket = collect(Int64, bracketStartIndex+1:bracketEndIndex)

	return filter(j -> j != i, bracket)
end

for phase in 1:floor(Int, log2(length(competitors)))
	println("===== PARTIDO ", phase, " =====")
	for (i, prob) in enumerate(probabilities(phase))
		println(competitors[i][1], ": ", round(prob * 100, digits=2), "%")
	end
	println()
end
