using Oceananigans
using Oceananigans.Units
using WenoNeverworld

output_dir    = joinpath(@__DIR__, "../files_four_vorticity_stencil/")
@show output_prefix = output_dir * "/neverworld_quarter_vorticity"

arch   = GPU()
old_degree = 1/4
new_degree = 1/4

orig_grid = NeverworldGrid(arch, old_degree)
grid      = NeverworldGrid(arch, new_degree)

# Remember to pass init file if we want to interpolate!
interp_init = false
init_file   = "files_four/neverworld_quarter_checkpoint_iteration172480.jld2"

# init always has to be true with interp_init, otherwise it depends if we start from a file or not
init = interp_init ? true : (init_file isa Nothing ? true : false)

# Simulation parameters
Δt        = 10minutes
stop_time =  2years

using Oceananigans.Advection: VorticityStencil

momentum_advection = WENO(vector_invariant = VorticityStencil())

# Construct the neverworld simulation
simulation = weno_neverworld_simulation(; grid, orig_grid, Δt, momentum_advection, stop_time, interp_init, init_file)

# Let's goo!
@info "Running with Δt = $(prettytime(simulation.Δt))"

# Add outputs
checkpoint_time = 1year
standard_outputs!(simulation, output_prefix; checkpoint_time)

# initializing the time for wall_time calculation
run_simulation!(simulation; init, init_file)
