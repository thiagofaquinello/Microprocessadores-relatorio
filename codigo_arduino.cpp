#include <Servo.h>

Servo servo1;
Servo servo2;

const int pinoServo1 = 2;
const int pinoServo2 = 3;

const int botoesCabine1[4] = {4, 5, 6, 7};
const int botoesCabine2[4] = {8, 9, 10, 11};
const int botoesCorredor[4] = {A0, A1, A2, A3};

const int angulosAndar[4] = {0, 60, 120, 180};

bool chamadas1[4] = {false, false, false, false};
int andarAtual1 = 0;
int direcao1 = 0;        
int anguloServo1 = 0;
int estado1 = 0;         
unsigned long portaTimer1 = 0;
unsigned long servoTimer1 = 0;

bool chamadas2[4] = {false, false, false, false};
int andarAtual2 = 0;
int direcao2 = 0;        
int anguloServo2 = 0;
int estado2 = 0;         
unsigned long portaTimer2 = 0;
unsigned long servoTimer2 = 0;

void setup() {
  Serial.begin(9600);
  servo1.attach(pinoServo1);
  servo2.attach(pinoServo2);
  
  for(int i = 0; i < 4; i++) {
    pinMode(botoesCabine1[i], INPUT_PULLUP);
    pinMode(botoesCabine2[i], INPUT_PULLUP);
    pinMode(botoesCorredor[i], INPUT_PULLUP); 
  }
  
  servo1.write(anguloServo1);
  servo2.write(anguloServo2);
  Serial.println("Sistema de Elevadores Duplos (Arduino UNO) Iniciado.");
}

bool temChamadaAcima1() { for(int i=andarAtual1+1; i<4; i++) if(chamadas1[i]) return true; return false; }
bool temChamadaAbaixo1() { for(int i=0; i<andarAtual1; i++) if(chamadas1[i]) return true; return false; }
bool temChamadaAcima2() { for(int i=andarAtual2+1; i<4; i++) if(chamadas2[i]) return true; return false; }
bool temChamadaAbaixo2() { for(int i=0; i<andarAtual2; i++) if(chamadas2[i]) return true; return false; }

void lerBotoes() {
  for(int i = 0; i < 4; i++) {
    if(digitalRead(botoesCabine1[i]) == LOW && !chamadas1[i]) {
      chamadas1[i] = true;
      Serial.print("Cabine 1: Destino adicionado -> Andar "); Serial.println(i + 1);
    }
  }

  for(int i = 0; i < 4; i++) {
    if(digitalRead(botoesCabine2[i]) == LOW && !chamadas2[i]) {
      chamadas2[i] = true;
      Serial.print("Cabine 2: Destino adicionado -> Andar "); Serial.println(i + 1);
    }
  }

  for(int i = 0; i < 4; i++) {
    if(digitalRead(botoesCorredor[i]) == LOW) {
      if(!chamadas1[i] && !chamadas2[i] && !(andarAtual1 == i && estado1 == 2) && !(andarAtual2 == i && estado2 == 2)) {
        
        int anguloAlvo = angulosAndar[i];
        
        int dist1 = abs(anguloServo1 - anguloAlvo);
        int dist2 = abs(anguloServo2 - anguloAlvo);
        
        if(dist1 < dist2) {
          chamadas1[i] = true;
          Serial.print("Corredor: Chamada no "); Serial.print(i+1); 
          Serial.print("o Andar enviada para Cabine 1 (Mais Perto por "); 
          Serial.print(dist2 - dist1); Serial.println(" graus de vantagem)");
        } 
        else if(dist2 < dist1) {
          chamadas2[i] = true;
          Serial.print("Corredor: Chamada no "); Serial.print(i+1); 
          Serial.print("o Andar enviada para Cabine 2 (Mais Perto por "); 
          Serial.print(dist1 - dist2); Serial.println(" graus de vantagem)");
        } 
        else {
          if(direcao1 == 0) {
            chamadas1[i] = true;
            Serial.println("Corredor: Empate absoluto! Enviado para Cabine 1");
          } else {
            chamadas2[i] = true;
            Serial.println("Corredor: Empate absoluto! Enviado para Cabine 2");
          }
        }
        delay(200); 
      }
    }
  }
}

