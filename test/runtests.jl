import MyExample
using Test

@testset "myf.jl" begin
    # Write your tests here.

    @test MyExample.myf(2, 1) == 7
    @test MyExample.myf(2, 2) == 10
end

@testset "Derivatives test" begin
    @test MyExample.deriv_my_f(2, 1) = 2

end