pkg load instrument-control
clear *;

ser = openSerialPort();
pause(1);
srl_flush(ser);

while time()-starttime < recTime
  recSignal(end+1) = str2num(char(srl_read(ser,1)));  
endwhile

save recSignal.dat recSignal
