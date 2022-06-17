# I'm frsher than a - 
hlen = 9
hno = 10
coreno = 4
hyperedges = Dict(tuple(rand([0, 1], 1, hlen)...) => rand() for _ in 1:hno)

# section hyperedges into groups of hlen/no_cores & put results distributions in a channel
function divide_dictionary(dictionary, hno, coreno) #unimportant for here but in the future,  anyway to yield dictionary instead of literally copying the whole thing? 
    stateful_iter = Iterators.Stateful(dictionary)
    elms_per_dict = ceil(hno / coreno)
    maxiter = floor(length(dictionary) / (elms_per_dict))

    array_of_dicts = [Dict(popfirst!(stateful_iter) for _ in 1:elms_per_dict) for _ in 1:maxiter]
    args = Dict(stateful_iter)
    push!(array_of_dicts, args)

    return array_of_dicts
end


# pull from channel every two and start a new thread merging them until channel is empty and all other threads have died 
mini_dicts = divide_dictionary(hyperedges, hno, coreno)


function fake_build_distribution(dictionary, i)
    println("length of dictionary is: $(length(dictionary))")
    print(i)
    return dictionary
end
fake_channel = []

using FLoops

ys = zeros(8)
xs = [i for i in 1:8]
function f(x)
    sleep(5)
    println("hello", x)
    return x^2
end
@floop for i in eachindex(ys, xs)
    ys[i] = f(xs[i])
end
print(ys)

@floop for i in 1:10
    sleep(1)
    println(i)
end


const to_merge_channel = Channel{Dict{NTuple{hlen,Int64},Float64}}(32);

@floop for (indx, mini_dict) in enumerate(mini_dicts)
    println(indx)
    put!(to_merge_channel, fake_build_distribution(mini_dict, indx))
end


print(to_merge_channel)
for elm in to_merge_channel
    print(elm)
end



# TODO probably need to find a way to not "pass" matrices but to lock the reference 




