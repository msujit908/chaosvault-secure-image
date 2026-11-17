function J = sm4d_jacobian(varargin)
% SM4D_JACOBIAN Computes the exact 4x4 analytic Jacobian matrix of the
% modified 4D Shimizu-Morioka chaotic dynamical system.
%
% Supported Calling Signatures:
%   J = sm4d_jacobian(X, params)
%   J = sm4d_jacobian(t, X, params)
%
% Mathematical Derivation of the Jacobian Matrix:
%   Given the vector field F(X) = [f1; f2; f3; f4]:
%     f1(X) = x_2
%     f2(X) = x_1 - b*x_2 - x_1*x_3
%     f3(X) = -a*x_3 + r*x_1^2 + d*x_4
%     f4(X) = -x_1*x_3 - c*x_4
%
%   The Jacobian matrix J_{ij} = \partial f_i / \partial x_j is:
%
%   Row 1 (\nabla f1):
%     \partial f1 / \partial x1 = 0
%     \partial f1 / \partial x2 = 1
%     \partial f1 / \partial x3 = 0
%     \partial f1 / \partial x4 = 0
%
%   Row 2 (\nabla f2):
%     \partial f2 / \partial x1 = 1 - x_3
%     \partial f2 / \partial x2 = -b
%     \partial f2 / \partial x3 = -x_1
%     \partial f2 / \partial x4 = 0
%
%   Row 3 (\nabla f3):
%     \partial f3 / \partial x1 = 2*r*x_1
%     \partial f3 / \partial x2 = 0
%     \partial f3 / \partial x3 = -a
%     \partial f3 / \partial x4 = d
%
%   Row 4 (\nabla f4):
%     \partial f4 / \partial x1 = -x_3
%     \partial f4 / \partial x2 = 0
%     \partial f4 / \partial x3 = -x_1
%     \partial f4 / \partial x4 = -c
%
%   Hence:
%     J(X) = [    0,     1,     0,    0 ;
%              1 - x3,  -b,   -x1,    0 ;
%              2*r*x1,   0,    -a,    d ;
%                -x3,    0,   -x1,   -c ]
%
% Note on Trace and Volume Contraction:
%   trace(J) = 0 - b - a - c = -(a + b + c) = sum of all instantaneous Lyapunov exponents.
%   With default parameters a=0.75, b=0.45, c=0.5:
%     trace(J) = -1.70 (constant everywhere in phase space, independent of X).
%
% Inputs:
%   X      - 4x1 state vector [x1; x2; x3; x4]
%   params - Parameter struct containing a, b, r, c, d
%   t      - (Optional) Time scalar, accepted for ODE solver compatibility.
%
% Output:
%   J      - 4x4 analytic Jacobian matrix evaluated at state X.
%
% Author: MTP Research Team (Chaos-Based Secure Communication)
% Phase 1: Modified 4D Shimizu-Morioka Chaotic System

    if nargin == 2
        X = varargin{1};
        params = varargin{2};
    elseif nargin == 3
        % Signature: sm4d_jacobian(t, X, params)
        X = varargin{2};
        params = varargin{3};
    else
        error('sm4d_jacobian:InvalidInputs', ...
            'Expected either (X, params) or (t, X, params).');
    end

    if numel(X) ~= 4
        error('sm4d_jacobian:InvalidDimension', 'State vector X must contain exactly 4 elements.');
    end

    % Extract state coordinates
    x1 = X(1);
    x3 = X(3);

    % Extract parameters with defaults
    if isfield(params, 'a'), a = params.a; else, a = 0.75; end
    if isfield(params, 'b'), b = params.b; else, b = 0.45; end
    if isfield(params, 'r'), r = params.r; else, r = 1.00; end
    if isfield(params, 'c'), c = params.c; else, c = 0.50; end
    if isfield(params, 'd'), d = params.d; else, d = 0.20; end

    % Construct analytic Jacobian matrix
    J = [      0,       1,      0,     0 ;
           1 - x3,     -b,    -x1,     0 ;
          2*r*x1,       0,     -a,     d ;
             -x3,       0,    -x1,    -c ];
end
