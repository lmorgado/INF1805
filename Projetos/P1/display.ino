#include "display.h"

float t0 = 0;
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
const byte SEGMENT_SELECT[] = {0xF1, 0xF2, 0xF4, 0xF8};

void setDisplayPins() {
  
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT);

} // setDisplayPins
  
void WriteNumberToSegment(byte Segment, byte Value) {
  
  digitalWrite(LATCH_DIO, LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);

} // WriteNumberToSegment

void displayTime(int hour, int min) {
 
    WriteNumberToSegment(0 , hour / 10);
    WriteNumberToSegment(1 , hour % 10);
    WriteNumberToSegment(2 , min / 10);
    WriteNumberToSegment(3 , min % 10); 

} // displayTime


void runClock(int clock[2]) {
   
  float t1 = millis();
  
  if (t1 - t0 >= 1000) {      
      
      t0 = t1;
      clock[1]++;
      adjustClock(clock);
  
  } // if

} // runClock


void adjustClock(int clock[2]) {
   
  if (clock[1] == 60) {

      clock[0]++;

  } // if
  
  adjustHour(clock);    
  adjustMin(clock);
  
} // adjustClock


void adjustHour(int time[2]) {

    if (time[0] < 0) {

        time[0] = 23;

    } // if
           
    if (time[0] > 23) {

        time[0] = 00;

    } // if
        
} // adjustHour


void adjustMin(int time[2]) {
  
    if (time[1] < 0) {

        time[1] = 59;

    } //  if  
              
    if (time[1] > 59) {

        time[1] = 00;
    
    } // if    
        
} // adjustMin
