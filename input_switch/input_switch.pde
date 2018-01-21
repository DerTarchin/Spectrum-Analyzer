/*
* This sketch demonstrates how to use the <code>setInputMixer</code> 
  * method of <code>Minim</code> in conjunction with the <code>getLineIn</code> 
  * method. By accessing the <code>Mixer</code> objects of Javasound, 
  * you can find one that corresponds to the input mixer of the sound device 
  * of your choice. You can then set this <code>Mixer</code> as the one 
  * that <code>Minim</code> should use when creating an <code>AudioInput</code> 
  * for you
  * <p>
  * This sketch uses controlP5 for the GUI, a user-contributed Processing library.
  */



import ddf.minim.*;
import controlP5.*;
// need to import this so we can use Mixer and Mixer.Info objects
import javax.sound.sampled.*;

Minim minim;
AudioInput in;

Mixer.Info[] mixerInfo;
int mixerIndex = 0;

void setup()
{
  size(512, 275);
  minim = new Minim(this);  
}

void draw()
{
  background(0);
}

void mousePressed() {
  mixerIndex = (mixerIndex + 1) % AudioSystem.getMixerInfo().length;
  Mixer mixer = AudioSystem.getMixer(mixerInfo[mixerIndex]);
  minim.setInputMixer(mixer);
  in = minim.getLineIn(Minim.MONO);
  println(mixerInfo[mixerIndex].getName());
  
  while(in == null) {
    mixerIndex = (mixerIndex + 1) % AudioSystem.getMixerInfo().length;
    mixer = AudioSystem.getMixer(mixerInfo[mixerIndex]);
    minim.setInputMixer(mixer);
    in = minim.getLineIn(Minim.MONO);
    println(mixerInfo[mixerIndex].getName());
  }
}