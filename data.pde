import gab.opencv.*;
import processing.svg.*;
import java.io.File;

PImage img;
boolean saveSVG = false;
int compteur = 1;
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
  if (saveSVG) beginRecord(SVG, UniqueFilename());
  dessinTroisNiveauxDétails();
  if (saveSVG) { endRecord(); saveSVG = false; println("SVG sauvegardé sous '" + filename + "'"); }
}

void dessinTroisNiveauxDétails() {
  int LargeurBandes = width / 3;
  for (int i = 0; i < 3; i++) {
    int NiveauFlou = i == 0 ? 20 : (i == 1 ? 10 : 2);
    int Seuil = i == 2 ? 120 : 100;
    PImage subImg = img.get(i * LargeurBandes, 0, LargeurBandes, height);
    OpenCV tempOpenCV = new OpenCV(this, subImg);
    tempOpenCV.gray();
    tempOpenCV.blur(NiveauFlou);
    tempOpenCV.threshold(Seuil);
    pushMatrix();
    translate(i * LargeurBandes, 0);
    dessinBords(tempOpenCV.findContours());
    popMatrix();
  }
}

void dessinBords(ArrayList<Contour> contours) {
  stroke(0);
  noFill();
  for (Contour c : contours) {
    beginShape();
    for (PVector p : c.getPoints()) vertex(p.x, p.y);
    endShape(CLOSE);
  }
}

String UniqueFilename() {
  do { filename = "output" + compteur++ + ".svg"; } while (new File(sketchPath(filename)).exists());
  return filename;
}

void keyPressed() { if (key == 's' || key == 'S') saveSVG = true; }
