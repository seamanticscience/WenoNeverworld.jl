const Lz   = 4000
const Ly   = 70
const h    = 1000.0
const ΔB   = 6.0e-2 
const ΔT   = 30.0
const fact = 5.0

"""
    function zonal_wind_stress(y, mid_wind)

returns the zonal wind as per https://egusphere.copernicus.org/preprints/2022/egusphere-2022-186/egusphere-2022-186.pdf
as a function of latitude `y`
"""
@inline function zonal_wind_stress(y)
    if y < -45
        return cubic_profile(y, -70.0, -45.0, 0.0, 0.2, 0.0, 0.0)
    elseif y < -15
        return cubic_profile(y, -45.0, -15.0, 0.2, -0.1, 0.0, 0.0)
    elseif y < 0
        return cubic_profile(y, -15.0, 0.0, -0.1, -0.02, 0.0, 0.0)
    elseif y < 15
        return cubic_profile(y, 0.0, 15.0, -0.02, -0.1, 0.0, 0.0)
    elseif y < 45
        return cubic_profile(y, 15.0, 45.0, -0.1, 0.1, 0.0, 0.0)
    else
        return cubic_profile(y, 45.0, 70.0, 0.1, 0.0, 0.0, 0.0)
    end
end

@inline exponential_profile(z; Δ = ΔB, Lz = Lz, h = h) = ( Δ * (exp(z / h) - exp( - Lz / h)) / (1 - exp( - Lz / h)) )

@inline parabolic_scaling(y) = - 1 / 70^2 * y^2 + 1
@inline atan_scaling(y)      = (atan(fact*((Ly + y)/Ly - 0.5)) / atan(fact * 0.5) + 1) /2

@inline initial_buoyancy_tangent(x, y, z)  = exponential_profile(z) * atan_scaling(y)
@inline initial_buoyancy_parabola(x, y, z) = exponential_profile(z) * parabolic_scaling(y) 

@inline initial_temperature_parabola(x, y, z) = exponential_profile(z; Δ = ΔT) * parabolic_scaling(y)

@inline function initial_salinity(y, mid_salinity)
    if y < -20
        return cubic_profile(y, -70.0, -20.0, 34.0, 37.0, 0.0, 0.0)
    elseif y < 0
        return cubic_profile(y, -20.0, 0.0, 37.0, 35.0, 0.0, 0.0)
    elseif y < 20
        return cubic_profile(y, 0.0, 20.0, 35.0, 37.0, 0.0, 0.0)
    else
        return cubic_profile(y, 20.0, 70.0, 37.0, 34.0, 0.0, 0.0)
    end
end


"""
    function salinity_flux(y)

returns the salinity flux as a function of latitude `y` 
(similar to https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2020gl089135)
"""
@inline function salinity_flux(y, mid_flux)
    if y < -20
        return cubic_profile(y, -70.0, -20.0, -2e-8, 2e-8, 0.0, 0.0) .* 35.0
    elseif y < 0
        return cubic_profile(y, -20.0, 0.0, 2e-8, -4e-8, 0.0, 0.0) .* 35.0
    elseif y < 20
        return cubic_profile(y, 0.0, 20.0, -4e-8, 2e-8, 0.0, 0.0) .* 35.0
    else
        return cubic_profile(y, 20.0, 70.0, 2e-8, -2e-8, 0.0, 0.0) .* 35.0
    end
end

