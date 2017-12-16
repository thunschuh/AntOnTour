class Drop {


  ////Getter für X,Y, Breite und Höhe
  float getX()
  {
    return xpos - screenLeftX;
  }


  float getY()
  {
    return ypos;
  }


  int getHeight()
  {
    return drop.height;
  }

  int getWidth()
  {
    return drop.width;
  }


  float xpos;
  float ypos, vy;
  float countd;
  PImage drop;


  Drop(float x, float y) {
    drop=loadImage("images/wassertropfen.png");

    xpos=x;
    ypos=y;
  }

  void display() {
    image(drop, xpos-screenLeftX, ypos);
  }

  void move() {
    vy+=0.5;
    ypos+=vy/frameRate;
    if (ypos>=height-90) {
      xpos=random(150, 2500);
      ypos= random(-200, 0);
      vy=0;
    }
  }
}
