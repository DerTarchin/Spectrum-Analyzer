public class View {
  public int res = (int)pow(2,10); // Define the resolution of the spectrum analysis
  public float smooth_factor = 0.7; // Data smoothing factor
  public float clean_factor = 1; // Volume cleaning factor
  
  private int bands; // Define how many FFT bands we want
  public float[] avg;
  public float rms_avg;
  
  private PApplet sketch;

  public View(PApplet sketch) {
    this.sketch = sketch;
  }
  
  public void draw() {
  }
  
  public void updateFFT(float[] avg) {
    this.avg = avg;
    this.bands = avg.length;
  }
  
  public void updateRMS(float rms_scaled) {
    rms_avg = rms_scaled;
  }
}