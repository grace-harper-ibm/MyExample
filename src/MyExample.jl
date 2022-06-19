# I'm frsher than a - 

module (MyExample)
using FLoops
using Revise

# section hyperedges into groups of hlen/no_cores & put results distributions in a channel
function divide_dictionary(dictionary, hno, coreno) #TODO unimportant for here but in the future,  anyway to yield dictionary instead of literally copying the whole thing? 
    stateful_iter = Iterators.Stateful(dictionary)
    elms_per_dict = ceil(hno / coreno) # TODO how much can this inexact mess us up?
    maxiter = floor(length(dictionary) / (elms_per_dict))

    array_of_dicts = [Dict(popfirst!(stateful_iter) for _ in 1:elms_per_dict) for _ in 1:maxiter]
    args = Dict(stateful_iter)
    if length(args) != 0
        push!(array_of_dicts, args)
    end

    return array_of_dicts
end
function update(distribution, hyperedge)
    (v, p) = hyperedge

    newdict = typeof(distribution)()
    for (hedge, opval) in distribution
        # don't add
        if hedge in keys(newdict)
            newdict[hedge] += round(opval * (1 - p), digits=6)
        else
            newdict[hedge] = round(opval * (1 - p), digits=6)
        end
        # add 
        newk = tuple([(hedge[i] + v[i]) % 2 for i in 1:length(hedge)]...)

        if newk in keys(newdict)
            newdict[newk] += round(opval * p, digits=6)
        else
            newdict[newk] = round(opval * p, digits=6)
        end
    end

    return newdict
end
function build_distribution(mini_dictionary, hyperedge_length)
    distribution = Dict(tuple(zeros(hyperedge_length)...) => 1.0)
    for (hyperedge, prob) in mini_dictionary
        distribution = update(distribution, (hyperedge, prob))
        println("mydistribution:$(distribution)")
    end
    return distribution
end

function build_mini_distribution_array(mini_dicts, hyperedge_length)
    if length(mini_dicts) == 0
        return []
    end
    mini_distributions = similar(mini_dicts, length(mini_dicts))# is it faster to instantiate this outside of function and pass reference to?
    @floop for (indx, mini_dict) in enumerate(mini_dicts)
        mini_distributions[indx] = build_distribution(mini_dict, hyperedge_length)
    end
    return mini_distributions
end

function merge_two_dicts(dict1, dict2)
    merged = typeof(dict1)()
    for (k1, v1) in dict1
        for (k2, v2) in dict2
            new_key = tuple([(id1 + id2) % 2 for (id1, id2) in zip(k1, k2)]...)
            if !(new_key in keys(merged))
                merged[new_key] = v1 * v2
            else
                merged[new_key] += v1 * v2
            end
        end
    end
    return merged
end

@views function merge_distribution(mini_distributions)
    if length(mini_distributions) == 1
        return mini_distributions[1]
    elseif length(mini_distributions) == 2
        return merge_two_dicts(mini_distributions[1], mini_distributions[2])
    else
        mid = Int64(floor(length(mini_distributions) / 2))
        m1 = merge_distribution(mini_distributions[1:mid])
        m2 = merge_distribution(mini_distributions[mid+1:end])
        return merge_two_dicts(m1, m2)
    end
end


# hlen = 9
# hno = 10
# coreno = 4
# hyperedges = Dict(tuple(rand([0, 1], 1, hlen)...) => rand() for _ in 1:hno)

# mini_dicts = divide_dictionary(hyperedges, hno, coreno)
# mini_distr_array = build_mini_distribution_array(mini_dicts)
# @views new_distr = merge_distribution(mini_distr_array[1:end])

hyperedges2 = Dict(
    (0, 1) => 0.1,
    (1, 0) => 0.2,
    (1, 1) => 0.3
)
build_distribution(hyperedges2, 2)


# test_mini = [Dict(tuple(zeros(hlen)...) => 1.0), Dict(tuple(ones(hlen)...) => 0.5, tuple(zeros(hlen)...) => 0.5), Dict(tuple(zeros(hlen)...) => 1.0)]







# ############## for more complicated parallelism 
# ##################### DIVIDING and CHANNELING original hyperedges

# function build_mini_distributions(c::Channel)
#     mini_dicts = divide_dictionary(hyperedges, hno, coreno)
#     @floop for (indx, mini_dict) in enumerate(mini_dicts)
#         put!(c, build_distribution(mini_dict))
#     end
#     sleep(10)
#     close(c)

# end

