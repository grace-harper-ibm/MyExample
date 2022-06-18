import MyExample
using Test

@testset "MyExample.jl" begin
    # Write your tests here.
    @testset begin
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
                println("hlen: $(hlen) w/ size1: $(size1), and size2: $(size2)")
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
end






# TEST merge dicts 

# TEST mini dict 

# TEST full process 
