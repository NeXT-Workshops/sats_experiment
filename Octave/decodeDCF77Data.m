% Decodes an array of dcf77 data.
% 

function decodeDCF77Data(data)
  pkg load miscellaneous
 
  
  s1 = "Parity Error in %s\n";  
  s2 = "Data: %s\n";
  s3 = "Calculated Parity: %d\n";
  s4 = "Received Parity: %d\n";
  parityErrorString = strcat(s1, s2, s3, s4);
  
  bcd = [1; 2; 4; 8; 10; 20; 40; 80];

  minute = dot(data(22:28), bcd(1:7));
  hour = dot(data(30:35), bcd(1:6));
  day = dot(data(37:42), bcd(1:6));
  dow = dot(data(43:45), bcd(1:3));
  month = dot(data(46:50), bcd(1:5));
  year = dot(data(51:58), bcd);
  
  parityMin = reduce(@(x,y)(xor(x,y)), data(22:28));
  parityHour = reduce(@(x,y)(xor(x,y)), data(30:35));
  parityDate = reduce(@(x,y)(xor(x,y)), data(37:58));
  
  if(parityMin != data(29))
    printf(parityErrorString, "Minute", num2str(data(22:28)), parityMin, data(29));
  endif    
  if(parityHour != data(36))   
    printf(parityErrorString, "Hour", num2str(data(30:35)), parityHour, data(36));
  endif
  if(parityDate != data(59))
    printf(parityErrorString, "Date", num2str(data(22:28)), parityMin, data(29));
  endif

  switch (dow)
    case 1 dow_s = "Mon";
    case 2 dow_s = "Tue";
    case 3 dow_s = "Wed";
    case 4 dow_s = "Thu";
    case 5 dow_s = "Fri";
    case 6 dow_s = "Sat";
    case 7 dow_s = "Sun";            
  endswitch
  printf("%s %02d.%02d.20%d %02d:%02d\n", dow_s, day, month, year, hour, minute);
endfunction
