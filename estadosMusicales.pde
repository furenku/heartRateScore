PFont f;

int fontSize = 30;

class Estado {
  Estado(String _nombre, int _x, int _y ) {
    nombre = _nombre;
    x = _x;
    y = _y; 
  }
  
  String nombre;
  int x, y;
};



String nombreEstados [] = {
  "uno", "dos", "tres", "cuatro",
  "cinco", "seis", "siete", "ocho",
  "nueve", "diez", "once", "doce"
};

int numEstados = nombreEstados.length;

Estado estados[] = new Estado[ numEstados ];

void setup() {
  size(1280,800);


  f = createFont("Arial", fontSize / 1.5);
  textFont(f);

  float step = (2*PI) / numEstados;

  for( int i = 0; i < nombreEstados.length; i++ ) {
    float angle = step * i;

    float newX = (width/2) + cos( angle ) * width / 3;
    float newY = (height/2) + sin( angle ) * height / 3;

    estados[i] = new Estado( nombreEstados[i], int(newX), int(newY) );
  }



}

void draw() {
  

  background( 125 );
  


  stroke(255);
  fill(255);

  for( int i = 0; i < nombreEstados.length; i++ ) {
    

    ellipse( estados[i].x, estados[i].y, 20, 20  );
    textSize(10);
    text( estados[i].nombre, estados[i].x, estados[i].y + fontSize );
  }
  ellipse( mouseX, mouseY, 20, 20 );
  Estado nearest = findNearest(mouseX, mouseY);
  line( mouseX, mouseY, nearest.x, nearest.y );

  stroke(0);
  textAlign(CENTER);
  textSize( fontSize );
  text( nearest.nombre, 0,  ( height / 2 ) - fontSize * 2, width, fontSize * 2 ); //, width, fontSize );

  text( nearest.nombre, 0,  ( height / 2 ) + fontSize * 2, width, fontSize * 2 ); //, width, fontSize );

}


float getDistance( int _x1, int _y1, int _x2, int _y2 ) {
  return sqrt( pow( _x1 - _x2, 2) + pow( _y1 - _y2, 2) );
}

Estado findNearest( int _x, int _y ) {
  float minDistance = -1;
  int nearest = -1;
  for( int i = 0; i < estados.length; i++ ) {

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