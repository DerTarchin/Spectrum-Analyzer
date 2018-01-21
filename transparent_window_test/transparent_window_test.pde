import com.sun.awt.AWTUtilities;

void setup() {
  size(500,500);
  frame.removeNotify();
  frame.setUndecorated(true);
  AWTUtilities.setWindowOpaque(frame, false); 
//  AWTUtilities.setWindowOpacity(frame,0.5f);
  frame.addNotify();
  
  
}

void draw() {
  background(255);

  
  loadPixels();
  for ( int i = 0 ; i < pixels.length ; i++ ) pixels[i] = 0;
  updatePixels();
  
  fill(255,0,0);
  rect(0,0,50,50);
}
