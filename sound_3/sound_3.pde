import processing.sound.*;

// Declare the processing sound variables 
FFT fft;
AudioIn in;
PShader blur;
PGraphics src;
PGraphics pass1, pass2;

float scale = 2; // Declare a scaling factor
int bands = 100; // Define how many FFT bands we want
int res = (int)pow(2,10); // Define the resolution of the spectrum analysis
float r_width; // declare a drawing variable for calculating rect width
float[] sum = new float[bands]; // Create a smoothing vector
float smooth_factor = 0.7; // Create a smoothing factor

void setup() {
  size(1280, 720, P2D);
  //size(displayWidth, displayHeight);
  //pixelDensity(displayDensity());
  surface.setResizable(true);
  smooth(8);

  // Create and patch the FFT analyzer
  in = new AudioIn(this, 0);
  in.start();
  fft = new FFT(this, res);
  fft.input(in);
  
  blur = loadShader("sep_blur.glsl");
  blur.set("blurSize", 100);
  blur.set("sigma", 5.0f);
  src = createGraphics(width, height, P2D); 
  pass1 = createGraphics(width, height, P2D);
  pass1.noSmooth();  
  pass2 = createGraphics(width, height, P2D);
  pass2.noSmooth();
}      

void draw() {
  analyze();
  background(0);
  
  // TEST
  src.beginDraw();
  src.background(0);
  drawViewSrc(0);
  src.endDraw();
  // Applying the blur shader along the vertical direction   
  blur.set("horizontalPass", 0);
  pass1.beginDraw();            
  pass1.shader(blur);  
  pass1.image(src, 0, 0);
  pass1.endDraw();
  // Applying the blur shader along the horizontal direction      
  blur.set("horizontalPass", 1);
  pass2.beginDraw();            
  pass2.shader(blur);  
  pass2.image(pass1, 0, 0);
  pass2.endDraw();          
  image(pass2, 0, 0);
  
  //noStroke();
  //fill(0,0,0,25);
  //rect(0,0,width,height);

  drawView(0);
  //filter(blur);
}

void analyze() {
  fft.analyze();
  // Smooth the FFT data by smoothing factor
  for(int i = 0; i < bands; i++) {
    sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
  }
  float[] sorted = sort(sum);
  float median;
  if (sum.length % 2 == 0)
    median = ((float)sorted[sorted.length/2] + (float)sorted[sorted.length/2 - 1])/2;
  else
    median = (float) sorted[sorted.length/2];
  for(int i = 0; i < bands; i++) {
    sum[i] -= median/2;
  }
}

float diff(float val1, float val2, float scale) {
  float delta = val1 - val2;
  return val2 + delta*scale;
}

void drawView(int index) {
  // draw outer circle view
  if(index == 0) {
    float d = min(height,width)/2; // diameter
    float r = d/2; // radius
    Tuple c = new Tuple(width/2, height/2); // center point
    int offset = 27; // rotation offset
    int amp = (int)(r*scale); // volume amplification 
    float spacing = 0.25; // spacing between bars
    float angle = 360.0/(bands*2); // bar angles
    int end_smoothing = 3;

    if(end_smoothing > 0) sum[0] *= 0.66;
    
    noStroke();
    for(int i=0; i < bands; i++) {
      float val = 0;
      
      fill(255*noise(i/1.0),255-255*noise(i/1.0),255);
      
      fill(255,255,255,60);
      
      if(i < bands-end_smoothing) {
        val = sum[i]*amp;
      }
      else if(i >= bands-end_smoothing) {
        val = diff(sum[0], sum[bands-1-end_smoothing], 
        1/float(end_smoothing)*(end_smoothing-(bands-i)))*amp;
      }

      val = constrain(val, min(amp, 0), max(amp, 0));
       
      drawCircleOuterBars(c, r, offset + angle * i, spacing, angle, val);
      drawCircleOuterBars(c, r, 180 + offset + angle * i, spacing, angle, val);
      //drawCircleOuterBars(c, r, offset + angle * i, spacing, angle, -val);
      //drawCircleOuterBars(c, r, 180 + offset + angle * i, spacing, angle, -val);
    }
  }
}

