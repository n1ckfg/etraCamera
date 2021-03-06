import peasy.PeasyCam;

PeasyCam cam;

//red laser scanning
float rThreshold = 0;
float rScale = 0.1;
boolean useSound = true;
boolean showImg = false;
boolean showCam = true;

int sW = 1280;
int sH = 720;
int fps = 30;

PImage img;
PShape shp;
PVector[] pts;
ArrayList<String> stringList;

int scanInterval = 2;
int counter=1;

boolean doCapture = false;
boolean firstRun = true;

Settings settings;

void setup() {
  size(50, 50, P3D);
  surface.setSize(sW, sH);
  frameRate(fps);
  
  cam = new PeasyCam(this, width/2, height/2, 400, 50);

  //settings = new Settings("settings.txt");
  
  img = createImage(sW,sH,RGB);
  img.loadPixels();
  
  pts = new PVector[int(img.pixels.length/scanInterval)];
  
  shp = createShape();
  shp.beginShape(POINTS);
  shp.stroke(255, 63);
  shp.strokeWeight(4);
  for (int i=0; i<pts.length; i++) {
    shp.vertex(0,0,0);
  }
  shp.endShape();
  
  if (useSound) setupSound();
}

void draw() {
  background(0);
  
  if (firstRun) {
    setupCap(sW, sH);
    firstRun = false;
  } else {
    updateCap();
 
    if (!showCam) {
      if (doCapture) {
      if (useSound) updateSound();
      
      if (newFrame) {
        int shapeCounter = 0;
        for (int y=0; y<img.height; y+=scanInterval) {
          for (int x=0; x<img.width; x+=scanInterval) {
            int loc = x + y * img.width;
            float r = red(frame.pixels[loc]);
            
            if (r >= rThreshold) {
              r*=rScale;
              r += red(img.pixels[loc]);
              if (r > 255) r=255;
              if (r < 0) r=0;
              img.pixels[loc] = color(r);
              float z = getDistance(r);
              
              PVector pt = new PVector(0,0,0);
              pt = new PVector((float)x/img.width, (float)y/img.height, z);
              pts[shapeCounter] = pt;
              shp.setVertex(shapeCounter, new PVector(x, y, z * -200.0));
            }
            shapeCounter++;
          }
        }
        img.updatePixels();
        }
      }
      
      if (showImg) {
        image(img, 0, 0); 
      } else {
        shape(shp);
      }
    } else {
      image(frame, 0, 0);
    }
  }
  
  surface.setTitle("" + frameRate);
}

float maxDistance = -1.0;

void getMaxDistance() {
  for (int i=1; i<256; i++) {
    maxDistance += 1.0/i;
  }
}

float getDistance(float val) {
  if (maxDistance < 0) getMaxDistance();
  
  float returns = 0.0;

  for (int i=1; i<val+1; i++) {
    returns += 1.0/i;
  }
  
  return abs(maxDistance - returns) + 1.0;
}
