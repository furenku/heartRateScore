import processing.serial.*;
import processing.video.*;

boolean testing = false;

String estadosCorazon [] = {
  "piano","forte","ruido",
  "granular","presión","rapido",
  "random","continuo","discontinuo",
  "silencio","vibrato"
};

String estadosCamara [] = {
  "piano","forte","ruido",
  "granular","presión","rapido",
  "random","continuo","discontinuo",
  "silencio","vibrato"
};



class Estado {

  Estado(String _nombre, int _x, int _y ) {
    nombre = _nombre;
    x = _x;
    y = _y; 
  }
  
  String nombre;
  int x, y;

};


Capture video;




int numEstadosCamara = estadosCamara.length;

Estado estados[] = new Estado[ numEstadosCamara ];


int pulso; 


Serial myPort;

PFont font;

int fontSize = 30;


int pulsoBajo = 70;
int pulsoAlto = 150;



/*
vars de camara
*/

PImage prevFrame;
int puerto;
String ip;

float threshold = 150;
int Mx = 0;
int My = 0;
int ave = 0;
 
int ballX = width/8;
int ballY = height/8;
int rsp = 5;


void setup() {

  size(1280,800);


  font = createFont("Arial", fontSize / 1.5);
  textFont( font );

  float step = (2*PI) / numEstadosCamara;

  for( int i = 0; i < estadosCamara.length; i++ ) {
    float angle = step * i;

    float newX = (width/2) + cos( angle ) * width / 2.5;
    float newY = (height/2) + sin( angle ) * height / 2.5;

    estados[i] = new Estado( estadosCamara[i], int(newX), int(newY) );
  }


  String portName = Serial.list()[ 0 ];
  
  for (int i = 0; i < Serial.list().length; i++) {
    println(Serial.list()[i]);
  }

  myPort = new Serial(this, portName, 9600);


  String[] cameras = Capture.list();
  println("Available cameras:");
  
  for (int i = 0; i < cameras.length; i++) {
    println(cameras[i]);
  }
  video = new Capture(this, 640, 480, 30);
  video.start();
  prevFrame = createImage(video.width, video.height, RGB);


}



void pulsar() {

  if( testing ) {

    pulso = int( ( mouseX / float( width ) ) * (pulsoAlto - pulsoBajo)) + pulsoBajo;

    String palabra = obtenerPalabra( pulso );

    dibujarPalabra( palabra,0, ( height / 2 ) + fontSize * 2);

  } else {

    if ( myPort.available() > 0) {  // If data is available,
      pulso = myPort.read();   
      
      println("pulso: " + pulso );
      
      String palabra = obtenerPalabra( pulso );
      dibujarPalabra( palabra,0, ( height / 2 ) + fontSize * 2);
    }
  }



  textAlign(LEFT);
  textSize( fontSize / 1.5 );
  text("ritmo cardiaco: "+pulso, 20, 40 );

}

void draw() {
  

  background( 125 );
  


  stroke(255);
  //fill(255);
  //dibujarEstados( mouseX, mouseY );


  //text( nearest.nombre,  ); //, width, fontSize );

  camara();
  pulsar();



}





float getDistance( int _x1, int _y1, int _x2, int _y2 ) {

  return sqrt( pow( _x1 - _x2, 2) + pow( _y1 - _y2, 2) );

}



Estado findNearest( int _x, int _y ) {

  float minDistance = -1;
  int nearest = -1;
  
  for( int i = 0; i < estadosCorazon.length; i++ ) {

    float di = getDistance( _x, _y, estados[i].x, estados[i].y );

    if( minDistance < 0 ) {
      minDistance = di;
      nearest = i;
    } else {
      if( di < minDistance ) {
        minDistance = di;
        nearest = i;
      }
    }

  }

  return estados[nearest];


}




void dibujarPalabra( String _palabra, int _x, int _y ){
  textSize( fontSize * 1.5 );
  text ( _palabra, _x, _y, width, fontSize * 2 );

}


String obtenerPalabra( int _val ) {
  
  float rango = abs(pulsoAlto - pulsoBajo);
  
  float posicion = ( _val - pulsoBajo ) / rango;

  posicion *= estadosCorazon.length;  
  if( posicion < 0 ) posicion = 0;
  if( posicion > estadosCorazon.length - 1 ) posicion = estadosCorazon.length - 1;

  posicion = floor( posicion );
  
  //println("posicion: " + posicion );
    
  
  return estadosCorazon[ int( posicion ) ];

}





void dibujarEstados(int _x, int _y) {
  
  stroke(0);
  fill(0);
  for( int i = 0; i < estadosCamara.length; i++ ) {
  
    ellipse( estados[i].x, estados[i].y, 20, 20  );
    textSize(10);
    text( estados[i].nombre, estados[i].x, estados[i].y + fontSize );
  }

  stroke(127,0,255);
  noFill();
  strokeWeight(10);
  ellipse( _x, _y, 60, 60 );
  fill(0);
  stroke(0);

  Estado nearest = findNearest(_x, _y);
  
  strokeWeight(1);
  line( _x, _y, nearest.x, nearest.y );



  textAlign(CENTER);
  textSize( fontSize );
  
  dibujarPalabra( nearest.nombre, 0,  ( height / 2 ) - fontSize * 2);
}




void camara() {



  if (video.available()) {
 
    prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); 
    prevFrame.updatePixels();
    video.read();
    
  }

  // image( video, 0, 0, width, height );
 
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();
 
  Mx = 0;
  My = 0;
  ave = 0;
 
 
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
 
      int loc = x + y*video.width;            
      color current = video.pixels[loc];      
      color previous = prevFrame.pixels[loc]; 
 
 
      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous);
      float diff = dist(r1, g1, b1, r2, g2, b2);
 
 
      if (diff > threshold) { 
        pixels[loc] = video.pixels[loc];
        Mx += x;
        My += y;
        ave++;
      } 
      else {
 
        pixels[loc] = video.pixels[loc];
      }
    }
  }
  fill(255);
  rect(0, 0, width, height);
  if (ave != 0) { 
    Mx = Mx/ave;
    My = My/ave;
  }
  if (Mx > ballX + rsp/2 && Mx > 50) {
    ballX+= rsp;
  }
  else if (Mx < ballX - rsp/2 && Mx > 50) {
    ballX-= rsp;
  }
  if (My > ballY + rsp/2 && My > 50) {
    ballY+= rsp;
  }
  else if (My < ballY - rsp/2 && My > 50) {
    ballY-= rsp;
  }
 
  // updatePixels();
  image(video,0,0,width,height);

  fill(255,125);
  rect(0,0,width,height);
  noStroke();

  
  int ballXinterpol = int((ballX/float(640))*width);
  int ballYinterpol = int((ballY/float(480))*height);
  // println(ballYinterpol);
  
  // ellipse(ballXinterpol, ballYinterpol, 40, 40);

  // fill(0);
  dibujarEstados( ballXinterpol, ballYinterpol );



}