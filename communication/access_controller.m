function [is_allowed, reason, audit_entry] = access_controller(action, varargin)
% ACCESS_CONTROLLER Policy enforcement and identity verification module
%
% Syntax:
%   [is_allowed, reason, audit] = access_controller('verify', package, claimant_id, shared_token)
%
% Inputs:
%   action       - 'verify' or 'register'
%   package      - Secure vault message package struct
%   claimant_id  - String/char identifier of entity attempting access (e.g. 'Bob')
%   shared_token - (Optional) Cryptographic access token or shared secret
%
% Outputs:
%   is_allowed   - Logical true/false
%   reason       - Detailed explanation string
%   audit_entry  - Struct documenting access attempt for audit trail
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    switch lower(action)
        case 'verify'
            if length(varargin) < 2
                error('access_controller: verify requires (package, claimant_id).');
            end
            pkg = varargin{1};
            claimant_id = strtrim(char(varargin{2}));

            if length(varargin) >= 3
                token = varargin{3};
            else
                token = '';
            end

            t_now = datetime('now', 'TimeZone', 'local');
            is_allowed = false;
            reason = '';

            % 1. Check Identity Match
            expected_recipient = strtrim(char(pkg.recipient_id));
            if ~strcmpi(claimant_id, expected_recipient) && ~strcmpi(expected_recipient, 'ANY')
                reason = sprintf('Identity mismatch: Claimant "%s" is not the designated recipient "%s".', ...
                    claimant_id, expected_recipient);
                audit_entry = make_audit(claimant_id, 'REJECTED_IDENTITY_MISMATCH', reason, t_now);
                return;
            end

            % 2. Check Expiration Status
            exp_status = expiration_manager('check', pkg.expiration);
            if exp_status.is_expired
                reason = sprintf('Access Denied: Package expired at %s (%s).', ...
                    pkg.expiration.expires_at, exp_status.remaining_str);
                audit_entry = make_audit(claimant_id, 'REJECTED_EXPIRED', reason, t_now);
                return;
            end

            % 3. Check Shared Authorization Token (if configured)
            if isfield(pkg, 'auth_token') && ~isempty(pkg.auth_token)
                if ~isequal(token, pkg.auth_token)
                    reason = 'Access Denied: Invalid authorization security token.';
                    audit_entry = make_audit(claimant_id, 'REJECTED_INVALID_TOKEN', reason, t_now);
                    return;
                end
            end

            % Authorization Success
            is_allowed = true;
            reason = sprintf('Access Granted: Entity "%s" authorized within valid lifespan.', claimant_id);
            audit_entry = make_audit(claimant_id, 'ACCESS_GRANTED', reason, t_now);

        otherwise
            error('access_controller: Unknown action "%s".', action);
    end
end

function audit = make_audit(claimant, status, reason, dt)
    audit = struct();
    audit.claimant_id = claimant;
    audit.status      = status;
    audit.reason      = reason;
    audit.timestamp   = char(dt, 'yyyy-MM-dd HH:mm:ss');
end
