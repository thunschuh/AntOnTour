//AntOnTour by Claudia Becker, Janet Michniewicz und Thu Nguyen //<>//
//IFG WS 2014/15 Assignment 10
//Excercise 15 
//Credits to freesound.org and freepik.org

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

//Soundvariablen
Minim minim;
AudioPlayer sound; 
AudioSample leafsound, gameoversound ; 

//Ersellung der Map-Instanz namens 'map'
Map map;

ArrayList rain;

//Antonvariabeln
// Position von Anton mittig der Levelkoordinaten
float playerX, playerY;
//Tempo von Anton 
float playerVX, playerVY;
//Gewindigkeit von Anton die aufs Tempo berechnet wird
float playerSpeed = 150;


//Zählt wie viele Blätter gesammelt werden
int counter;
//Zählt die Gesamtanzahl der Blätter im Level
int counter2;

//Aktueller level
int level=0;

// Variablen fürs die Bildschirmbewegung (Scrollen) 
float screenLeftX, screenTopY;


//Gamestadien
int GAMESTART=0, GAMEWAIT=1, GAMERUNNING=2, GAMEOVER=3, GAMEWON=4, GAMELEVEL2=5;
int gameState;

//Schriftartvariabel;
PFont font;

//Bildervariabeln
PImage backgroundImg;
PImage bgImg;
PImage grassImg;
PImage imgPlayer;
PImage overlay;
PImage startscreen;
PImage gameoverscreen;
PImage leaf;
PImage spider;
PImage winscreen;


//Antons animation (bilderwechsel)
boolean right, left;

//Springlimit
float kMaxPlayerJumpDiff = 220;
//Alte yPosition
float mOriginalPlayerY = playerY;

//Spinnenvariabeln
float ySpider=1;
float spiderVY=25;

//Laufrichtung
PlayerDirection mPlayerDirection = PlayerDirection.RIGHT;

//Kachelvariabeln
boolean ground, uground, udground, lground, rground, ldground, rdground, dground;


void setup() {
  size( 1000, 500 );
  background(0);

  //Erzeugung der Arraylist 
  rain = new ArrayList();

  //Bilder laden
  backgroundImg = loadImage ("images/BG.jpg");
  grassImg = loadImage("images/grass.png");
  startscreen = loadImage("images/Startscreen.jpg");
  overlay = loadImage("images/overlay.png");
  leaf= loadImage("images/E.png");
  gameoverscreen= loadImage("images/gameoverscreen.png");
  spider= loadImage("images/spider.png");
  winscreen=loadImage("images/winnn8.png");


  //schriftart laden
  font = loadFont("data/LIMBO-48.vlw");

  //laden von musik
  minim = new Minim (this);
  sound = minim.loadFile("data/musik.mp3");
  leafsound = minim.loadSample("data/Leaf.mp3");
  gameoversound = minim.loadSample("data/gameover.mp3");

  //Hintergrundmusik wird in Schleife gesetzt
  sound.loop();

  //Laden des Spiellevels
  newGame();
}


//Zeichnet die Spinne 
//int xSpider gibt die x-Positon der Spinne wieder
void drawSpider(float xSpider) {
  //Distanzvariabel zu Anton
  float spiderD;

  //Zeichnet den Spinnenfaden
  stroke(200);
  line(xSpider-screenLeftX, 0, xSpider-screenLeftX, ySpider);
  //Spinne
  image(spider, xSpider-screenLeftX, ySpider);

  //Berechnet die Y-Position der Spinne
  ySpider+=spiderVY/frameRate;

  //Wenn Spinn unten ist geht sie wieder nach oben
  if (ySpider >=330) {
    spiderVY= -100;
  }
  //Wenn Spinne oben ist geht sie nach unten
  if (ySpider <= 0) {
    spiderVY= +100;
  }

  //Berechnet die Distanz von Anton zur Spinne in der Mitte 
  //Wenn die Distanz kleiner als 25 ist, dann ist man Gameover
  spiderD = dist(playerX, playerY, xSpider+32, ySpider);
  if (spiderD < 25) {
    gameState = GAMEOVER;
  }
}//ende Spinne



void drawDrop() {
  float dropD;

  for (int i=0; i<5; i++) {
    //Erzeugung des Objekts von der Klasse Drop namens d
    Drop d = new Drop(random(playerX+200, playerX+1000), random(-500, 0));
    rain.add(d); //Das Objekt wird in die Arraylist hinzugefügt
  }


  for (int i=0; i<5; i++) {
    //Abrufung der Tropfen
    Drop d= (Drop) rain.get(i);
    d.display();
    d.move();

    //Variabeln für die Tropfen
    float halfDropWidth = d.getWidth()/2.0f;
    float halfDropHeight = d.getHeight()/2.0f;
    float dropLeft = d.getX() - halfDropWidth;
    float dropTop = d.getY() - halfDropHeight;

    //Berechnung der Distanz zwischen Tropfen und Anton
    //Wenn die Distanz kleiner oder 20 ist, dann ist man Gameover
    dropD = dist(playerX-screenLeftX, (playerY-screenTopY), dropLeft, dropTop);
    if (dropD <= 20) {
      gameState=GAMEOVER;
    }
  }
}


