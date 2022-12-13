using BLPLogit
using Test
using LinearAlgebra, Distributions, Random,UnPack
@testset "BLPLogit.jl" begin
    # Write your tests here.
end

struct BLPparameters
    T::Int64
    J::Int64
    I::Int64
    σ::AbstractVector
    α::Float64
    β::AbstractVector
end

pa= BLPparameters(10,10,10,[-1,2,1],1,[1,1,1])



function simlate_utility(pa::BLPparameters)
    @unpack T,J,I,σ,α,β = pa
    ϵ= rand(Logistic(),J*T*I)
    mvnormalchar= MvNormal(zeros(length(β)), Array(Diagonal(ones(length(β)))));
    char = rand(mvnormalchar,J*T)'
    p = rand(Normal(0,1),J*T)
    ξ = rand(Normal(0,1),J*T)
    δ = reshape(-α .*p + char*β + ξ, J,T)
    mvnormalv= MvNormal(zeros(length(σ)), Array(Diagonal(ones(length(σ)))));
    v = rand(mvnormalv,I)'
    U = zeros(T,J,I)

    pchar = hcat(p, char[:,1:length(σ)-1])
    ϵm =  reshape(ϵ,I,J,T)
    for i in 1:T
        for j in 1:J
            for t in 1:I
                 U[i,j,t]= δ[j,t] + sum( σ .* v[i,:]' .* pchar[(j-1)*T + t, :]) + ϵm[i,j,t]
            end
        end
    end


    return (p, char, U) = (p, char, U)
end

A = simlate_utility(pa::BLPparameters)
A[3]

function simulate_BLP(pa::BLPparameters)
    U = simlate_utility(pa::BLPparameters)[3]
    @unpack T,I = pa
    c = zeros(I,T)
    for i in 1:I
        for t in 1:T
        c[i,t] = findmax(U[i,:,t])[2]
        end 
    end 
    return (p= A[1],char=A[2] ,c=c)
end

simulate_BLP(pa)[3]




