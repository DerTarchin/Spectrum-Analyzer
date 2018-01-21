import processing.sound.*;

// Sound Processing Variables
FFT fft;
AudioIn in;
AudioIn in2;
Amplitude rms;

// Visualizer settings
int bands = 100; // Define how many FFT bands we want
int res = (int)pow(2,10); // Define the resolution of the spectrum analysis
float[] avg = new float[bands]; // Create a smoothing vector
float smooth_factor = 0.7; // Data smoothing factor
float clean_factor = 1; // Volume cleaning factor
View viz;

float amp_scale=2;
float amp_smooth_factor=0.5;
float amp_sum;
float rms_scaled;
//float rms_high;
//float rms_high_prev;

void setup() {
  size(1280, 720, P2D);
  //size(displayWidth, displayHeight);
  //fullScreen(P2D);
  surface.setLocation(displayWidth/2-width/2,displayHeight/2-height/2);
  surface.setResizable(true);
  smooth(8);
  
  // Create and patch the FFT analyzer
  in = new AudioIn(this, 0);
  in.start();
  in2 = new AudioIn(this, 0);
  in2.start();
  fft = new FFT(this, res);
  fft.input(in);
  rms = new Amplitude(this);
  rms.input(in2);
  
  viz = new Circular(this, Circular.OUT);
}      

void draw() {
  //analyze(); // figure out is this the faster one?
  analyzeWithBoost();
  background(0);
  viz.updateFFT(avg);
  viz.updateRMS(amp_sum);
  viz.draw();
  //noLoop();
  
  
  //float diff = ((rms_high - rms_high_prev)/rms_high_prev) * 100;
  //if(diff>10 && rms_high > 200) println(rms_high);
  //rms_high_prev = rms_high;
  
  noStroke();
  fill(255,255,255,30);
  ellipse(width/2, height/2, rms_scaled, rms_scaled);
  //noFill();
  //stroke(255,255,255,120);
  //ellipse(width/2, height/2, rms_high, rms_high);
  
  
}

void analyzeWithBoost() {
  fft.analyze();
  // Smooth the FFT data by smoothing factor
  for(int i = 0; i < bands; i++) {
    avg[i] += (fft.spectrum[i] - avg[i]) * smooth_factor;
  }
  float[] sorted = sort(avg);
  float median;
  if (avg.length % 2 == 0)
    median = ((float)sorted[sorted.length/2] + (float)sorted[sorted.length/2 - 1])/2;
  else
    median = (float) sorted[sorted.length/2];
  for(int i = 0; i < bands; i++) {
    avg[i] -= median * clean_factor;
  }
  amp_sum += (rms.analyze() - amp_sum) * amp_smooth_factor;
  rms_scaled = amp_sum*(height/2)*amp_scale;
  //rms_high *= .99;
  //if(rms_scaled > rms_high) rms_high = rms_scaled;
}

void analyze() {
  fft.analyze();
  // Smooth the FFT data by smoothing factor
  for(int i = 0; i < bands; i++) {
    avg[i] += (fft.spectrum[i] - avg[i]) * smooth_factor;
  }
  float[] sorted = sort(avg);
  float median;
  if (avg.length % 2 == 0)
    median = ((float)sorted[sorted.length/2] + (float)sorted[sorted.length/2 - 1])/2;
  else
    median = (float) sorted[sorted.length/2];
  for(int i = 0; i < bands; i++) {
    avg[i] -= median * clean_factor;
  }
  amp_sum += (rmsAnalyze() - amp_sum) * amp_smooth_factor;
  rms_scaled = amp_sum*(height/2)*amp_scale;
  //rms_high *= .99;
  //if(rms_scaled > rms_high) rms_high = rms_scaled;
}

float rmsAnalyze() {
  float sum = 0;
  int count = 5;
  for(int i=0; i<count; i++)
    sum += avg[i];
  return sum/count;
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