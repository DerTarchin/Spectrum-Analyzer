public class Circular extends View {
  final static int OUT = 1;
  final static int IN = 2;
  final static int BOTH = 3;
  final static int DOT = 4;
  
  // EQ variables
  public float minheight; // minheight
  public float diameter; // diameter
  public int repeat; // range repeat
  private int circleType;
  private Tuple c; // center point
  private int offset; // rotation offset
  private int amp; // volume amplification 
  private float angle; // bar angles
  private int transition; // transition
  private float scale; // scale
  private float rms_boost_val; // diameter boost
  private float rms_boost_vol_min; // volume-based change
  private float rms_boost_change_min; // perc-based change
  private float rms_high;
  private float rms_high_prev;
  private float rms_orig_diameter;
  private float rms_boost_val_max;
  
  // Window variables
  private int pwinw, pwinh;
  private PShader shader;
  private PGraphics blur, pass1, pass2;
  
  private color c1, c2, c3, c4;
  
  public Circular(PApplet sketch, int circleType) {
    super(sketch);
 
    this.circleType = circleType;
    shader = loadShader("blur.glsl");
    shader.set("blurSize", 100);
    shader.set("sigma", 5.0f);
    blur = createGraphics(width, height, P2D); 
    pass1 = createGraphics(width, height, P2D);
    pass2 = createGraphics(width, height, P2D);
    pass1.noSmooth();  
    pass2.noSmooth();
    pwinw = width;
    pwinh = height;
    
    c = new Tuple(width/2, height/2);
    resetDefaults();
  }
  
  public void resetDefaults() {
    c = new Tuple(width/2, height/2);
    diameter = min(height,width)/2;
    scale = 2;
    amp = int((diameter/2)*scale); 
    repeat = 2;
    angle = 360.0/(bands*repeat);
    transition = 3;
    minheight = .5;
    offset = 25;
    
    rms_boost_val = 1; // diameter boost
    rms_boost_vol_min = 0.26; // noboost = .05
    rms_boost_change_min = 10; // noboost = 20
    rms_boost_val_max = 1.15;
    rms_orig_diameter = diameter;
    
    rms_high = rms_high_prev = 0;
    
    c1 = color(35,68,83);
    c2 = color(5,9,10);
    c3 = color(59,158,99);
    c4 = color(10,24,15);
  }
  
  public void draw() {
    updateWindow();
    rms_high *= .99;
    if(rms_avg > rms_high) rms_high = rms_avg;
    float diff = ((rms_high - rms_high_prev)/rms_high_prev) * 100;
    //if(diff > rms_boost_change_min)
      //println(int(diff) + " : " + rms_avg);
    if(diff>rms_boost_change_min && rms_high>rms_boost_vol_min) {
      float boost = map(diff, 0, 100, 0, rms_boost_val_max);
      rms_boost_val = rms_boost_val + boost;
      println(int(diff) + " : " + boost);
    }
    rms_high_prev = rms_high;
    
    rms_boost_val = constrain(rms_boost_val*.98,1,rms_boost_val_max);
    diameter = rms_orig_diameter*rms_boost_val;
    
    this.drawEQBlur();
    
    noFill();
    stroke(255);
    //ellipse(width/2, height/2, diameter + rms_avg*amp, diameter + rms_avg*amp);
    
    stroke(255,255,255,100);
    //ellipse(width/2, height/2, diameter + rms_boost_vol_min*amp, diameter + rms_boost_vol_min*amp);
    
    this.drawEQ();     
  }
  
  private void drawBg() {
    float rms_perc = rms_avg*300; // avg between 0 and 100
    float cx = parseFloat((int)c.x);
    float cy = parseFloat((int)c.y);
    
    float r = mix(mix(red(c1),red(c3),rms_perc), mix(red(c2),red(c4),rms_perc), 100);
    float g = mix(mix(green(c1),green(c3),rms_perc), mix(green(c2),green(c4),rms_perc), 100);
    float b = mix(mix(blue(c1),blue(c3),rms_perc), mix(blue(c2),blue(c4),rms_perc), 100);
    blur.background(r,g,b);
    blur.noFill();
    for(int i=0; i<max(width,height); i++) {
      float perc = (i*100)/float(max(width,height));
      r = mix(mix(red(c1),red(c3),rms_perc), mix(red(c2),red(c4),rms_perc), perc);
      g = mix(mix(green(c1),green(c3),rms_perc), mix(green(c2),green(c4),rms_perc), perc);
      b = mix(mix(blue(c1),blue(c3),rms_perc), mix(blue(c2),blue(c4),rms_perc), perc);
      blur.stroke(r,g,b);
      blur.strokeWeight(1);
      blur.ellipse(cx, cy, float(i), float(i));
    }
  }
  
  /* Draw blurred EQ effect */
  private void drawEQBlur() {
    blur.beginDraw();
    blur.clear();
    blur.background(0);
    //this.drawBg();
    for(int j=0; j < repeat; j++) {
      for(int i=0; i < bands; i++) {
        float val = this.getValue(i);
        if(val < minheight*2) val = minheight*2;
        val *= 1.1;
        float repeat_offset = (360/float(repeat))*j;
        
        blur.fill(255*noise(i/1.0),255-255*noise(i/1.0),255);
        blur.noStroke();
        if(circleType == OUT || circleType == BOTH) {
          drawBar(repeat_offset + offset + angle * i, val, true);
        }
        else if(circleType == IN || circleType == BOTH) {
          drawBar(repeat_offset + offset + angle * i, -val/2, true);
        }
        else { // DOTS
          // default
        }
      }
    }
    blur.endDraw();
    shader.set("horizontalPass", 0);
    pass1.beginDraw();            
    pass1.shader(shader);  
    pass1.image(blur, 0, 0);
    pass1.endDraw();
    shader.set("horizontalPass", 1);
    pass2.beginDraw();            
    pass2.shader(shader);  
    pass2.image(pass1, 0, 0);
    pass2.endDraw();          
    image(pass2, 0, 0); 
  }
  
  private void drawEQ() {
    for(int j=0; j < repeat; j++) {
      for(int i=0; i < bands; i++) {
        float val = this.getValue(i);
        float repeat_offset = (360/float(repeat))*j;
        
        fill(255,255,255,100);
        noStroke();
        if(circleType == OUT || circleType == BOTH) {
          drawBar(repeat_offset + offset + angle * i, val);
        }
        if(circleType == IN || circleType == BOTH) {
          drawBar(repeat_offset + offset + angle * i, -val/2);
        }
        if(circleType == DOT) { // DOTS
          // default
        }
      }
    }
  }
  
  private float getValue(int i) {
    float r = diameter/2;
    float val = 0;      
    if(i < bands-transition) val = avg[i]*amp;
    else if(i >= bands-transition) {
      float valmax = constrain(avg[0]*0.66*amp, min(r, val+minheight), max(r, val+minheight));
      val = this.diff(valmax/amp, avg[bands-1-transition], 
      1/float(transition)*(transition-(bands-i)))*amp;
      fill(255,0,0);
    }
    return constrain(val, min(r, minheight), max(r, minheight));
  }
  
  private void drawBar(float sa, float val) {
    this.drawBar(sa, val, false);
  }
  
  private void drawBar(float sa, float val, boolean isBlur) {
    float spacing = 0.25;
    if(isBlur) spacing = 0.65;
    
    float r = diameter/2; // radius
    float cx = parseFloat((int)c.x);
    float cy = parseFloat((int)c.y);
    // bottom start point
    float bsx = cx + r * cos(radians(sa-angle*spacing));
    float bsy = cy + r * sin(radians(sa-angle*spacing));
    // bottom end point
    float bex = cx + r * cos(radians(sa+angle*spacing));
    float bey = cy + r * sin(radians(sa+angle*spacing));
    // top start point
    float tsx = cx + (r+val) * cos(radians(sa-angle*spacing));
    float tsy = cy + (r+val) * sin(radians(sa-angle*spacing));
    // top end point
    float tex = cx + (r+val) * cos(radians(sa+angle*spacing));
    float tey = cy + (r+val) * sin(radians(sa+angle*spacing));
    
    if(isBlur) {
      blur.strokeJoin(ROUND);
      blur.beginShape();
      blur.vertex(bsx, bsy);
      blur.vertex(bex, bey);
      blur.vertex(tex, tey);
      blur.vertex(tsx, tsy);
      blur.endShape(CLOSE);
    }
    else {
      strokeJoin(ROUND);
      beginShape();
      vertex(bsx, bsy);
      vertex(bex, bey);
      vertex(tex, tey);
      vertex(tsx, tsy);
      endShape(CLOSE);
    }
  }
  
  private float diff(float val1, float val2, float scale) {
    float delta = val1 - val2;
    return val2 + delta*scale;
  }
  
  /* checks if window has been resized */
  private void updateWindow() {
    if(width != pwinw || height != pwinh) {
      pwinw = width;
      pwinh = height;
      blur = createGraphics(width, height, P2D); 
      pass1 = createGraphics(width, height, P2D);
      pass2 = createGraphics(width, height, P2D);
      pass1.noSmooth();  
      pass2.noSmooth();
      //c = new Tuple(width/2, height/2);
      //diameter = min(height,width)/2;
      //amp = int((diameter/2)*scale);
      this.resetDefaults();
    }
  }
  
  private float mix(float start, float end, float perc) {
    return constrain(map(perc, 0, 100, start, end), min(start,end), max(start,end));
  }
}