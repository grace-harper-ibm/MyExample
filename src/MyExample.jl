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


# TODO: We could simplify the API here, because reusing dict doesnt work
# and is unlikely to help much anyway.
function update(distribution, hyperedge)
    (v, p) = hyperedge
    newdict = typeof(distribution)()
    for (hedge, opval) in distribution
        # don't add
        if hedge in keys(newdict)
            newdict[hedge] += opval * (1 - p)
        else
            newdict[hedge] = opval * (1 - p)
        end

        # add 
        newk = tuple([(hedge[i] + v[i]) % 2 for i in 1:length(hedge)]...)

        if newk in keys(newdict)
            newdict[newk] += opval * p
        else
            newdict[newk] = opval * p
        end
    end
    return newdict
end


function build_distribution(mini_dictionary)
    distribution = Dict(tuple(zeros(hlen)...) => 1.0)
    for (hyperedge, prob) in mini_dictionary
        distribution = update(distribution, (hyperedge, prob))
    end
    return distribution
end

hlen = 2
test_dict = Dict(zeros(hlen) => 0.5, ones(hlen) => 0.5, (1, 0) => 0.5)

println(build_distribution(test_dict))

using FLoops

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




