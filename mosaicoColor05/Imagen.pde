class Imagen {
  String filename; // Único argumento del Constructor los demás son calculados
  int index;
  color avgColor;
  PImage originalImg;
  PImage smallerImg;
  PImage cellImg;
  int r;
  int g;
  int b;
  
  
  //CONSTRUCTOR
  Imagen(String tempFilename) {
    filename = tempFilename;
    originalImg = loadImage(filename);
    
    smallerImg = createImage(scl, scl, RGB);
    smallerImg.copy(originalImg, 0, 0, originalImg.width, originalImg.height, 0, 0, scl, scl);
    smallerImg.loadPixels();
    // Calculate average color
    int avgR = 0;
    int avgG = 0;
    int avgB = 0;
    pixelsLength = smallerImg.pixels.length;
    for (int i = 0; i < smallerImg.pixels.length; i++) {
      int R =  (smallerImg.pixels[i] >> 16) & 0xFF;
      int G =  (smallerImg.pixels[i] >> 8) & 0xFF;
      int B =  smallerImg.pixels[i] & 0xFF;
      avgR += R;
      avgG += G;
      avgB += B;
    }
    avgR /= smallerImg.pixels.length;
    avgG /= smallerImg.pixels.length;
    avgB /= smallerImg.pixels.length;
    
    avgColor = color(avgR, avgG, avgB);
    r = avgR;
    g = avgG;
    b = avgB;
    cellImg = createImage(scl,scl,RGB);
    cellImg.copy(originalImg, 0, 0, originalImg.width, originalImg.height, 0, 0, scl, scl);
    
  }// ENDS CONSTRUCTOR
  //Métodos
  void getColor() {
  }
  String getPath(){
    return filename;
  }
  
}