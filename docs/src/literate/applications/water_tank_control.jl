# # Water tank level control
#
# This example shows how to use `FuzzyLogic.jl` to design a fuzzy
# controller for a single water tank. The goal is to keep the water level
# close to a desired reference by adjusting the inlet flow using a fuzzy
# rule base.
#
# !!! tip "Try it yourself!"
#     Read this as Jupyter notebook [here](https://nbviewer.org/github/lucaferranti/FuzzyLogic.jl/blob/gh-pages/dev/notebooks/water_tank_control.ipynb)
#
# ## Plant model
#
# We consider a simple first-order model. The state of the system is the
# water level `h`. The inlet flow `q_in` is our control input, while the
# outlet flow is proportional to the current water level:
#
# ```math
# \dot h(t) = \frac{1}{A} \bigl(q_{\text{in}}(t) - k_\text{out} h(t)\bigr)
# ```
#
# where `A` is the tank cross-section and `k_out` is an outflow
# coefficient. We simulate the model in discrete time using forward Euler
# integration.
#
# We define a small helper function to simulate one time step of the
# plant.

using FuzzyLogic
using Plots

# Tank parameters
const A_tank = 1.0     # [m^2] cross-section
const k_out = 0.5     # [1/s] outflow coefficient
const q_in_max = 1.0    # [m^3/s] maximum inlet flow

"""
    step_tank(h, u; dt) -> h_next

Simulate one time step of the water tank.

- `h`   : current water level
- `u`   : control signal in [0, 1] (valve opening)
- `dt`  : time step

Returns the new water level `h_next`.
"""
function step_tank(h::Float64, u::Float64; dt::Float64)
    q_in = q_in_max * clamp(u, 0.0, 1.0)
    q_out = k_out * max(h, 0.0)
    dh = (q_in - q_out) / A_tank
    h_new = h + dt * dh
    return max(h_new, 0.0)
end

# ## Fuzzy controller design
#
# We design a Mamdani-type fuzzy controller with:
#
# - Inputs
#   * `e`  : level error, `e = h_ref - h`
#   * `de` : change of error, `de = e - e_prev`
# - Output
#   * `u`  : valve opening (normalized in [0, 1])
#
# The intuition is:
#
# - If the level is much lower than the reference (`e` large positive),
#   the valve should be opened almost fully.
# - If the level is higher than the reference (`e` negative), the valve
#   should be almost closed.
# - If the level is close to the reference, the action depends on whether
#   we are approaching the setpoint or moving away from it (`de`).
#
# We implement the controller using the `@mamfis` macro.
fis = @mamfis function water_tank_controller(e, de)::u
    e := begin
        domain = -1:1

        PVS = ZShapeMF(-1.0, -0.666)                    # very small positive
        PS = GaussianMF(-0.5, 0.333)            # small
        PM = GaussianMF(0.0, 0.333)         # medium
        PL = GaussianMF(0.5, 0.333)           # large
        PVL = SShapeMF(0.666, 1.0)                    # very large
    end

    de := begin
        domain = -1:1

        VDN = ZShapeMF(-1.0, -0.666)                   # very decreasing
        DN = GaussianMF(-0.5, 0.333)          # slightly decreasing
        DZ = GaussianMF(0.0, 0.333)            # roughly constant
        DP = GaussianMF(0.5, 0.333)           # slightly increasing
        VDP = SShapeMF(0.666, 1.0)                     # very increasing
    end

    u := begin
        domain = 0:1

        Close = ZShapeMF(0.00, 0.166)
        Small = GaussianMF(0.25, 0.166)
        Medium = GaussianMF(0.5, 0.166)
        Large = GaussianMF(0.75, 0.166)
        Full = SShapeMF(0.833, 1.00)
    end

    e == PVL && de == VDN --> u == Full
    e == PVL && de == DN --> u == Full
    e == PVL && de == DZ --> u == Full
    e == PVL && de == DP --> u == Large
    e == PVL && de == VDP --> u == Large

    e == PL && de == VDN --> u == Full
    e == PL && de == DN --> u == Full
    e == PL && de == DZ --> u == Large
    e == PL && de == DP --> u == Medium
    e == PL && de == VDP --> u == Medium

    e == PM && de == VDN --> u == Large
    e == PM && de == DN --> u == Large
    e == PM && de == DZ --> u == Medium
    e == PM && de == DP --> u == Small
    e == PM && de == VDP --> u == Small

    e == PS && de == VDN --> u == Medium
    e == PS && de == DN --> u == Small
    e == PS && de == DZ --> u == Small
    e == PS && de == DP --> u == Close
    e == PS && de == VDP --> u == Close

    e == PVS --> u == Close
end

# Plot the fuzzy system and its membership functions.
plot(fis, size = (800, 400))

plot(plot(fis, :e, size = (400, 300)),
    plot(fis, :u, size = (400, 300)),
    layout = (1, 2))

# ## Closed-loop simulation
#
# We now simulate the closed-loop system composed of the water tank model
# and the fuzzy controller. We consider a unit step in the reference
# level: the level should rise from 0 to 1 and stay close to 1 without
# excessive overshoot.
let dt = 0.01,            # [s] time step
    t_final = 60.0,       # [s] total simulation time
    h_ref = 1.0

    n_steps = Int(round(t_final / dt))

    time = collect(0:n_steps) .* dt
    h_log = similar(time)
    u_log = similar(time)

    h = 0.0
    e_prev = h_ref - h

    for k in eachindex(time)
        e = h_ref - h
        de = e - e_prev

        u_val = fis(e = e, de = de)[:u]
        h_next = step_tank(h, u_val; dt = dt)

        h_log[k] = h
        u_log[k] = u_val

        e_prev = e
        h = h_next
    end

    p1 = plot(time, h_log,
        xlabel = "time [s]", ylabel = "water level",
        label = "h(t)", legend = :bottomright)
    plot!(p1, time, fill(h_ref, length(time)), linestyle = :dash,
        label = "reference")

    p2 = plot(time, u_log,
        xlabel = "time [s]", ylabel = "valve opening u",
        label = "u(t)", legend = :bottomright)

    plot(p1, p2, layout = (2, 1), size = (800, 600))
end
