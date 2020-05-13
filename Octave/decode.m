pkg load instrument-control
ser = openSerialPort();

buff = 0;
data = [];
clear time;
oldtime = 0;

while true  
  in = str2num(char(srl_read(ser,1)));
  if (buff != in)
    
    newtime = time();
    timediff = newtime - oldtime;
    oldtime = newtime;
    
    if(buff<in)      
      % rising flank
      wasLow = true;
    else
      % falling flank
      wasLow = false;
    endif
    
    
    if (timediff < .150)
      % 0-Bit
      data(end+1) = 0;      
    elseif (timediff < .250)
      % 1-Bit
      data(end+1) = 1;      
    elseif (timediff > 1.1 && wasLow)    
      if (columns(data) == 59 || columns(data)== 60) 
        lastData = data
        decodeDCF77Data(data);        
      endif    
      % Minute finished   
      data = [];      
    endif    
    
    %counter++
  endif  
  buff = in;  
  pause(.001);
endwhile
srl_close(s1);

