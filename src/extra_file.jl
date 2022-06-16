import ForwardDiff
myf(x, y) = 2x + 3y

deriv_my_f(x, y) = ForwardDiff.derivative(x -> myf(x, y), x)
