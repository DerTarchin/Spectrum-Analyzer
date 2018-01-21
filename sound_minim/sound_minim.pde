import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.signals.*;
 
Minim minim;
AudioPlayer jingle;
AudioOutput out;
AudioInput input;
FFT fft;
String windowName;
 
void setup()
{
  size(200, 200, P3D);
  textMode(SCREEN);
 
  minim = new Minim(this);
  input = minim.getLineIn(Minim.MONO, (int)pow(2,11)); 
  fft = new FFT(input.bufferSize(), input.sampleRate()); 
 
}
 
void draw()
{ 
  background(0);
  stroke(255);
  // perform a forward FFT on the samples in jingle's left buffer
  // note that if jingle were a MONO file, 
  // this would be the same as using jingle.right or jingle.left
  fft.forward(input.mix);
  for(int i = 0; i < 100; i++)
  {
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    line(i, height, i, height - fft.getBand(i)*10);
  }
  //println(fft.specSize());
  fill(128);
}
 
void stop()
{
  // always close Minim audio classes when you finish with them
  out.close();
  minim.stop();
 
  super.stop();
}