function send = telepush(varargin)
% MAKETELEPUSH  Build a sender bound to a specific host/port (closure).
%   send = makeTelepush('host',H,'port',P,'secret',S,'timeout',T,'to',TO)

    % ---- parse constructor args ----
    ip = inputParser;
    ip.addParameter('host', envOrDefault('TELEPUSHD_HOST','127.0.0.1'), @(x)ischar(x)||isstring(x));
    ip.addParameter('port', str2double(envOrDefault('TELEPUSHD_PORT','8787')), @(x)isnumeric(x)&&isscalar(x));
    ip.addParameter('secret', envOrDefault('TELEPUSHD_SECRET',''), @(x)ischar(x)||isstring(x));
    ip.addParameter('timeout', 3.0, @(x)isnumeric(x)&&isscalar(x));
    ip.addParameter('to', '', @(x)ischar(x)||isstring(x));
    ip.parse(varargin{:});

    host    = char(ip.Results.host);
    port    = ip.Results.port;
    secret  = char(ip.Results.secret);
    dfltTmo = ip.Results.timeout;
    dfltTo  = char(ip.Results.to);

    url = sprintf('http://%s:%d/notify/json', host, port);
    hdrs = {};
    if ~isempty(strtrim(secret))
        hdrs = {'X-Telepush-Secret', secret};
    end
    baseOpts = weboptions('Timeout', dfltTmo, 'HeaderFields', hdrs, 'MediaType', 'application/json');

    % Returned function (closure)
    send = @telepush_send;

    function resp = telepush_send(msg, varargin)
        % Optional per-call overrides: 'to', 'timeout'
        sp = inputParser;
        sp.addParameter('to', dfltTo, @(x)ischar(x)||isstring(x));
        sp.addParameter('timeout', dfltTmo, @(x)isnumeric(x)&&isscalar(x));
        sp.parse(varargin{:});                 % <-- FIXED

        to  = char(sp.Results.to);
        tmo = sp.Results.timeout;

        body = struct('msg', char(msg));
        if ~isempty(strtrim(to))
            body.to = to; %#ok<STRNU>
        end

        if tmo == dfltTmo
            opts = baseOpts;
        else
            opts = weboptions('Timeout', tmo, 'HeaderFields', hdrs, 'MediaType', 'application/json');
        end

        resp = webwrite(url, body, opts);
    end
end

function val = envOrDefault(name, defaultVal)
    v = getenv(name);
    if isempty(v), val = defaultVal; else, val = v; end
end

