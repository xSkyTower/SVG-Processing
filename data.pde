import gab.opencv.*;
import processing.svg.*;
import java.io.File;

PImage img;
boolean saveSVG = false;
int counter = 1;
String filename = "";

void setup() {
  size(1191, 842); // Format A3 Paysage en pixels (72 DPI)
  img = loadImage("archi.jpg");
  if (img == null) {
    println("Erreur : Image non trouvée !");
    exit();
  }
  img.resize(width, height);
}

void draw() {
  background(255);
  if (saveSVG) beginRecord(SVG, getUniqueFilename());
  drawThreeDetailLevels();
  if (saveSVG) { endRecord(); saveSVG = false; println("SVG sauvegardé sous '" + filename + "'"); }
}

void drawThreeDetailLevels() {
  int bandWidth = width / 3;
  for (int i = 0; i < 3; i++) {
    int blurLevel = i == 0 ? 20 : (i == 1 ? 10 : 2);
    int thresholdLevel = i == 2 ? 120 : 100;
    PImage subImg = img.get(i * bandWidth, 0, bandWidth, height);
    OpenCV tempOpenCV = new OpenCV(this, subImg);
    tempOpenCV.gray();
    tempOpenCV.blur(blurLevel);
    tempOpenCV.threshold(thresholdLevel);
    pushMatrix();
    translate(i * bandWidth, 0);
    drawEdges(tempOpenCV.findContours());
    popMatrix();
  }
}

void drawEdges(ArrayList<Contour> contours) {
  stroke(0);
  noFill();
  for (Contour c : contours) {
    beginShape();
    for (PVector p : c.getPoints()) vertex(p.x, p.y);
    endShape(CLOSE);
  }
}

String getUniqueFilename() {
  do { filename = "output" + counter++ + ".svg"; } while (new File(sketchPath(filename)).exists());
  return filename;
}

void keyPressed() { if (key == 's' || key == 'S') saveSVG = true; }