# function build_mini_distributions_channel(mini_dicts, ch)
#     @floop for (indx, mini_dict) in enumerate(mini_dicts)
#         put!(ch, build_distribution(mini_dict))
#     end
#     close(ch)
# end
# mini_distr_ch = Channel{Dict}(30)
# task = @async build_mini_distributions_channel(mini_dicts, mini_distr_ch)
# errormonitor(task)

# #################### ONGOING MERGING PIECES 
# # Hacky way to make sure channel closes when all threads finish

# ### PRIMARY FLOW  
# # ... have this function also async, puling from to_merge_dict, 
# # see if make closing of (to_merge_dict_chan) based on (closing(Channel(build_mini_distribution)) and all threads using merge channel finished)...
# # TODO probably need to find a way to not "pass" matrices but to lock the reference


# input_args = []
# to_merge_channel = Channel{Dict{NTuple{hlen,Int64},Float64}}(32);
# thread_channel = Channel()
# merging_tasks = []
# # try making this async, putting stuff into to_merge_dict_chan and later ...
# for distr in mini_distr_ch
#     if length(input_args) < 2
#         push!(input_args, distr)
#     else
#         new_merge_thread = @async begin
#             put!(to_merge_channel, merge_two_dicts(args...))  # TODO make this async w/ FUTURES 
#         end
#         put!(thread_channel, new_merge_thread)
#         input_args = []
#     end
# end

# if len(input_args > 0) # needn't worry about channel closing early bc that's not kicked off until continual_merging is called. 
#     put!(to_merge_channel, input_args[0])
# end

# final_distribution = continual_merging()



# function close_merge_channel()
#     while (!isempty(mini_dict_chan))
#     end
#     while !isempty(thread_channel)
#         wait(take!(thread_channel))
#     end
#     # mini_dict_chan is empty and thrad_channel is empty 
#     close(thread_channel)
#     close(to_merge_channel)
# end


# function continual_merging()
#     future_end = close_merge_channel()
#     while () # Future future_end is not done 
#         # take 
#         # take 
#         # async merge & put 
#         # take1 = None 
#         # take2 = None 
#     end
#     if () # take1 or tak2 is nonzero 
#         # put! take1/take2 
#         md1 = merge(take1, take2)
#     else
#         md1 = take!(to_merge_channel)
#     end

#     for mdict in to_merge_channel
#         md1 = merge_two_dicts(md1, mdict)
#     end
#     return md1

# end


# function finish_merging(to_merge_channel::Channel)
#     if isempty(to_merge_channel)
#         Base._throw_not_readable
#     end

# end



# ############## for more complicated parallelism 




























# ############# can't collapse
# """
# # # converting to channels/tasks paradigm 
# # mini_dicts = divide_dictionary(hyperedges, hno, coreno)
# # ######
# # c = Channel(30)

# # task_handler_1 = @async begin
# #     sleep(3)
# #     for i in 1:10
# #         put!(c, 1)
# #     end
# # end

# # task_handler_2 = @async begin
# #     sleep(10)
# #     for i in 1:10
# #         put!(c, 2)
# #     end
# # end

# # errormonitor(task_handler_1)
# # errormonitor(task_handler_2)

# # my_task_handler_array = [task_handler_1, task_handler_2]
# # wait_for_tasks_to_finish = @async begin
# #     for task in my_task_handler_array
# #         wait(task)
# #     end
# # end

# # bind(c, wait_for_tasks_to_finish)

# # for i in c
# #     @show i
# # end
# # ########### why 


# c = Channel(30)
# task_handler_array = []

# for minidict in divide_dictionary(hyperedges, hno, coreno)
#     push!(task_handler_array, @async begin
#         put!(c, build_distribution(mini_dict))
#     end)
# end

# wait_for_tasks_to_finish = @async begin
#     [(wait(task), errormonitor(task)) for task in task_handler_array] # TODO does errormonitor work here? 
# end;
# bind(c, wait_for_tasks_to_finish)

# for i in c
#     @show i
# end

# ####
# """

# function build_mini_distributions_channel(mini_dicts)
#     ch = Channel{Dict}(30)
#     @floop for (indx, mini_dict) in enumerate(mini_dicts)
#         put!(ch, build_distribution(mini_dict))
#     end
#     close(ch)
#     return ch
# end

# mini_distr_ch = build_mini_distributions_channel(mini_dicts)
# for i in mini_distr_ch
#     @show i
# end











# ########################## VIEW  fun 

# @views function changeme(arr)
#     if length(arr) == 1
#         arr[1] = "CHANGED"
#         return "cheese"
#     end
#     arr[1] = "changing"
#     return changeme(arr[2:end])
# end


# math = []
# for i in 2:7
#     push!(math, i)
# end
# push!(math, 1)
# @views changeme((math[1:end]))
# println(math)


end