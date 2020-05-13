function collectData(in)
  %printf("WTF")
  if (!exist("buff", "var"))
    buff=0;
  endif
  if (!exist("oldtime", "var"))
    oldtime=time();
  endif
  
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
        printf("Minute end detected");
        lastData = data
        decodeDCF77Data(data);        
      endif    
      % Minute finished   
      printf("Minute start detected");
      data = [];      
    endif    
  endif  
  buff = in;  
endfunction
