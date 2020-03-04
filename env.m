function value = env(key, default)
    % ENV - read environment variables
    %
    % Reads values from three sources in the following order:
    %  1) ".env" file on the path
    %  2) MATLAB preferences (getpref) in the 'env' group
    %  3) System environment (getenv)
    %
    % Examples:
    %  dbHost = env('DATABASE_HOST', '127.0.0.1');
    %  s3Pass = env('S3_PASSWORD');
    %  env PATH
    %
    % See also: getenv, getpref

    % Copyright 2019 Florian Schwaiger <f.schwaiger@tum.de>
    %
    % Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    % associated documentation files (the "Software"), to deal in the Software without restriction,
    % including without limitation the rights to use, copy, modify, merge, publish, distribute,
    % sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
    % is furnished to do so, subject to the following conditions:
    %
    % The above copyright notice and this permission notice shall be included in all copies
    % or substantial portions of the Software.
    %
    % THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
    % BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    % NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    % DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    % OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    value = readfrominifile(key);
    if ~isempty(value)
        return
    end

    value = readfrommatlabpref(key);
    if ~isempty(value)
        return
    end

    value = readfromsystemenv(key);
    if ~isempty(value)
        return
    end

    if nargout > 0 && nargin > 1
        value = default;
    elseif nargout > 0
        error('Environment value "%s" undefined, no default given.', key);
    end

end


function value = readfromsystemenv(key)
    % try to read from system env variables
    value = getenv(key);
end


function value = readfrommatlabpref(key)
    % read from MATLAB preferences "env" group
    if ispref('env', key)
        value = getpref('env', key);
    else
        value = [];
    end
end


function value = readfrominifile(key)
    % get the value from an ".env" file
    value = [];
    if ~exist('.env', 'file')
        return
    end

    modified = lastmodified('.env');
    persistent envCache
    if isempty(envCache) || envCache.modified < modified
        envCache = struct( ...
            'modified', modified, ...
            'content', loadini('.env') ...
        );
    end

    if isfield(envCache.content, key)
        value = envCache.content.(key);
    end
end


function modified = lastmodified(filename)
    % finds out when a file was modified last
    info = dir(filename);
    modified = info(1).datenum;
end


function value = loadini(filename)
    % read and parse a file in KEY=VALUE format
    lines = strsplit(fileread(filename), newline);
    value = struct();

    for iLine = 1:numel(lines)
        line = strtrim(lines{iLine});

        if isempty(line) || any(line(1) == '#;[')
            % ignore comments and section headers
        else
            value = appendlinevalue(value, line);
        end
    end
end


function parent = appendlinevalue(parent, line)
    [key, valueWithEqualsChar] = strtok(line, '=');
    key = strtrim(key);
    text = strtrim(valueWithEqualsChar(2:end));

    if isempty(text) || any(text(1) == '#;')
        % ignore unset value and comments
    elseif any(text(1) == '"''')
        % extract until the closing quote character
        parent.(key) = strtok(text, text(1));
    elseif text(1) == '{'
        % extract until the closing quote character
        parent.(key) = strsplit(strtok(text(2:end), '}'), ',');
    else
        % try to coerce to a numeric value
        parent.(key) = parsenum(text);
    end
end


function value = parsenum(text)
    % parse string to number, but do not evaluate classes
    value = text;
    if ~exist(text, 'class')
        [numerical, isNumeric] = str2num(text); %#ok<ST2NM>
        if isNumeric
            value = numerical;
        end
    end
end

