using Test, GroupedArrays

p1 = repeat(1:5, inner = 2)


g1 = GroupedArray(p1)
@test eltype(g1) <: Int
@test size(g1) == (10,)
@test length(g1) == 10
@test g1[1] == 1
@test g1[1:2] == [1, 1]
@test g1[g1.<=1] == g1[[1, 1]] 
@test_throws ArgumentError g1[1] = 0
g1[1] = 10
@test g1.ngroups == 10



p1_missing = repeat([missing, 1, 2, 3, 4], inner = 2)
g1 = GroupedArray(p1_missing)
@test eltype(g1) == Union{Int, Missing}
@test size(g1) == (10,)
@test length(g1) == 10
@test g1[1] === missing
@test g1.refs[1] === 0
@test g1.ngroups == 4


p1_missing = repeat([missing, -5, -10, 100, -300], inner = 2)
g1 = GroupedArray(p1_missing)
@test eltype(g1) == Union{Int, Missing}
@test size(g1) == (10,)
@test length(g1) == 10
@test g1[1] === missing
@test g1.refs[1] === 0
@test g1[end] === g1[end-1]


p1_missing = repeat([missing, "a", "b", "c", "c"], inner = 2)
g1 = GroupedArray(p1_missing)
@test eltype(g1) == Union{Int, Missing}
@test size(g1) == (10,)
@test length(g1) == 10
@test g1[1] === missing
@test g1.refs[1] === 0

g1 = GroupedArray(p1_missing; coalesce = true)
@test g1[1] === 1
@test eltype(g1) <: Int


p2 = repeat(1:5, outer = 2)
g = GroupedArray(p1_missing, p2)
@test g[1] === missing
g[3] = missing
@test g[3] === missing

p3 = [1,2]
@test_throws DimensionMismatch GroupedArray(p1, p3)


p = [1 2; 1 2; 2 1]
g = GroupedArray(p)

using CategoricalArrays
g = GroupedArray(categorical(p1_missing), categorical(p2))
@test g[1] === missing

using PooledArrays
g = GroupedArray(PooledArray(p1_missing), PooledArray(p2))
@test g[1] === missing

g = GroupedArray(PooledArray(p1_missing), p2)
@test g[1] === missing


using DataAPI
refs = DataAPI.refarray(g)
pools = DataAPI.refpool(g)
invrefpools = DataAPI.invrefpool(g)
@test all(pools[refs] .=== g)
@test all(DataAPI.refvalue(g, refs[i]) === g[i] for i in 1:length(g))

for x in eachindex(pools)
	@test invrefpools[pools[x]] == x
end
@test get(invrefpools, missing, -1) == -1

pools[invrefpools[missing]] == missing
for ix in 1:g.ngroups
	pools[invrefpools[ix]] == ix
end

