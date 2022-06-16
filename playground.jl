
# # using Base
# print("THrORNS")

# ##
# struct BarPNG end
# Base.show(io::IO, ::MIME"image/png", ::BarPNG) = print(io, read(joinpath(@__DIR__, "assets", "jungseohyun.webp"), String))

import Fatou
using PyPlot
c = -0.06 + 0.67im
nf = Fatou.juliafill(:(z^2 + $c), ∂=[-1.5, 1.5, -1, 1], N=80, n=1501, cmap="gnuplot", iter=true)
nf

pygui(false)
figure()
plot(Fatou.fatou(nf), bare=true)
display(gcf())

##

