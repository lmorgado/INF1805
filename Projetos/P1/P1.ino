#include "pindefs.h"
#include "display.h"
#include "utils.h"

// selector = 0: menu,
// selector = 1: config. hour,
// selector = 2: config. minute,
// selector = 3: confirm changes and return to menu.
int selector = 0;

// alarm time: hour and minute.
int alarm[2] = {06, 00};

// clock time: hour and minute.
int clock[2] = {10, 00};

// screen in which the user is.
bool clockScreen = true;
bool alarmScreen = false;

// if the alarm is waiting to ring.
bool waiting = false;

// if the alarm is enabled.
bool checked = true;

// times in milliseconds.
const int clickLength = 100;
const int holdLength = 2000;
float keyPressLength = 0;


void setup() {
  
  setDisplayPins();
  pinMode(LED4, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(KEY1,  INPUT_PULLUP);
  pinMode(KEY2,  INPUT_PULLUP);
  pinMode(KEY3,  INPUT_PULLUP);
  pinMode(BUZZ, OUTPUT);

  digitalWrite(BUZZ, OFF);
  digitalWrite(LED4, OFF);
  digitalWrite(LED3, OFF);
  digitalWrite(LED2, OFF);
  digitalWrite(LED1, OFF);
  
  Serial.begin(9600);

} // END SETUP

void loop() {
  
  if (clockScreen) {

      displayTime(clock[0], clock[1]);
      digitalWrite(LED4, ON);
      digitalWrite(LED3, OFF);  

  } // if
      
  else if (alarmScreen) {

      displayTime(alarm[0], alarm[1]);
      digitalWrite(LED3, ON);
      digitalWrite(LED4, OFF);

  } // else if
             
  if (selector == 0) {

      runClock(clock);
      digitalWrite(LED2, OFF);

  } // if
      
  else {

      digitalWrite(LED2, ON);

  } // else

  if (checked) {

      listener_alarm();
      blinkWithInterval(LED1);

  } // if

  else {

      buzzOff(BUZZ);
      digitalWrite(LED1, OFF);

  } // else

  listener_key1();
  listener_key2();
  listener_key3();

} // END LOOP


////////////////////////////////////////////////////
////// LISTENERS ///////////////////////////////////
////////////////////////////////////////////////////


void listener_key1() { // Up command
                       // and set sleep alarm mode
  
  while (digitalRead(KEY1) == ON) { 
      
      delay(100); 
      keyPressLength += 100;
  
  } // while

  // press (hold) key 1 - button 1.
  if (keyPressLength >= holdLength) {  // set sleep alarm mode

      if (digitalRead(BUZZ) == ON) {

          waiting = true;

      } // if    

  } // if

  // press (click) key 1 - button 1.
  else if (keyPressLength >= clickLength) {
      
      if (selector == 0) {  // Up menu from clock screen to alarm screen            
          
          clockScreen = false;
          alarmScreen = true;
      
      } // if

      else if (selector == 1) {  // Up hour digits      
          
          if (clockScreen) {         
              
              clock[0]++;
              adjustHour(clock);    
           
           } // if
           
           if (alarmScreen) {      
              
              alarm[0]++;             
              adjustHour(alarm);      
           
           } // if
      
      } // else if

      else if (selector == 2) {  // Up minutes digits
        
          if (clockScreen) {  
              
              clock[1]++;
              adjustMin(clock);  
           
           } // if
        
           if (alarmScreen) {   
              
              alarm[1]++;
              adjustMin(alarm);   
           
           } // if  
      
      } // else if
     
  } // else if

  keyPressLength = 0;

} // listener_k1 - button 1 (Up command)


void listener_key2() {  // Down command 
                        // and set sleep alarm mode
  
  while (digitalRead(KEY2) == ON) {
      
      delay(100); 
      keyPressLength += 100;  
  
  } // while

  // press (hold) key 2 - button 2.
  if (keyPressLength >= holdLength) {  // set sleep alarm mode

      if (digitalRead(BUZZ) == ON) {

          waiting = true;  

      } // if

  } // if

  // press (click) key 2 - button 2.
  else if (keyPressLength >= clickLength) { 
      
      if (selector == 0) {  // Down menu from alarm screen to clock screen                 
          
          clockScreen = true;
          alarmScreen = false;
      
      } // if

      else if (selector == 1) { // Down hours digits
         
          if (clockScreen) {         
              
              clock[0]--;
              adjustHour(clock);    
           
           } // if
        
           
           if (alarmScreen) {      
              
              alarm[0]--;
              adjustHour(alarm);      
           
           } // if     
      
      } // else if

      else if (selector == 2) { // Down minutes digits
        
          if (clockScreen) {         
              
              clock[1]--;
              adjustMin(clock);  
           
           } // if
        
           if (alarmScreen) {      
              
              alarm[1]--;
              adjustMin(alarm);   
           
           } //if
      
      } // else if
        
  } // else if

  keyPressLength = 0;

} // listener_k2 - button 2 (Down command)


void listener_key3() {  // Select adjust mode: hours or minutes,
                        // confirm changes
                        // and turn on/off alarm
  
  while (digitalRead(KEY3) == ON) { 
      
      delay(100); 
      keyPressLength += 100;  
  
  } // while

  // press (hold) key 3 - button 3.
  if (keyPressLength >= holdLength) {  // turn on/off alarm

      checked = !checked;
      selector = 0;

  } // if
      
  // press (click) key 3 - button 3.    
  else if (keyPressLength >= clickLength) {  // select adjust mode

      selector++;

  } // else if
              
  if (selector == 3) {  // confirm changes 
                        // and return to menu

      selector = 0;

  } // if
      
  keyPressLength = 0;

} // listener_k3 - button 3 (adjust and turn on/off alarm)


void listener_alarm() {   // Verify alarm time
                          // and turn on/off Buzz

      if (selector != 0) {

          return;
      
      } // if

      if (waiting == false) { // check alarm time
                              // and ringing whether applicable

          if (alarm[0] == clock[0] && alarm[1] == clock[1]) {

              buzzOn(BUZZ);

          } // if

      } // if

      else {  // config. sleep alarm mode
              // and turning off Buzz

          buzzOff(BUZZ);
          
          alarm[1] = clock[1] + 10;
          
          if (alarm[1] >= 60) {

              alarm[0]++;
              alarm[1] = alarm[1] - 60;   

          } // if
               
          waiting = false;     

      } // else
      
} // listener_alarm