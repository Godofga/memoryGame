import processing.io.*;
import java.util.Random;
// On the Raspberry Pi GPIO 4 is physical pin 7 on the header

String guess;
String answer;

int state; //0- aguardando o início do jogo (vermelho). 1 - reproduzindo(azul). 2 - escutando (verde) 3- delay
int confirmiterations= 8;
int canceliterations=5;
int pressing[];
int helper;
int helper2;
int nextState;
boolean confirmed ;
boolean attempted;

Random generator;

void setup() {
  GPIO.pinMode(14, GPIO.INPUT);
  GPIO.pinMode(15, GPIO.INPUT);
  GPIO.pinMode(18, GPIO.INPUT);
  GPIO.pinMode(23, GPIO.INPUT);
  
  GPIO.pinMode(24, GPIO.OUTPUT);
  GPIO.pinMode(25, GPIO.OUTPUT);
  GPIO.pinMode(8, GPIO.OUTPUT);
  GPIO.pinMode(7, GPIO.OUTPUT);
  GPIO.pinMode(1, GPIO.OUTPUT);
  GPIO.pinMode(12, GPIO.OUTPUT);
  GPIO.pinMode(16, GPIO.OUTPUT);
  
  GPIO.digitalWrite(24,GPIO.LOW);
  GPIO.digitalWrite(25,GPIO.LOW);
  GPIO.digitalWrite(8,GPIO.LOW);
  GPIO.digitalWrite(7,GPIO.LOW);
  GPIO.digitalWrite(1,GPIO.LOW);//b
  GPIO.digitalWrite(12,GPIO.LOW);//g
  GPIO.digitalWrite(16,GPIO.HIGH);//r
  
  guess = "";
  answer = "";
  state = 0;
  pressing = new int[5];
  confirmed = false;
  attempted=true;
  helper =0;
  helper2=0;
  generator = new Random();
  nextState=0;
  
}

void draw() {
  
  switch(state){
    case 0:
    
    
    switch(helper){
      case 0:
      GPIO.digitalWrite(25,GPIO.LOW);
      GPIO.digitalWrite(7,GPIO.HIGH);
      break;
      case 10:
      GPIO.digitalWrite(8,GPIO.HIGH);
      GPIO.digitalWrite(7,GPIO.LOW);
      break;
      case 20:
      GPIO.digitalWrite(25,GPIO.HIGH);
      GPIO.digitalWrite(8,GPIO.LOW);
      break;
     
    }
     helper++;
     if(helper==30)
       helper=0;
    if(GPIO.digitalRead(14) == GPIO.HIGH){
      state = 3;
      nextState=1;
      GPIO.digitalWrite(16,GPIO.LOW);
      GPIO.digitalWrite(1,GPIO.HIGH);
      helper = 0;
      helper2 = 0;
      GPIO.digitalWrite(24,GPIO.LOW);
      GPIO.digitalWrite(25,GPIO.LOW);
      GPIO.digitalWrite(8,GPIO.LOW);
      GPIO.digitalWrite(7,GPIO.LOW);
    }
    
    break;
    case 1:
    if(attempted){
      answer= answer+ ""+ generator.nextInt(3);
      print(answer);
      attempted=false;
    } else{
      if(helper==30){
        helper=0;
        helper2++;
        if(helper2%2!=0){
          
          
          switch(answer.charAt((helper2-1)/2)){
            case '0':
              GPIO.digitalWrite(24,GPIO.HIGH);
            break;
            case '1':
              GPIO.digitalWrite(25,GPIO.HIGH);
            break;
            case '2':
              GPIO.digitalWrite(8,GPIO.HIGH);
            break;
            case '3':
              GPIO.digitalWrite(7,GPIO.HIGH);
            break;
          }
        } else{
          switch(answer.charAt((helper2 - 2)/2)){
            case '0':
              GPIO.digitalWrite(24,GPIO.LOW);
            break;
            case '1':
              GPIO.digitalWrite(25,GPIO.LOW);
            break;
            case '2':
              GPIO.digitalWrite(8,GPIO.LOW);
            break;
            case '3':
              GPIO.digitalWrite(7,GPIO.LOW);
            break;
          }
        }
      }
      helper++;
      if(helper2/2==answer.length()){
        GPIO.digitalWrite(1,GPIO.LOW);
        GPIO.digitalWrite(12,GPIO.HIGH);
        helper = 0;
        helper2 = 0;
        guess= "";
        state=3;
        nextState=2;
      }
      
      
    }
    break;
    case 2:
      if (GPIO.digitalRead(14) == GPIO.HIGH) {
        // button is pressed
        pressing[0]++;
        if(pressing[0]>=confirmiterations&&!confirmed){
          guess= guess+ "0";
          confirmed = true;
          print(guess+"\n");
        }
      } else if (GPIO.digitalRead(15) == GPIO.HIGH) {
        // button is pressed
        pressing[1]++;
        if(pressing[1]>=confirmiterations&&!confirmed){
          guess= guess+ "1";
          confirmed = true;
          print(guess+"\n");
        }
      }else if (GPIO.digitalRead(18) == GPIO.HIGH) {
        // button is pressed
        pressing[2]++;
         if(pressing[2]>=confirmiterations&&!confirmed){
          guess= guess+ "2";
          confirmed = true;
          print(guess+"\n");
        }
      }else if (GPIO.digitalRead(23) == GPIO.HIGH) {
        pressing[3]++;
        if(pressing[3]>=confirmiterations&&!confirmed){
          guess= guess+ "3";
          confirmed = true;
          print(guess+"\n");
        }
      }else {
        pressing[4]++;
        if(pressing[4]>=5){
          for(int i=0;i<canceliterations;i++){
            pressing[i]=0;
          }
          confirmed = false;
        }
        // button is not pressed
        fill(0);
      }
      if(guess.length()==answer.length()){
        if(guess.equals(answer)){
          attempted=true;
          GPIO.digitalWrite(1,GPIO.HIGH);
          GPIO.digitalWrite(12,GPIO.LOW);
          helper = 0;
          helper2 = 0;
          state=3;
          nextState=1;
        } else{
          GPIO.digitalWrite(12,GPIO.LOW);
          GPIO.digitalWrite(16,GPIO.HIGH);
          answer="";
          state= 3;
          nextState=0;
          print("Sua pontuação foi "+(guess.length()-1)+" cores! Péssimo..");
        }
      }
      
      break;
      case 3:
      helper++;
      if(helper==30){
        helper = 0;
        state=nextState;
      }
      break;
  }
}