///Ladet die Map mti den jeweiligen Level
void newGame () {
  //laedt das Level
  map = new Map( "level"+level+".map");
  for ( int x = 0; x < map.w; ++x ) {
    for ( int y = 0; y < map.h; ++y ) {
      //Sucht die Map nach der Kachel S ab
      //und gibt Koordinaten Anton
      if ( map.at(x, y) == 'S' ) {
        playerX = map.centerXOfTile (x);
        playerY = map.centerYOfTile (y);
        //Ersetzt die Kachel mit Z
        map.set(x, y, 'Z');
      }  
      //Such nach der Kachel E
      if ( map.at(x, y) == 'E' ) {
        counter2++;
      }
    }
  }
  playerVX = 0;
  playerVY = 0;
}

////////////////
////TASTATUR STEUERUNG
////////////////
void keyPressed() {  
  PlayerDirection nextPlayerDirection;

  ////////////
  //SPRINGEN  
  ///////////
  if ( keyCode == ' ' && playerVY == 0 ) {
    mOriginalPlayerY = playerY;
    playerSpeed = -500;
    playerVY =playerSpeed;
  }
  ////////////
  //LINKE TASTE  
  ///////////
  if (keyCode == LEFT) {

    playerVX = 150;

    //Animation 
    if ( keyCode == LEFT && left == false ) {
      mPlayerDirection = PlayerDirection.LEFT;
      left =true;
    } else if (keyCode==LEFT &&left == true) {
      left =false;
    }

    //Beginn des Spiel kann er nicht Links gehen
    playerVX = -150;
    if (playerX <= 75) {
      playerVX = 0;
    }

    //Kachel links / Anton stoppt
    if (lground==true)
    {
      playerVX=0;
    }
  } 

  ////////////
  //RECHTE TASTE  
  ///////////
  if (keyCode == RIGHT) {
    playerVX = 150;

    //Animation
    if ( keyCode == RIGHT && right== false) {
      mPlayerDirection = PlayerDirection.RIGHT;
      right =true;
    } else if (keyCode==RIGHT &&right == true) {
      right =false;
    }

    //Kachel rechts / Anton stoppt
    if (rground==true)
    {
      playerVX=0;
    }
  }
}

//Wenn keine Tastegedrückt
void keyReleased() {
  //Anton bleibt stehen
  if (keyCode ==LEFT || keyCode == RIGHT) {
    playerVX=0;
  }

  //Anton fällt
  if (keyCode == ' ') {
    playerSpeed = 150;
    playerVY =+playerSpeed;
  }
}

