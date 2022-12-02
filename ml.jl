using Flux

m = Chain(RNN(2 => 5), Dense(5 => 1))

function loss(x, y)
	Flux.reset!(m)
	sum(mse(m(xi), yi) for (xi, yi) in zip(x, y))
end

seq_init = [rand(Float32, 2)]
seq_1 = [rand(Float32, 2) for i = 1:3]
seq_2 = [rand(Float32, 2) for i = 1:3]

y1 = [rand(Float32, 1) for i = 1:3]
y2 = [rand(Float32, 1) for i = 1:3]

X = [seq_1, seq_2]
Y = [y1, y2]
data = zip(X,Y)

Flux.reset!(m)
[m(x) for x in seq_init]

ps = Flux.params(m)
opt= Adam(1e-3)
Flux.train!(loss, ps, data, opt)
