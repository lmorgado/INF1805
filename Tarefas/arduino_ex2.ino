
/* A polaridade do LED esta invertida na placa
 * Assim isso será ON quando o pino esta LOW e OFF quando o pino esta HIGH
 */
#define ON LOW
#define OFF HIGH

const int bt1Pin = A1;
const int bt2Pin = A2;  
const int ledPin = LED_BUILTIN;

int ledState = OFF;
unsigned long previousTime = 0;
unsigned long blinkInterval = 0;

void setup() {
  
  pinMode(ledPin, OUTPUT);
  pinMode(bt1Pin,  INPUT_PULLUP);
  pinMode(bt2Pin,  INPUT_PULLUP);

  setBlinkInterval(1000);  // o led pisca a cada 1 segundo.

}

void loop() {
  
  blinkWithInterval();   // piscar led dentro do intervalo ("blinkInterval") setado

  unsigned long bt1Time = 0;
  unsigned long bt2Time = 10000000;
  
  if(digitalRead(bt1Pin) == ON) bt1Time = millis();      // instante de clique p/ botao 1
  if(digitalRead(bt2Pin) == ON) bt2Time = millis();      // instante de clique p/ botao 2

  if(bt2Time - bt1Time <= 500) setBlinkInterval(0);     // os 2 botoes foram clicados dentro de 500ms;
                                                        // o led para de piscar.
       
  else if (digitalRead(bt1Pin)==ON) setBlinkInterval(2 * blinkInterval / 3);    // botao 1 clicado; acelera o led.
  else if (digitalRead(bt2Pin)==ON) setBlinkInterval(3 * blinkInterval / 2);    // botao 2 clicado; desacelera o led.
  
}


// funcao p/ setar o intervalo "blinkInterval" no qual o led pisca
void setBlinkInterval(int value) {
  blinkInterval = value;  
  delay(100);
}

// funcao p/ piscar o led
void blinkWithInterval( ) {   
  unsigned long currentTime = millis(); 
  if (currentTime - previousTime >= blinkInterval) {     
      previousTime = currentTime;      
      ledState = !ledState;     
      digitalWrite(ledPin, ledState);
  } 
}
