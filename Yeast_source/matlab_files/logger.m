function logfun = logger(logFile)
    % Create a logging function that writes timestamped messages to a file
    logfun = @log_message;
    
    function log_message(message)
        % Open file in append mode
        fid = fopen(logFile, 'a');
        
        % Check if file opened successfully
        if fid == -1
            error('Could not open log file: %s', logFile);
        end
        
        % Write timestamp and message
        fprintf(fid, '[%s] %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), message);
        
        % Close file
        fclose(fid);
    end
end