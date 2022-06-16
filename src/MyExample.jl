# I'm frsher than a - 
hlen = 9
hno = 10
coreno = 4
hyperedges = Dict(tuple(rand([0, 1], 1, hlen)...) => rand() for _ in 1:hno)

# section hyperedges into groups of hlen/no_cores & put results distributions in a channel

##
stateful_iter = Iterators.Stateful(hyperedges)
##
function divide_dictionary(dictionary, hno, coreno)
    stateful_iter = Iterators.Stateful(dictionary)
    array_of_dicts = []
    elms_per_dict = ceil(hno / coreno)
    maxiter = floor(length(dictionary) / (elms_per_dict))

    for _ in 1:maxiter
        args = Dict(popfirst!(stateful_iter) for _ in 1:elms_per_dict)
        println(args)
        push!(array_of_dicts, args)
    end
    remainingno = length(stateful_iter)
    args = Dict(popfirst!(stateful_iter) for _ in 1:remainingno)
    push!(array_of_dicts, args)
    return array_of_dicts
end

p = divide_dictionary(hyperedges, hno, coreno)
totno = 0
for elm in (p)
    totno += length(elm)
    println("like can you just not?")
    println(elm)
end
println(totno == length(hyperedges))

# const results = Channel{Tuple{Int,Float64}}(32);

# pull from channel every two and start a new thread merging them until channel is empty and all other threads have died 


