function dX = sm4d_rhs(varargin)
% SM4D_RHS Evaluates the right-hand side differential equations of the
% modified 4-Dimensional Shimizu-Morioka chaotic dynamical system.
%
% Supported Calling Signatures:
%   dX = sm4d_rhs(t, X, params)   % Standard ODE / integrator signature
%   dX = sm4d_rhs(X, params)      % Direct autonomous evaluation
%   dX = sm4d_rhs(t, X)           % Uses default nominal parameters
%   dX = sm4d_rhs(X)              % Direct evaluation with default parameters
%
% Mathematical Formulation:
%   \dot{x}_1 = x_2
%   \dot{x}_2 = x_1 - b*x_2 - x_1*x_3
%   \dot{x}_3 = -a*x_3 + r*x_1^2 + d*x_4
%   \dot{x}_4 = -x_1*x_3 - c*x_4
%
% State Vector:
%   X = [x_1; x_2; x_3; x_4] (4x1 column vector)
%
% Physical & Dynamical Interpretation of Terms:
%   x_1      : Primary generalized coordinate / displacement variable.
%   x_2      : Generalized velocity (dx_1/dt).
%   -b*x_2   : Linear viscous damping / dissipation on velocity.
%   -x_1*x_3 : Nonlinear cross-coupling term (inertial feedback).
%   -a*x_3   : Linear restoring dissipation on x_3.
%   +r*x_1^2 : Centrifugal quadratic feedback pumping energy into x_3 from x_1.
%   +d*x_4   : Linear coupling parameter injecting 4th-dimensional dynamics into x_3.
%   -x_1*x_3 : Nonlinear driving feedback coupling the 1st and 3rd modes into x_4.
%   -c*x_4   : Linear dissipation rate of the 4th state coordinate.
%
% Dissipativity & Phase Volume Contraction:
%   The divergence of the vector field is:
%     div(F) = d(dx1)/dx1 + d(dx2)/dx2 + d(dx3)/dx3 + d(dx4)/dx4
%            = 0 - b - a - c = -(a + b + c)
%   For standard parameters a=0.75, b=0.45, c=0.5:
%     div(F) = -(0.75 + 0.45 + 0.50) = -1.70 < 0
%   Because div(F) is negative everywhere, phase space volume contracts
%   exponentially according to dV/dt = -1.70*V, guaranteeing that asymptotic
%   trajectories are confined to a bounded invariant attractor of zero Lebesgue volume.
%
% Inputs:
%   t      - (Optional) Current simulation time scalar (seconds).
%   X      - 4x1 state vector [x1; x2; x3; x4].
%   params - (Optional) Struct containing system parameters:
%              params.a : Damping parameter for x3 (default: 0.75)
%              params.b : Viscous damping for x2   (default: 0.45)
%              params.r : Quadratic feedback gain (default: 1.00)
%              params.c : Dissipation for x4       (default: 0.50)
%              params.d : Cross-coupling gain      (default: 0.20)
%
% Output:
%   dX     - 4x1 column vector of time derivatives [dx1/dt; dx2/dt; dx3/dt; dx4/dt].
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% Phase 1: Modified 4D Shimizu-Morioka Chaotic System

    % --- Flexible Argument Resolution ---
    if nargin == 1
        % Signature: sm4d_rhs(X)
        X = varargin{1};
        params = struct();
    elseif nargin == 2
        if isstruct(varargin{2}) && numel(varargin{1}) == 4
            % Signature: sm4d_rhs(X, params)
            X = varargin{1};
            params = varargin{2};
        else
            % Signature: sm4d_rhs(t, X)
            X = varargin{2};
            params = struct();
        end
    elseif nargin >= 3
        % Signature: sm4d_rhs(t, X, params)
        X = varargin{2};
        params = varargin{3};
    else
        error('sm4d_rhs:TooFewInputs', 'At least state vector X must be supplied.');
    end

    % Validate dimension
    if numel(X) ~= 4
        error('sm4d_rhs:InvalidDimension', ...
            'State vector X must contain exactly 4 elements. Received %d elements.', numel(X));
    end

    % Ensure scalar coordinate extraction
    x1 = X(1);
    x2 = X(2);
    x3 = X(3);
    x4 = X(4);

    % --- Parameter Extraction with Nominal Defaults ---
    if isempty(params) || ~isstruct(params)
        params = struct();
    end

    if isfield(params, 'a'), a = params.a; else, a = 0.75; end
    if isfield(params, 'b'), b = params.b; else, b = 0.45; end
    if isfield(params, 'r'), r = params.r; else, r = 1.00; end
    if isfield(params, 'c'), c = params.c; else, c = 0.50; end
    if isfield(params, 'd'), d = params.d; else, d = 0.20; end

    % --- 4D Differential Equations ---
    dx1_dt = x2;
    dx2_dt = x1 - b*x2 - x1*x3;
    dx3_dt = -a*x3 + r*(x1^2) + d*x4;
    dx4_dt = -x1*x3 - c*x4;

    % Return guaranteed 4x1 column vector
    dX = [dx1_dt; dx2_dt; dx3_dt; dx4_dt];
end
