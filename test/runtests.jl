using Test, GroupedArrays

p1 = repeat(1:5, inner = 2)
p1_missing = repeat([missing, 1, 2, 3, 4], inner = 2)
p2 = repeat(1:5, outer = 2)


g1 = GroupedArray(p1)
@test eltype(g1) <: Int
@test size(g1) == (10,)
@test length(g1) == 10
@test g1[1] == 1
@test g1[1:2] == [1, 1]
@test g1[g1.<=1] == g1[[1, 1]] 
@test_throws ArgumentError g1[1] = 0
g1[1] = 10
@test g1.n == 10



p1_missing = repeat([missing, 1, 2, 3, 4], inner = 2)
g1 = GroupedArray(p1_missing)
@test eltype(g1) <: Union{Int, Missing}
@test size(g1) == (10,)
@test length(g1) == 10
@test g1[1] === missing
@test g1.refs[1] === 0

p1_missing = repeat([missing, "a", "b", "c", "c"], inner = 2)
g1 = GroupedArray(p1_missing)
@test eltype(g1) <: Union{Int, Missing}
@test size(g1) == (10,)
@test length(g1) == 10
@test g1[1] === missing
@test g1.refs[1] === 0


p2 = repeat(1:5, outer = 2)
g = GroupedArray(p1_missing, p2)
g[1] == 0


using CategoricalArrays
g = GroupedArray(categorical(p1), categorical(p2))

using PooledArrays
g = GroupedArray(PooledArray(p1), PooledArray(p2))





p3 = [1,2]
@test_throws DimensionMismatch GroupedArray(p1, p3)