
using Base

print("THrORNS")

##
struct BarPNG end
Base.show(io::IO, ::MIME"image/png", ::BarPNG) =
    print(io, read(joinpath(@__DIR__, "assets", "jungseohyun.webp"), String))

BarPNG()
##

