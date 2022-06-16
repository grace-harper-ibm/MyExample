
println(@__MODULE__)
import Pkg;
Pkg.add("ImageShow");
import Pkg;
Pkg.add("Colors");
using ImageShow, Colors


function mandel(z; maxiter=100)
    c = z
    for n in 1:maxiter
        if abs(z) > 2
            return (n - 1) / maxiter
        end
        z = z^2 + c
    end
    return 1
end

to_color(x) = Gray(1 - x)

domain(step=0.1) = (-2.5:step:1) .- ((-1.5:step:1.5)im)'


function make_mandel(vals)

    c = to_color.(mandel.(vals))
    return c
end
step = 0.005
length(domain(step))

make_mandel(domain(step))


