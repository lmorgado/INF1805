/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
 
/* Set DIO pins to outputs */
void setDisplayPins();
  
/* Write a hour between 0 and 23 and a min between 0 and 59 to the display */
void displayTime(int hour, int min);

// adjustment for time
void adjustHour(int time[2]);
void adjustMin(int time[2]);
void adjustClock(int clock[2]);

// simulate a clock whose minute is equivalent to 1000ms
void runClock(int clock[2]);