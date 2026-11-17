function x_next = rk4_step(f, t, x, dt)
% RK4_STEP Performs a single integration step using the classical 4th-Order
% Runge-Kutta (RK4) numerical integration algorithm.
%
% Mathematical Algorithm:
%   Given the initial value problem dx/dt = f(t, x) with step size dt:
%     k1 = f(t,          x)
%     k2 = f(t + dt/2,   x + (dt/2)*k1)
%     k3 = f(t + dt/2,   x + (dt/2)*k2)
%     k4 = f(t + dt,     x + dt*k3)
%     x_next = x + (dt/6) * (k1 + 2*k2 + 2*k3 + k4)
%
% Numerical & Algorithmic Properties:
%   - Global truncation error: O(dt^4)
%   - Local truncation error:  O(dt^5)
%   - Orientation Preservation: Normalizes vectors to column orientation internally
%     to prevent accidental matrix expansion in MATLAB R2016b+ if row and column
%     vectors are combined.
%   - Explicit 4-stage method providing superior numerical stability and
%     conservation compared to Euler, Heun, or 2nd-order methods for
%     stiff or chaotic vector fields.
%
% Inputs:
%   f      - Function handle accepting (t, x) and returning dx/dt.
%   t      - Current time scalar.
%   x      - Current state vector (column or row vector of length N).
%   dt     - Integration time step scalar.
%
% Output:
%   x_next - State vector evaluated at time t + dt (same orientation as x).
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% Phase 1: Modified 4D Shimizu-Morioka Chaotic System

    % Guard against implicit matrix expansion by enforcing column vectors
    is_row = isrow(x);
    x_col = x(:);

    % Compute four intermediate slopes (stages)
    k1 = f(t,              x_col);               k1 = k1(:);
    k2 = f(t + 0.5*dt,     x_col + 0.5*dt*k1);   k2 = k2(:);
    k3 = f(t + 0.5*dt,     x_col + 0.5*dt*k2);   k3 = k3(:);
    k4 = f(t + dt,         x_col + dt*k3);       k4 = k4(:);

    % Compute weighted average update
    x_next_col = x_col + (dt / 6.0) * (k1 + 2.0*k2 + 2.0*k3 + k4);

    % Restore original orientation
    if is_row
        x_next = x_next_col';
    else
        x_next = x_next_col;
    end
end
