% Returns the first working Serial port.
% tries /dev/USB0 ..1 ..2 etc up to 10

function serialport = openSerialPort()  
  s_templ = "/dev/ttyUSB";
  %s_templ = "\\\\.\\COM1";
  for i = 0:10
    
    try
      s_interface = strcat(s_templ, num2str(i));
      ser = serial(s_interface);
    catch err
      printf ("Unable to open Port: [%s]\n", s_interface)
    end_try_catch
    
    if( exist("ser", "var"))
      printf("Opened serial Port: [%s]\n", s_interface);
      break 
    endif  
    
  endfor
  pause(1);
  srl_flush(ser);
  serialport = ser;
endfunction
