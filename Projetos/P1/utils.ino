#include "utils.h"

unsigned long previousTime = 0;
const unsigned long interval = 500;

void blinkWithInterval(int led) {
  
  unsigned long currentTime = millis();
  
  if (currentTime - previousTime >= interval) {     
      
      int ledState = digitalRead(led);
      previousTime = currentTime;         
      digitalWrite(led, !ledState);
  
  } // if

} // blinkWithInterval

void buzzOn(int pin) {

    digitalWrite(pin, ON);

} // buzzOn

void buzzOff(int pin) {

    digitalWrite(pin, OFF);
    
} // buzzOff