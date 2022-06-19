import MyExample
using Test


@testset "divide_dictionary" begin
    function check_division(dictionary, hno, coreno, size1, size2)
        res = MyExample.divide_dictionary(dictionary, hno, coreno)

        # check that all keys in dictionary made it into res 
        full_key_set = Set()
        for cdict in res
            for k in keys(cdict)
                push!(full_key_set, k)
            end
        end
        for key in keys(dictionary)
            @test key in full_key_set
        end

        # check that correct number of dictionary entires exist 
        num_tot = 0
        for hdict in res
            hlen = length(hdict)
            num_tot += hlen
            @test hlen == size1 || hlen == size2
            # test that correct values for keys were kept 
            for h in keys(hdict)
                @test hdict[h] == dictionary[h]
            end
        end
        @test num_tot == length(dictionary)
    end
    # should have leftover hyperedge
    dictionary = Dict(
        (0, 0) => 0.1,
        (0, 1) => 0.2,
        (1, 0) => 0.3,
        (1, 1) => 0.4,
    )

    check_division(dictionary, 4, 4, 1, 1)
    check_division(dictionary, 4, 3, 2, 1)
    check_division(dictionary, 4, 2, 2, 2)
    check_division(dictionary, 4, 1, 4, 4)
end

@testset "update" begin
    init_distribution = Dict((0, 0) => 1.0)
    hyperedge1 = ((0, 1), 0.5)
    distribution2 = MyExample.update(init_distribution, hyperedge1)

    @test distribution2 == Dict((0, 1) => 0.5, (0, 0) => 0.5)

    hyperedge2 = ((1, 1), 0.25)
    distribution3 = MyExample.update(distribution2, hyperedge2)
    @test distribution3 == Dict(
        (0, 1) => 0.375,
        (1, 0) => 0.125,
        (1, 1) => 0.125,
        (0, 0) => 0.375
    )

    # Test an example where a hyperedge generates a preexisting key 
    hyperedge1_repeat = ((0, 1.0), 0.5)
    distribution4 = MyExample.update(distribution2, hyperedge1_repeat)
    @test distribution4 == Dict(
        (0, 0) => 0.5,
        (0, 1) => 0.5
    )
end


@testset "test build_distribution" begin
    hyperedges = Dict(
        (0, 1) => 0.5,
        (1, 1) => 0.25
    )
    distribution = Dict(
        (0, 1) => 0.375,
        (1, 0) => 0.125,
        (1, 1) => 0.125,
        (0, 0) => 0.375
    )

    @test MyExample.build_distribution(hyperedges, 2) == distribution

    hyperedges2 = Dict(
        (0, 1) => 0.1,
        (1, 0) => 0.2,
        (1, 1) => 0.3
    )

    distribution2 = Dict(
        (1, 1) => 0.23,
        (1, 0) => 0.15,
        (0, 1) => 0.11,
        (0, 0) => 0.51
    )
    println("TWO")
    @test MyExample.build_distribution(hyperedges2, 2) == distribution2



end

@testset "build_mini_distribution_array" begin
    mini_dicts = [
        Dict(
            (0, 1) => 0.5,
            (1, 1) => 0.25
        ),
        Dict(
            (0, 1) => 0.1,
            (1, 0) => 0.2,
            (1, 1) => 0.3
        )
    ]

    distribution = Dict(
        (0, 1) => 0.375,
        (1, 0) => 0.125,
        (1, 1) => 0.125,
        (0, 0) => 0.375
    )
    distribution2 = Dict(
        (1, 1) => 0.23,
        (1, 0) => 0.15,
        (0, 1) => 0.11,
        (0, 0) => 0.51
    )

    mini_distribution_arry = MyExample.build_mini_distribution_array(mini_dicts, 2)
    for distr in mini_distribution_arry
        @test distr == distribution || distr == distribution2
    end

end

# TEST merge 2 dicts 

@testset "merge_two_dicts" begin
    distribution1 = Dict(
        (0, 1) => 0.375,
        (1, 0) => 0.125,
        (1, 1) => 0.125,
        (0, 0) => 0.375
    )

    distribution2 = Dict(
        (0, 1) => 0.15,
        (0, 0) => 0.85
    )

    final_distribution = Dict(
        (0, 0) => 0.375,
        (1, 1) => 0.125,
        (0, 1) => 0.375,
        (1, 0) => 0.125
    )

    @test MyExample.merge_two_dicts(distribution1, distribution2) == final_distribution

end

@testset "Full Run" begin
    hyperedges = Dict(
        (0, 1) => 0.075,
        (1, 0) => 0.125,
        (1, 1) => 0.125,
        (0, 0) => 0.375
    )
    hlen = 2

    final_distribution = Dict(
        (0, 0) => 0.709375,
        (1, 1) => 0.109375,
        (0, 1) => 0.071875,
        (1, 0) => 0.109375
    )

    function full_run(hyperedges, hno, coreno, hlen, final_distribution)
        mini_dicts = MyExample.divide_dictionary(hyperedges, hno, coreno)
        mini_distr = MyExample.build_mini_distribution_array(mini_dicts, hlen)
        final_distr = MyExample.merge_distribution(mini_distr)

        @test final_distr == final_distribution

    end

    full_run(hyperedges, 4, 4, 2, final_distribution)
    full_run(hyperedges, 4, 3, 2, final_distribution)
    full_run(hyperedges, 4, 2, 2, final_distribution)
    full_run(hyperedges, 4, 1, 2, final_distribution)



end
