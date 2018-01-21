import processing.sound.*;

FFT fft;
AudioIn in;
int res = (int)pow(2, 9);
float amplifier = 3;
float[] spectrum = new float[res];

void setup() {
  size(512, 360);
  background(255);
    
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, res);
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  
  // patch the AudioIn
  fft.input(in);
}      

void draw() { 
  background(255);
  fft.analyze(spectrum);

  for(int i = 0; i < res; i++){
  // The result of the FFT is normalized
  // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    int index = (int)constrain(map(log(res-i),0,6.2383246,res,0),0,res-1);
    stroke(0);
    line( i, height, i, height - spectrum[index]*height*amplifier );
    stroke(255,0,0,126);
    line( i, height, i, height - spectrum[i]*height*amplifier );
  } 
}

void mouseMoved() {
  //println(mouseX + ", " + log(mouseX));
  
  println();
}