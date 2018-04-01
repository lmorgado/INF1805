
// Leds and Buzz are with their polarity inverted;
// Buttons are connected to pull-up resistors;
#define ON LOW
#define OFF HIGH

void blinkWithInterval(int led);
void buzzOn(int pin);
void buzzOff(int pin);