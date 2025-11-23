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
const A_tank  = 1.0     # [m^2] cross-section
const k_out   = 0.5     # [1/s] outflow coefficient
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
    q_in  = q_in_max * clamp(u, 0.0, 1.0)
    q_out = k_out * max(h, 0.0)
    dh    = (q_in - q_out) / A_tank
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
        domain = -1.0:1.0

        NL = TrapezoidalMF(-1.0, -1.0, -0.7, -0.3)  # negative large
        NS = TriangularMF(-0.7, -0.35, 0.0)         # negative small
        ZE = TriangularMF(-0.1, 0.0, 0.1)           # around zero
        PS = TriangularMF(0.0, 0.35, 0.7)           # positive small
        PL = TrapezoidalMF(0.3, 0.7, 1.0, 1.0)      # positive large
    end

    de := begin
        domain = -0.5:0.5

        DN = TrapezoidalMF(-0.5, -0.5, -0.25, 0.0)  # decreasing
        DZ = TriangularMF(-0.1, 0.0, 0.1)           # roughly constant
        DP = TrapezoidalMF(0.0, 0.25, 0.5, 0.5)     # increasing
    end

    u := begin
        domain = 0.0:1.0

        Close  = TrapezoidalMF(0.0, 0.0, 0.1, 0.2)
        Small  = TriangularMF(0.1, 0.25, 0.4)
        Medium = TriangularMF(0.3, 0.5, 0.7)
        Large  = TriangularMF(0.6, 0.75, 0.9)
        Full   = TrapezoidalMF(0.8, 0.9, 1.0, 1.0)
    end

    e == PL          && de == DN --> u == Full
    e == PL          && de == DZ --> u == Full
    e == PL          && de == DP --> u == Large

    e == PS          && de == DN --> u == Full
    e == PS          && de == DZ --> u == Large
    e == PS          && de == DP --> u == Medium

    e == ZE          && de == DN --> u == Large
    e == ZE          && de == DZ --> u == Medium
    e == ZE          && de == DP --> u == Small

    e == NS          && de == DN --> u == Small
    e == NS          && de == DZ --> u == Close
    e == NS          && de == DP --> u == Close

    e == NL                      --> u == Close
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
let dt = 0.1,             # [s] time step
    t_final = 60.0,       # [s] total simulation time
    h_ref = 1.0

    n_steps = Int(round(t_final / dt))

    time = collect(0:n_steps) .* dt
    h_log = similar(time)
    u_log = similar(time)

    h = 0.0
    e_prev = h_ref - h

    for k in eachindex(time)
        e  = h_ref - h
        de = e - e_prev

        u_val = fis(e = e, de = de)[:u]
        h_next = step_tank(h, u_val; dt = dt)

        h_log[k] = h
        u_log[k] = u_val

        e_prev = e
        h      = h_next
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
