/*
 * Reads input at digital Pin 2
 * relays input to UART
 * let's LED blink according to input
 */

#define signalPin 2
#define ledPin LED_BUILTIN

char dcf77Signal;
char buffer;

int plotCounter = 0;

void setup() {
  pinMode(signalPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(115200);
}

void loop() {
  byte in = digitalRead(signalPin);
  Serial.print(in);  
  digitalWrite(ledPin, in ? HIGH : LOW);
  delay(5);
}
