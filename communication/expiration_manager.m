function status = expiration_manager(action, varargin)
% EXPIRATION_MANAGER Enforces time-to-live (TTL) deadlines, access revocation, and file purging
%
% Syntax:
%   exp_info = expiration_manager('create', ttl_seconds)
%   status   = expiration_manager('check', exp_info)
%   purge_log = expiration_manager('expire_now', exp_info, target_files)
%
% Inputs:
%   action       - 'create', 'check', or 'expire_now'
%   ttl_seconds  - Lifespan duration in seconds (e.g. 30, 60, 300)
%   exp_info     - Struct containing {created_at, expires_at, ttl_seconds}
%   target_files - Cell array of file paths to securely overwrite and delete
%
% Outputs:
%   status       - Struct containing {is_expired, remaining_sec, remaining_str, authorized}
%
% Scientific Disclaimer:
%   Application-level expiration enforces strict access revocation within the ChaosVault
%   software platform. However, software deletion CANNOT guarantee remote wiping of
%   unauthorized client screenshots, external memory dumps, or physical NAND flash wear blocks.
%
% Author: MTP Research Team (ChaosVault Secure Communication)
% =========================================================================

    switch lower(action)
        case 'create'
            if nargin < 2 || isempty(varargin{1})
                ttl_sec = 60; % Default 60 seconds
            else
                ttl_sec = varargin{1};
            end
            
            t_now = datetime('now', 'TimeZone', 'local');
            t_exp = t_now + seconds(ttl_sec);

            status = struct();
            status.ttl_seconds  = ttl_sec;
            status.created_at   = char(t_now, 'yyyy-MM-dd HH:mm:ss');
            status.expires_at   = char(t_exp, 'yyyy-MM-dd HH:mm:ss');
            status.created_dt   = t_now;
            status.expires_dt   = t_exp;
            status.is_expired   = false;

        case 'check'
            if nargin < 2
                error('expiration_manager: check requires exp_info struct.');
            end
            exp_info = varargin{1};
            
            t_now = datetime('now', 'TimeZone', 'local');
            if isfield(exp_info, 'expires_dt')
                t_exp = exp_info.expires_dt;
            else
                t_exp = datetime(exp_info.expires_at, 'InputFormat', 'yyyy-MM-dd HH:mm:ss', 'TimeZone', 'local');
            end

            rem_sec = seconds(t_exp - t_now);
            
            status = struct();
            if rem_sec <= 0
                status.is_expired     = true;
                status.remaining_sec  = 0.0;
                status.remaining_str  = 'EXPIRED (00:00:00)';
                status.authorized     = false;
                status.status_code    = 'DEADLINE_EXCEEDED';
            else
                status.is_expired     = false;
                status.remaining_sec  = rem_sec;
                mins = floor(rem_sec / 60);
                secs = floor(rem_sec - mins * 60);
                status.remaining_str  = sprintf('%02d:%02d remaining', mins, secs);
                status.authorized     = true;
                status.status_code    = 'ACTIVE';
            end

        case 'expire_now'
            exp_info = varargin{1};
            if length(varargin) >= 2
                files_to_delete = varargin{2};
            else
                files_to_delete = {};
            end

            purged_files = {};
            for i = 1 : length(files_to_delete)
                f_path = files_to_delete{i};
                if exist(f_path, 'file')
                    try
                        % Overwrite file bytes with zeros prior to unlinking
                        f_size = dir(f_path).bytes;
                        fid = fopen(f_path, 'w');
                        if fid > 0
                            fwrite(fid, zeros(1, f_size, 'uint8'), 'uint8');
                            fclose(fid);
                        end
                        delete(f_path);
                        purged_files{end + 1} = f_path;
                    catch
                    end
                end
            end

            % Trigger key zeroization
            key_zeroization(exp_info);

            status = struct();
            status.is_expired    = true;
            status.purged_files  = purged_files;
            status.timestamp     = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
            status.status_code   = 'REVOKED_AND_PURGED';

        otherwise
            error('expiration_manager: Unknown action "%s". Use "create", "check", or "expire_now".', action);
    end
end
