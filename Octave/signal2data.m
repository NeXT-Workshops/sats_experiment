function data = signal2data(signal)  
  buff=0;  
  oldIndex=0;
  data = [];
  global recData = [];
  for index = 1:rows(signal)    
    in=signal(index);
    
    if (buff != in)    
      newIndex = index;
      diffIndex = newIndex - oldIndex;
      oldIndex = newIndex;
      
      if(buff<in)      
        % rising flank
        wasLow = true;
      else
        % falling flank
        wasLow = false;
      endif      
      
      if (diffIndex * 0.005 < .150)
        % 0-Bit
        data(end+1) = 0;      
      elseif (diffIndex * 0.005 < .250)
        % 1-Bit
        data(end+1) = 1;      
      elseif (diffIndex * 0.005  > 1.1 && wasLow)    
        if (columns(data) == 59 || columns(data)== 60) 
          printf("Minute end detected\n");
          save recData.dat data;
          recData = data;
          break;
        endif    
        % Minute finished   
        printf("Minute start detected\n");
        data = [];      
      endif    
    endif  
    buff = in;  
  endfor
endfunction
