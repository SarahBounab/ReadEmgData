clear all; close all; clc;

% ------------------- Settings -------------------
folderName = "tst";   % desired folder name
baseFilename = folderName; % base file name for CSV
port = "COM3";
baudRate = 115200;
Fs = 1000;                 % sampling rate

% ----------------- Create Folder ----------------
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

% ------------- Auto-Increment Filename ----------
i = 1;
while true
    csvFilename = sprintf("%s/%s%d.csv", folderName, baseFilename, i);
    if ~isfile(csvFilename)
        break;
    end
    i = i + 1;
end

% --------------- Prepare CSV File ---------------
fid = fopen(csvFilename, "w");
fprintf(fid, "Time,Raw (V),Filtered (V),Filtered (mV)\n");

% --------------- Serial Setup -------------------
s = serialport(port, baudRate);
configureTerminator(s, "CR/LF");
flush(s);

% --------------- Plot Setup ---------------------
figure('Name','ESP32 Raw vs Filtered EMG','NumberTitle','off');
h1 = animatedline('Color','[0 0.447 0.741]','LineWidth',1.5); % raw
h2 = animatedline('Color','[0.85 0.325 0.098]','LineWidth',1.5); % filtered
legend('Raw','Filtered');
ax = gca;
ax.YLim = [-3.3 3.3];  
ax.XLim = [0 10];
xlabel('Time (s)');
ylabel('Amplitude (V)');
grid on;

% --------------- Data Loop ----------------------
tic;
while ishandle(h1)
    str = readline(s);
    data = sscanf(str, "%f,%f");

    if length(data) ~= 2
        continue;
    end

    raw = data(1);
    filtered = data(2)
    filtered_mV = filtered * 1000;
    t = toc;

    % Plot
    addpoints(h1, t, raw);
    addpoints(h2, t, filtered);
    if t > ax.XLim(2)
        ax.XLim = [t-10, t];
    end
    drawnow limitrate

    % Log
    fprintf(fid, "%.4f,%.4f,%.4f,%.4f\n", t, raw, filtered, filtered_mV);
end

% ------------- Cleanup --------------------------
fclose(fid);
clear s;