void drawViewSrc(int index) {
  // draw outer circle view
  if(index == 0) {
    float d = min(height,width)/2; // diameter
    float r = d/2; // radius
    Tuple c = new Tuple(width/2, height/2); // center point
    int offset = 27; // rotation offset
    int amp = (int)(r*scale); // volume amplification 
    float spacing = 1; // spacing between bars
    float angle = 360.0/(bands*2); // bar angles
    int end_smoothing = 3;

    if(end_smoothing > 0) sum[0] *= 0.66;
    
    noStroke();
    for(int i=0; i < bands; i++) {
      float val = 0;
      
      src.fill(255*noise(i/1.0),255-255*noise(i/1.0),255);
      
      if(i < bands-end_smoothing) {
        val = sum[i]*amp;
      }
      else if(i >= bands-end_smoothing) {
        val = diff(sum[0], sum[bands-1-end_smoothing], 
        1/float(end_smoothing)*(end_smoothing-(bands-i)))*amp;
      }

      val = constrain(val, min(amp, 0), max(amp, 0));
       
      drawCircleOuterBarsSrc(c, r, offset + angle * i, spacing, angle, val);
      drawCircleOuterBarsSrc(c, r, 180 + offset + angle * i, spacing, angle, val);
      //drawCircleOuterBars(c, r, offset + angle * i, spacing, angle, -val);
      //drawCircleOuterBars(c, r, 180 + offset + angle * i, spacing, angle, -val);
    }
  }
}

/* draw outer circle bars, 
given a center, radius, starting angle, angle, spacing and val */
void drawCircleOuterBarsSrc(Tuple c, float r, float sa, float spacing, float angle, float val) {
  float cx = parseFloat((int)c.x);
  float cy = parseFloat((int)c.y);
  // bottom start point
  float bsx = cx + r * cos(radians(sa-angle*spacing));
  float bsy = cy + r * sin(radians(sa-angle*spacing));
  //ellipse(x,y,5,5);
  // bottom end point
  float bex = cx + r * cos(radians(sa+angle*spacing));
  float bey = cy + r * sin(radians(sa+angle*spacing));
  //ellipse(x,y,5,5);
  //stroke(255,0,0);
  // top start point
  float tsx = cx + (r+val) * cos(radians(sa-angle*spacing));
  float tsy = cy + (r+val) * sin(radians(sa-angle*spacing));
  // top end point
  float tex = cx + (r+val) * cos(radians(sa+angle*spacing));
  float tey = cy + (r+val) * sin(radians(sa+angle*spacing));
  src.strokeJoin(ROUND);
  src.beginShape();
  src.vertex(bsx, bsy);
  src.vertex(bex, bey);
  src.vertex(tex, tey);
  src.vertex(tsx, tsy);
  src.endShape(CLOSE);
}

void drawCircleOuterBars(Tuple c, float r, float sa, float spacing, float angle, float val) {
  float cx = parseFloat((int)c.x);
  float cy = parseFloat((int)c.y);
  // bottom start point
  float bsx = cx + r * cos(radians(sa-angle*spacing));
  float bsy = cy + r * sin(radians(sa-angle*spacing));
  //ellipse(x,y,5,5);
  // bottom end point
  float bex = cx + r * cos(radians(sa+angle*spacing));
  float bey = cy + r * sin(radians(sa+angle*spacing));
  //ellipse(x,y,5,5);
  //stroke(255,0,0);
  // top start point
  float tsx = cx + (r+val) * cos(radians(sa-angle*spacing));
  float tsy = cy + (r+val) * sin(radians(sa-angle*spacing));
  // top end point
  float tex = cx + (r+val) * cos(radians(sa+angle*spacing));
  float tey = cy + (r+val) * sin(radians(sa+angle*spacing));
  strokeJoin(ROUND);
  beginShape();
  vertex(bsx, bsy);
  vertex(bex, bey);
  vertex(tex, tey);
  vertex(tsx, tsy);
  endShape(CLOSE);
}

void keyPressed() 
{
  if ((key == 'o') || (key == 'O')) {
    println("o");
  } 
  if ((key == 'r') || (key == 'R')) {
    println("r");
  }
}

public class Tuple<X, Y> { 
  public final X x; 
  public final Y y; 
  public Tuple(X x, Y y) { 
    this.x = x; 
    this.y = y; 
  } 
}