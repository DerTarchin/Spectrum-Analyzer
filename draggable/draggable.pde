int posx, posy;
int gmx, gmy; // global mouse
int pgmx, pgmy; // prev global mouse
int flx, fly; // frame location

void setup(){
  fullScreen(P2D);
  noStroke();
  fill(0,255,0,100);
  flx = 100;
  fly = 100;
  surface.setSize(500,500);
  surface.setLocation(100,100);
}

void draw(){
  background(255);
}

void mousePressed(){
  //calculate screen mouse positions before we drag
  pgmx = flx + mouseX;
  pgmy = fly + mouseY;
}

void mouseDragged(){
  rect(0,0,width,height);

  //get x+y position of the frame
  posx = flx;
  posy = fly;
  
  //calculate screen mouse positions
  gmx = posx+mouseX;
  gmy = posy+mouseY;

  //screen x+y movement of mouse
  posx += (gmx - pgmx);  
  posy += (gmy - pgmy);

  //set new frame possition
  surface.setLocation(posx,posy);
  flx = posx;
  fly = posy;

  // Remember the last global position
  pgmx = gmx;  
  pgmy = gmy;
} 