# export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
using TensorFlowDiffEq
using Base.Test

using Plots; plotly()
using DiffEqBase, ParameterizedFunctions

# Toy problem 1

f = (t,u) -> -u/5 + exp(-t/5).*cos(t)
(::typeof(f))(::Type{Val{:analytic}},t,u0) =  exp(-t/5)*(u0 + sin(t))
prob = ODEProblem(f,Float32(0.0),(Float32(0.0),Float32(2.0)))
sol = solve(prob,odetf(),dt=0.02)

plot(sol,plot_analytic=true)

# Problem 2

function lotka_voltera_tf(t,u)
  du1 = 1.5 .* u[:,1] - 1.0 .* u[:,1].*u[:,2]
  du2 = -3 .* u[:,2] + u[:,1].*u[:,2]
  [du1 du2]
end
prob = ODEProblem(lotka_voltera_tf,Float32[1.0,1.0],(Float32(0.0),Float32(100.0)))
sol = solve(prob,odetf(hl_width=256),dt=0.1,maxiters=Int(1e4),progress_steps=500)

plot(sol)

# Toy problem 3

function lorenz_tf(t,u)
    du1 = 10.0(u[:, 2]-u[:,1])
    du2 = u[:,1].*(28.0-u[:, 3]) - u[:, 2]
    du3 = u[:,1].*u[:,2] - (8/3)*u[:,3]

    [du1 du2 du3]
end
prob = ODEProblem(lorenz_tf,Float32[1.0,0.0,0.0],(Float32(0.0),Float32(100.0)))
sol = solve(prob,odetf(hl_width=256),dt=0.1,maxiters=Int(1e5),progress_steps=500)

plot(sol,vars=(1,2,3))

# Macro Usage

g = @ode_def LorenzExample begin
  dx = σ*(y-x)
  dy = x*(ρ-z) - y
  dz = x*y - β*z
end σ=10.0 ρ=28.0 β=(8/3)

# g.vector_ex and g.vector_ex_return are vectorized forms
# g(Val{:vec},t,u,du) and g(Val{:vec},t,u)