////////////////
////SPIELERUPDATE
////////////////
void updatePlayer() {

  //Berechnung der Position durch die Addition vom Tempo 
  //die Positionsvariabeln werden in die lokale Variabel nextX,Y gespeichert
  float nextX = playerX + playerVX/frameRate, 
  nextY = playerY + playerVY/frameRate;

  //Gameover wenn die Y-Position groesser als 350 ist
  if (playerY >= 350) {
    gameState = GAMEOVER;
  }

  //Springlimit berechnet 
  //Alte-aktuelle Position des Players darf nicht groesser als die maximale Sprunghoehe sein
  //Sonst abwaerts
  if (mOriginalPlayerY - nextY > kMaxPlayerJumpDiff)
  {
    nextY = playerY;
    playerSpeed = 150;
    playerVY =+playerSpeed;
  }

  ///beruherung der grasshuepfer = gameover 
  // Wenn das unsichtbare Rechteck die Kachel G,H berührt dann Gameover
  if ( map.testTileInRect (nextX-8, nextY-35, 16, 16, "G" ) ) {
    gameState=GAMEOVER;
    gameoversound.trigger();
  }
  if ( map.testTileInRect  (nextX-8, nextY-35, 16, 16, "H" ) ) {
    gameState=GAMEOVER;
    gameoversound.trigger();
  }


  //////ZIELKACHEL LEVEL 1
  if ( map.testTileInRect (nextX-15, nextY-8, 10, 16, "K" ) ) {
    gameState = GAMELEVEL2;
  }

  if ( map.testTileInRect (nextX-8, nextY-8, 2*8, 2*8, "L" ) ) {
    gameState= GAMELEVEL2;
  }
  if ( map.testTileInRect (nextX-8, nextY-8, 2*8, 2*8, "M" ) ) {
    gameState=GAMELEVEL2;
  }



  ///ZIELKACHELLEVEL2
  if ( map.testTileInRect (nextX-8, nextY-8, 2*8, 2*8, "U" ) ) {
    gameState = GAMEWON;
  }
  if ( map.testTileInRect (nextX-8, nextY-8, 2*8, 2*8, "V" ) ) {
    gameState= GAMEWON;
  }
  if ( map.testTileInRect (nextX-8, nextY-8, 2*8, 2*8, "W" ) ) {
    gameState=GAMEWON;
  }



  /////beruherung der ameisenbaer = gameover
  // Wenn das unsichtbare Rechteck die Kachel A,B berührt dann Gameover
  if ( map.testTileInRect (nextX-8, nextY-8, 2*8, 2*8, "A" ) ) {
    gameState=GAMEOVER;
    gameoversound.trigger();
  }
  if ( map.testTileInRect (nextX-8, nextY-8, 2*8, 2*8, "B" ) ) {
    gameState=GAMEOVER;
    gameoversound.trigger();
  }



  //Blätterkachel die verschwinden wenn die berührt werden 
  if ( map.testTileInRect (nextX-15, nextY-8, 10, 2*8, "E" ) ) {
    //fragt ab ob da die reference e ist
    Map.TileReference reference = map.findTileInRect(nextX-8, nextY-8, 2*8, 2*8, "E");

    //Wenn da also blatt ist 
    if (reference != null)
    {
      //ersetze die kachel mit einer leeren kachel und  zaehlt counter hoch und spielt den sound ab
      map.set(reference.x, reference.y, '_');
      counter+=1;
      leafsound.trigger();
    }
  }


  ///springlimit bis fenster oben, faellt dann wieder
  if (nextY <= -10) {
    playerSpeed = 150;
    playerVY =+playerSpeed;
  }



  ////////////////
  ////Prüft ob Kachel vorhanden sind (unter ihm, rechts vom ihm, links vom ihm 
  ////////////////  

  //IST KACHEL UNTER SEINEN FUESSEN?
  if ( map.testTileInRect(nextX, nextY+7, 5, 20, "F") )
  {
    ground = true; //ja
  } else
  {
    ground = false;//nein
  }


  //IST EINE GRASKACHEL UNTER SEINEN FUESSEN?
  if ( map.testTileInRect(nextX, nextY-8, 5, 20, "D") )
  {
    //println("yes bottom!!");
    dground = true;
    //nextY=nextY-5;
  } else
  {
    //  println("no bottom!");
    dground = false;
  }

  /////KACHEL UEBER SEIEN KOPF?
  if ( map.testTileFullyInsideRect(nextX, nextY-8 -35, 5, 30, "D") )
  {
    println("yes bottom!!");
    uground = true;
  } else
  {
    // println("no bottom!");
    uground = false;
  }


  /////KACHEL RECHTS VOM IHM?
  if ( map.testTileInRect(nextX+20, nextY-20, 5, 10, "D") )
  {
    println("yes recyes!!");
    rground = true;
  } else
  {
    // println("no rechts!");
    rground = false;
  }

  /////kachellinks von ihm??
  if ( map.testTileInRect(nextX-40, nextY-20, 5, 10, "D") )
  {
    // println("yes links!!");
    lground = true;
  } else
  {
    //println("no links!");
    lground = false;
  }



  ///Soll aufhören zu fallen bis eine boden kachel da ist 
  if (ground == true) {
    playerVY = 0;
  } else if (ground == false) {
    playerVY =+playerSpeed;
  } 



  ///Soll aufhören zu fallen bis eine bodengraskachel da ist 
  if (dground == true) {
    playerVY = 0;
  }

  ////wenn über ihm eine grasKachel ist faellt er 
  if (uground == true) {
    playerSpeed=200;
    playerVY =+playerSpeed;
  }

  //wenn rechts ihm eine graskachel bleibt stehen
  if (rground == true) {
    playerVX= 0;
  }


  //wenn links kachel dann bleibt stehen
  if (lground == true) {
    playerVX =0;
  }

  //lokalevariabeln werden auf die globalen uebertragen
  playerX = nextX;
  playerY = nextY;
}



// Maps x to an output y = map(x,xRef,yRef,factor), such that
//     - x0 is mapped to y0
//     - increasing x by 1 increases y by factor
float map (float x, float xRef, float yRef, float factor) {
  return factor*(x-xRef)+yRef;
}


