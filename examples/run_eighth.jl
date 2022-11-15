using Oceananigans
using Oceananigans.Units
using WenoNeverworld

output_dir    = joinpath(@__DIR__, "../files_eight")
@show output_prefix = output_dir * "/neverworld_eighth"

H = 5

arch   = GPU()
old_degree = 1/4
new_degree = 1/8

orig_grid = neverworld_grid(arch, old_degree; H)
grid      = neverworld_grid(arch, new_degree; H)

# Remember to pass init file if we want to interpolate!
interp_init = false
init_file   = nothing
init        = true

# init always has to be true with interp_init
init = inter_init ? true : init

# Simulation parameters
Δt        = 2.5minutes
stop_time = 2years

# Construct the neverworld simulation
simulation = weno_neverworld_simulation(; grid, orig_grid, Δt, stop_time, interp_init, init_file)

# Increase simulation Δt after 40days
increase_simulation_Δt!(simulation, cutoff_time = 50days, new_Δt = 4minutes)

# Let's goo!
@info "Running with Δt = $(prettytime(simulation.Δt))"

# Add outputs
checkpoint_time = 0.5years
standard_outputs!(simulation, output_prefix; checkpoint_time)

# initializing the time for wall_time calculation
run_simulation!(simulation; init, init_file)