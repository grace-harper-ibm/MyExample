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
test_mini = [Dict(zeros(hlen) => 0.5, ones(hlen) => 0.5, (1, 0) => 0.5) for _ in 1:12]

using FLoops
to_merge_channel = Channel{Dict{NTuple{hlen,Int64},Float64}}(32);


function build_mini_distributions(c::Channel)
    mini_dicts = divide_dictionary(hyperedges, hno, coreno)
    @floop for (indx, mini_dict) in enumerate(mini_dicts)
        put!(c, build_distribution(mini_dict))
    end
    sleep(10)
    close(c)

end

#     mini_dicts = divide_dictionary(hyperedges, hno, coreno)
# function build_mini_distributions_channel(mini_dicts)
#     ch = Channel{Any}()
#     @floop for (indx, mini_dict) in enumerate(mini_dicts)
#         put!(ch, build_distribution(mini_dict))
#     end
# end

function merge_two_dicts(dict1, dict2)
    merged = typeof(dict1)()
    for (k1, v1) in dict1
        for (k2, v2) in dict2
            new_key = tuple([id1^id2 for (id1, id2) in zip(k1, k2)]...)
            if new_key
                not in keys(merged)
                merged[new_key] = v1 * v2
            else
                merged[new_key] += v1 * v2
            end
        end
    end
    return merged
end


input_args = []
to_merge_dict_chan = []

# try making this async, putting stuff into to_merge_dict_chan and later ...
for distr in Channel(build_mini_distributions)
    if length(input_args) < 2
        push!(input_args, distr)
    else
        push!(to_merge_dict_chan, merge_two_dicts(args...))  # TODO make this async 
        input_args = []

    end
end

# ... have this function also async, puling from to_merge_dict, 
# see if make closing of (to_merge_dict_chan) based on (closing(Channel(build_mini_distribution)) and merge_)...

# Maybe instead just creating channels until you get a channel that closes having produced only 1 dict? 


# TODO probably need to find a way to not "pass" matrices but to lock the reference 







t = @task begin
    sleep(10)
    println("TASKING")
end

t1 = @task begin
    sleep(1)
    for i in 1:20
        sleep(1)
        println("running: ", i)
    end
end

@async begin
    print("in my head")
    for i in 1:10
        print(i, " ")
    end
end

for i in 1:10
    @async begin
        sleep(5)
        println("I've got to go! ")
    end
end