void drawBackground() {
  // Explanation to the computation of x and y:
  // If screenLeftX increases by 1, i.e. the main level moves 1 to the left on screen,
  // we want the background map to move 0.5 to the left, i.e. x decrease by 0.5
  // Further, imagine the center of the screen (width/2) corresponds to the center of the level
  // (map.widthPixel), i.e. screenLeftX=map.widthPixel()/2-width/2. Then we want
  // the center of the background image (backgroundImg.width/2) also correspond to the screen
  // center (width/2), i.e. x=-backgroundImg.width/2+width/2.
  float x = map (screenLeftX, map.widthPixel(), -backgroundImg.width/2+width/2, -0.5);
  float y = map (screenTopY, map.heightPixel(), -backgroundImg.height/2+height/2, -0.5);

  //zeichnet den Hintergrund der sich NICHT bewegt 
  image(backgroundImg, 500, 180);

  //Grasshintergrund wird ruebergelegt und bewegt nach links mit durch ScreenLeftX
  image(grassImg, x-screenLeftX-backgroundImg.width+500, y+20);
  //wiederholung des grases, wenn es endet
  if (screenLeftX >= 1130) {
    image(grassImg, x-screenLeftX-backgroundImg.width+3667, y+20);
  }

  //Schattierung des Hintergrundes
  image(overlay, 500, 250);

  //counter 
  stroke(0);
  fill(220);
  textSize(20);
  image(leaf, 900, 30);
  text(counter+ " / ", 940, 30);
  text(counter2, 960, 30);
}


void drawMap() {   
  // The left border of the screen is at screenLeftX in map coordinates
  // so we draw the left border of the map at -screenLeftX in screen coordinates
  // Same for screenTopY.
  map.draw( -screenLeftX, -screenTopY );
}


void drawPlayer() {
  // Zeichnet den Spieler  
  noStroke();
  fill(0, 255, 255);
  imageMode(CENTER);
  PImage playerImage = playerImageForDirection(mPlayerDirection);
  image(playerImage, playerX - screenLeftX, playerY - screenTopY);
}

//Darstellung der Starts-, Gameover- und Winscreen
void drawScreen() { 
  textAlign(CENTER, CENTER);
  fill(255);  
  textSize(40);  
  textFont(font, 48);
  //STARTSCREEN
  if (gameState==GAMESTART) 
  { 
    image(startscreen, 500, 250);
    textSize(25);
    text ("Help Anton to find his home but take care of the dangerous \n world and don't forget to collect food for your family members!", width/2, 200);

    textSize(40);
    text ("»press            to start«", width/2, 300);
    fill(#64081c);
    text ("enter", 470, 300);
  } else  if (gameState==GAMEWAIT) {
    text ("press enter to start", width/2, height/2);
  }
  //GAMEOVERSCREEEN
  else if (gameState==GAMEOVER)
  {
    image(gameoverscreen, 500, 250);
    text ("play again? Press Enter", width/2, height/2);
  }
  //WINSCREEEN
  else if (gameState==GAMEWON) { 
    image (winscreen, 500, 250);

    textSize (45);

    fill(0);
    text ("I can. I win. End of Story!", width/2, 80);
    textSize (30);
    text ("play again? Press enter", width/2, 120);
    fill(#64081c);
    textSize (45);
    text ("win", 434, 80);
  } 
  //LEVEL2N END SCREEN
  else if (gameState == GAMELEVEL2) {
    text ("Press Enter for the next Level", width/2, height/2);
  }
}



void draw() {
  if (gameState == GAMESTART && keyCode == ENTER)
  {
    gameState = GAMERUNNING;
  }

  if (gameState==GAMERUNNING) {
    updatePlayer();
  } else if (keyPressed && key== ENTER) {
    if (gameState==GAMEWAIT) {
      gameState=GAMERUNNING;
    } else if (gameState==GAMEOVER) { 
      gameState=GAMERUNNING; 
      counter2=0;
      newGame(); 
      counter=0;
    } else if (gameState==GAMELEVEL2) {
      counter2=0; //anzahl der gesamten blätter wird fuers neue level zurueck gesetzt
      level++;
      grassImg = loadImage("images/grass1.png");
      gameState=GAMERUNNING; 
      newGame(); 
      counter=0;
    } else if (gameState == GAMEWON) {
      level=0;
      grassImg = loadImage("images/grass.png");
      gameState=GAMERUNNING; 
      counter2=0;
      newGame(); 
      counter=0;
    }
  }

  screenLeftX = playerX -150;
  screenTopY  = -50;

  drawBackground();

  drawMap();
  drawDrop();
  if (level ==1) {
    drawSpider(200);
    drawSpider(1000);
    drawSpider(2500);
  }
  drawPlayer();
  drawScreen();
}//ende draw



//ladet die Bilder fuer die Animation
PImage playerImageForDirection(PlayerDirection direction)
{
  String filename = "";
  switch (direction)
  {
  case RIGHT:
    if (right == false) {
      filename = "right.png";
    } else if (right == true) {
      filename = "right0.png";
    }
    break;
  case LEFT:
    if (left == false) {
      filename = "left.png";
    } else if (left == true) {
      filename = "left0.png";
    }
    break;
  }
  return loadImage("images/" + filename);
}
