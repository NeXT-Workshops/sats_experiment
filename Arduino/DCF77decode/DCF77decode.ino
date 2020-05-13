//DCF77_03.ino
//Code fuer Arduino
//Author Retian
//Version 1.1
//Greatly modified by Marcel Mann



#define signalPin 2
#define ledPin 3

#define MINUTE_BEGIN_INDEX 21
#define MINUTE_END_INDEX 27
#define HOUR_BEGIN_INDEX 29
#define HOUR_END_INDEX 34
#define DAY_BEGIN_INDEX 36
#define DAY_END_INDEX 41
#define DOW_BEGIN_INDEX 42
#define DOW_END_INDEX 44
#define MONTH_BEGIN_INDEX 45
#define MONTH_END_INDEX 49
#define YEAR_BEGIN_INDEX 50
#define YEAR_END_INDEX 57

struct dcf77param {
  char name[4];
  byte beginIndex;
  byte endIndex;
  byte value;
};


struct dcf77param minute = {"Min", MINUTE_BEGIN_INDEX, MINUTE_END_INDEX, 0};
struct dcf77param hour = {"Hou", HOUR_BEGIN_INDEX, HOUR_END_INDEX, 0};
struct dcf77param dow = {"DOW", DOW_BEGIN_INDEX, DOW_END_INDEX, 0};
struct dcf77param day = {"Day", DAY_BEGIN_INDEX, DAY_BEGIN_INDEX, 0};
struct dcf77param month = {"Mon", MONTH_BEGIN_INDEX, MONTH_END_INDEX, 0};
struct dcf77param year = {"Yea", YEAR_BEGIN_INDEX, YEAR_END_INDEX, 0};

struct dcf77param params[] = {minute, hour, day, dow, month, year};

char dcf77Signal;
char buffer;

unsigned long nowTime, lastTime;
int diffTime;

byte valuesLevel; // valuesdauer 100ms => logisch 0, 200 ms => logisch 1
byte values[59]; // eingehende values
byte bitValue[8] = {1, 2, 4, 8, 10, 20, 40, 80}; //valueswertigkeit für Level logisch 1
byte counter = 0; //Anzahl eingehende valuese

byte dcf77Stunde = 0;
byte dcf77Minute = 0;



void setup() {
  pinMode(signalPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
  Serial.write("Initialized\n");
}

void loop() {
  delay(20);
  dcf77Signal = digitalRead(signalPin);
  if (dcf77Signal != buffer)
  {
    nowTime = millis();
    delay(5); //Wartezeit bis eingeschwungener Zustand
    diffTime = nowTime - lastTime;
    lastTime = nowTime;
    if (diffTime < 150){
      valuesLevel = 0;
      Serial.print(counter);
      Serial.write(":0\n");
    }
    else if (diffTime < 250){
      valuesLevel = 1;
      Serial.print(counter);
      Serial.write(":1\n");
    }
    else if (diffTime > 1000)
    {
      if (counter == 59 || counter == 60) decodeTime();
      counter = 0;
      Serial.write("Neue Minute\n");
    }
    if (dcf77Signal == 0) // Abfrage auf "1", wenn das invertierte Signal verwendet wird
    {
      values[counter] = valuesLevel;
      counter++;
    }
    digitalWrite(ledPin, dcf77Signal);
    buffer = dcf77Signal;
  }
}
void printParam(const dcf77param& param){
  char buff[50];
  sprintf(buff, "Param: %s; begin: %2d; end %2d; value: %2d\n", param.name, param.beginIndex, param.endIndex, param.value);
  Serial.print(buff);
}

void printValues(){
  for (byte i = 0; i < 59; i++){
    char buff[5];
    sprintf(buff, "%2d|", i);
    Serial.print(buff);
  }
  Serial.print("\n");
  for (byte i = 0; i < 59; i++){
    char buff[5];
    sprintf(buff, "%2d|", values[i]);
    Serial.print(buff);
  }
  Serial.print("\n");
}

void decodeTime(){
  bool parityError = false;
  bool valueRangeError = false;
  byte parityHour = 0, parityMinute = 0, parityDate = 0;

  dcf77Stunde = 0;
  dcf77Minute = 0;

  for (byte i = 0; i < 6; i++){
    struct dcf77param actualParam = params[i];
    printParam(actualParam);
    byte beginIndex = actualParam.beginIndex;
    byte endIndex = actualParam.endIndex;
  
    for (byte j = beginIndex; j <= endIndex; j++) {           
      if (values[j]){
        char buff[50];
        sprintf(buff, "Index: %d; Value: %d; BitValue: %d\n", j, values[j], bitValue[j-beginIndex] );
        Serial.print(buff);
        actualParam.value += bitValue[j - beginIndex];
      }         
    }
    printParam(actualParam);
  
  }

  // Check Parity
  for (byte i = MINUTE_BEGIN_INDEX; i <= MINUTE_END_INDEX; i++) {  
    parityMinute ^= values[i];  
  }
  for (byte i = HOUR_BEGIN_INDEX; i <= HOUR_END_INDEX; i++) {  
    parityHour ^= values[i];  
  }
  for (byte i = DAY_BEGIN_INDEX; i <= YEAR_END_INDEX; i++) {  
    parityDate ^= values[i];  
  }
  if (values[35] != parityHour || values[28] != parityMinute || values[58] != parityDate) {    
      Serial.print("Parity Error\n");
  } else if (dcf77Stunde > 23 || dcf77Minute > 59) {
      Serial.print("Value-Range Error\n");
  } else {
      char buff[50];
      sprintf(buff, "Time: %d:%d %d.%d.20%d\n", hour.value, minute.value, day.value, month.value, year.value);  
      Serial.print(buff);    
  }
}
