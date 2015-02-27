import processing.serial.*;

Serial myPort;
int pulso; 
PFont f;
String[] estados = {"piano","forte","ruido","granular","presión","rapido","random","continuo","discontinuo","silencio","vibrato"};
int que = 1;

int pulsoBajo = 70;
int pulsoAlto = 150;


int textSize = 20;

void setup()
{ size (400,400);
  String portName = Serial.list()[1];
  
  myPort = new Serial(this, portName, 9600);
  
  f = createFont ("Opus Metronome", textSize );
  //textfont(f,40);
  
  textSize( textSize );
  textAlign(CENTER);
};

void dibujarPalabra( String _palabra ){
  background (255);
  fill(0);
  text ( _palabra, 0, (height / 2 - (textSize / 2 ) ), width, textSize + 5);
}


void draw() {
  
  if ( myPort.available() > 0) {  // If data is available,
    pulso = myPort.read();   
    
    println("pulso: " + pulso );
    
    String palabra = obtenerPalabra( pulso );
    dibujarPalabra( palabra );

  }
  
  
}



String obtenerPalabra( int _val ) {
  
  float rango = abs(pulsoAlto - pulsoBajo);
  
  float posicion = ( _val - pulsoBajo ) / rango;

  posicion *= estados.length;  
  if( posicion < 0 ) posicion = 0;
  if( posicion > estados.length - 1 ) posicion = estados.length - 1;

  posicion = floor( posicion );
  
  println("posicion: " + posicion );
    
  
  return estados[ int( posicion ) ];

}
