
import ipcapture.*;
import processing.video.*;
import oscP5.*;
import netP5.*;
import gab.opencv.*;

OpenCV opencv;
PImage img, canny;

int numPixelsOrig;
int numPixels;
boolean first = true;

int boxWidth = 8;
int boxHeight = 6;

int numHoriz = 640/boxWidth;
int numVert = 480/boxHeight;

color[] downPix = new color[numHoriz * numVert];

IPCapture video;
OscP5 oscP5;
NetAddress dest;

void setup() {
  size(640,480,P2D);
  video = new IPCapture(this, "http://10.200.177.45:8080/videofeed", "", "");
  video.start();
  numPixelsOrig = video.width * video.height;
  loadPixels();
  noStroke();
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);
  
}
void draw() {
  
  
    video.read();
    //image(video,0,0, video.width/4, video.height/4);
    image(video,0,0);
    saveFrame("test.jpg");
    img = loadImage("test.jpg");
    print("some");
    opencv = new OpenCV(this,img);
    opencv.findCannyEdges(20,75);
    canny = opencv.getSnapshot();
    image(canny,0,0);
    saveFrame("canny.jpg");
    video.loadPixels(); // Make the pixels of video available
    //PImage img = loadImage(video.pixels);
    
    /*for (int i = 0; i < numPixels; i++) {
      int x = i % video.width;
      int y = i / video.width;
      float xscl = (float) width / (float) video.width;
      float yscl = (float) height / (float) video.height;
      
      float gradient = diff(i, -1) + diff(i, +1) + diff(i, -video.width) + diff(i, video.width);
      fill(color(gradient, gradient, gradient));
      rect(x * xscl, y * yscl, xscl, yscl);
    } */
  int boxNum = 0;
  int tot = boxWidth*boxHeight;
  for (int x = 0; x < 640; x += boxWidth) {
     for (int y = 0; y < 480; y += boxHeight) {
        float red = 0, green = 0, blue = 0;
        
        for (int i = 0; i < boxWidth; i++) {
           for (int j = 0; j < boxHeight; j++) {
              int index = (x + i) + (y + j) * 640;
              red += red(canny.pixels[index]);
              green += green(canny.pixels[index]);
              blue += blue(canny.pixels[index]);
           } 
        }
       downPix[boxNum] =  color(red/tot, green/tot, blue/tot);
      // downPix[boxNum] = color((float)red/tot, (float)green/tot, (float)blue/tot);
       fill(downPix[boxNum]);
       
       int index = x + 640*y;
       red += red(video.pixels[index]);
       green += green(video.pixels[index]);
       blue += blue(video.pixels[index]);
      //fill (color(red, green, blue));
       rect(x, y, boxWidth, boxHeight);
       boxNum++;
      /* if (first) {
         println(boxNum);
       } */
     } 
  }
  if(frameCount % 2 == 0)
    sendOsc(downPix);

  
  first = false;
  fill(0);
  text("Sending 100 inputs to port 6448 using message /wek/inputs", 10, 10);

}

float diff(int p, int off) {
  if(p + off < 0 || p + off >= numPixels)
    return 0;
  return red(video.pixels[p+off]) - red(video.pixels[p]) +
         green(video.pixels[p+off]) - green(video.pixels[p]) +
         blue(video.pixels[p+off]) - blue(video.pixels[p]);
}

void sendOsc(int[] px) {
  OscMessage msg = new OscMessage("/wek/inputs");
 // msg.add(px);
   for (int i = 0; i < px.length; i++) {
      msg.add(float(px[i])); 
   }
  oscP5.send(msg, dest);
}