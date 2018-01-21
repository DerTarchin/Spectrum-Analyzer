import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import javax.sound.sampled.*;

boolean debug = true;

// Declare the processing sound variables 
FFT fft;
Minim minim;
AudioInput in;
int mixerIndex;
Mixer.Info[] mixerInfo;

PShader blur;

float scale = 1; // Declare a scaling factor
int bands = 100; // Define how many FFT bands we want
int res = (int)pow(2,10); // Define the resolution of the spectrum analysis
float r_width; // declare a drawing variable for calculating rect width
float[] sum = new float[bands]; // Create a smoothing vector
float smooth_factor = 0.7; // Create a smoothing factor

void setup() {
  size(1280, 720);
  //size(displayWidth, displayHeight);
  //pixelDensity(displayDensity());
  surface.setResizable(true);
  smooth(8);

  // Create and patch the FFT analyzer
  minim = new Minim(this);
  mixerInfo = AudioSystem.getMixerInfo();
  mixerIndex = 0;
  minim.setInputMixer(AudioSystem.getMixer(mixerInfo[mixerIndex]));
  in = minim.getLineIn(Minim.MONO, (int)pow(2,11));
  fft = new FFT(in.bufferSize(), in.sampleRate());
  
  blur = loadShader("blur.glsl"); 
}      

void draw() {
  analyze();
  background(0);
  
  fill(255, 255, 255, 80);
  noStroke();
  //r_width = width/float(bands);
  //for(int i=0; i<bands; i++) {
  //  // Draw the rects with a scale factor
  //  rect( i*r_width, height, r_width-r_width/4, -sum[i]*height*scale );    
  //}
  
  drawView(0);
  //filter(blur);
}

void analyze() {
  fft.forward(in.mix);
  
  // Smooth the FFT data by smoothing factor
  for(int i = 0; i < bands; i++) {
    println(fft.getBand(i));
    sum[i] += (fft.getBand(i) - sum[i]) * smooth_factor;
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

//void findmax() {
//  int pos=-1;
//  float max=Integer.MIN_VALUE; //lowest possible value of an int.
//  for(int i=0;i<fft.spectrum.length;i++)
//  {
//    if(fft.spectrum[i]>max)
//    {
//      pos=i;
//      max=fft.spectrum[i];
//    }
//  }
//}

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
    
    if(debug) {
      stroke(80);
      noFill();
      //ellipse(width/2, height/2, d, d);
    }
    
    noStroke();
    for(int i=0; i < bands; i++) {
      float val = 0;
      
      fill(255,0,0);
      fill(255*noise(i/1.0),255-255*noise(i/1.0),255);
      
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

/* draw outer circle bars, 
given a center, radius, starting angle, angle, spacing and val */
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