void loop() {
  lerBotoes();
  unsigned long tempoAtual = millis();

  if (estado1 == 0) { 
    if (chamadas1[andarAtual1]) {
      estado1 = 2; 
      portaTimer1 = tempoAtual;
      chamadas1[andarAtual1] = false;
      Serial.print("Cabine 1: Porta Aberta no "); Serial.print(andarAtual1 + 1); Serial.println("o Andar.");
    } else if (temChamadaAcima1()) {
      direcao1 = 1; estado1 = 1; servoTimer1 = tempoAtual;
    } else if (temChamadaAbaixo1()) {
      direcao1 = -1; estado1 = 1; servoTimer1 = tempoAtual;
    }
  }
  else if (estado1 == 1) { 
    if (tempoAtual - servoTimer1 >= 30) { 
      servoTimer1 = tempoAtual;
      int alvoAngulo = angulosAndar[andarAtual1 + direcao1];
      
      if (anguloServo1 < alvoAngulo) anguloServo1++;
      else if (anguloServo1 > alvoAngulo) anguloServo1--;
      servo1.write(anguloServo1);
      
      if (anguloServo1 == alvoAngulo) { 
        andarAtual1 += direcao1;
        
        if (chamadas1[andarAtual1] || (direcao1 == 1 && !temChamadaAcima1()) || (direcao1 == -1 && !temChamadaAbaixo1())) {
          estado1 = 2; 
          portaTimer1 = tempoAtual;
          chamadas1[andarAtual1] = false;
          Serial.print("Cabine 1: Parando no "); Serial.print(andarAtual1 + 1); Serial.println("o Andar.");
        }
      }
    }
  }
  else if (estado1 == 2) { 
    if (tempoAtual - portaTimer1 >= 5000) {
      estado1 = 0; direcao1 = 0; 
      Serial.print("Cabine 1: Porta Fechada no "); Serial.print(andarAtual1 + 1); Serial.println("o Andar.");
    }
  }


  if (estado2 == 0) { 
    if (chamadas2[andarAtual2]) {
      estado2 = 2; 
      portaTimer2 = tempoAtual;
      chamadas2[andarAtual2] = false;
      Serial.print("Cabine 2: Porta Aberta no "); Serial.print(andarAtual2 + 1); Serial.println("o Andar.");
    } else if (temChamadaAcima2()) {
      direcao2 = 1; estado2 = 1; servoTimer2 = tempoAtual;
    } else if (temChamadaAbaixo2()) {
      direcao2 = -1; estado2 = 1; servoTimer2 = tempoAtual;
    }
  }
  else if (estado2 == 1) { 
    if (tempoAtual - servoTimer2 >= 30) { 
      servoTimer2 = tempoAtual;
      int alvoAngulo = angulosAndar[andarAtual2 + direcao2];
      
      if (anguloServo2 < alvoAngulo) anguloServo2++;
      else if (anguloServo2 > alvoAngulo) anguloServo2--;
      servo2.write(anguloServo2);
      
      if (anguloServo2 == alvoAngulo) {
        andarAtual2 += direcao2;
        
        if (chamadas2[andarAtual2] || (direcao2 == 1 && !temChamadaAcima2()) || (direcao2 == -1 && !temChamadaAbaixo2())) {
          estado2 = 2; 
          portaTimer2 = tempoAtual;
          chamadas2[andarAtual2] = false;
          Serial.print("Cabine 2: Parando no "); Serial.print(andarAtual2 + 1); Serial.println("o Andar.");
        }
      }
    }
  }
  else if (estado2 == 2) { 
    if (tempoAtual - portaTimer2 >= 5000) {
      estado2 = 0; direcao2 = 0;
      Serial.print("Cabine 2: Porta Fechada no "); Serial.print(andarAtual2 + 1); Serial.println("o Andar.");
    }
  }
}