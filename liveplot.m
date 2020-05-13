pkg load instrument-control
clear *;

% Arduino sample frequency
fs = 200;

% width of graph in secs
width_sec = 10;

% plot refresh rate
fp = 40;

% runTime
runTime = 70;

width = width_sec * fs;
samples_per_iter = fs/fp;
scrollstart = width / fs / fp;
ser = openSerialPort();
samples_end = runTime * fs;

pause(1);
srl_flush(ser);

signalTemp = cell(samples_per_iter,1);
signal = 0;
iter = 0;
stop =false;

while !stop
  iter++;
  for i = 1:samples_per_iter
    in = str2num(char(srl_read(ser,1)));
    collectData(in);
    signalTemp {i,1} = in;
  endfor 
  signal = cat(1, signal, signalTemp{1:samples_per_iter});
  plot(signal, "linewidth", 10);
  samples = iter * samples_per_iter;
  if (samples<=width)
    axis([0 width -0.2 1.2]); 
  else    
    axis([samples-width samples -0.2 1.2]); 
  endif
  if (samples > samples_end)
    save recSignal.dat signal;
    stop = true;
  endif
  pause(.001)
endwhile


srl_close(ser);
close;