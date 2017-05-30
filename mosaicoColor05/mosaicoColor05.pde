// Version 0.5 Beta //<>//
// Based in Obamathon
// https://github.com/ITPNYU/Obamathon
// YouTube video tutorial: https://youtu.be/nnlAH1zDBDE

// Zoom and pan from https://github.com/jinlong25/ProcessingMapZoomPan 

import processing.video.*;

// USER OPTIONS
// USER option: First photo to load
String firstPhoto = "girl.jpg";

// User option: framerate, and resolution of webcam
// You can see your cam capture options in GNULinux with the command  `v4l2-ctl --list-formats-ext`
int fps = 30;
int camW = 640;
int camH = 480;

// User option - Size of sketch
// At present it different from webcam resolution more strange things happen
int surfaceW = 640;
int surfaceH = 480;

// User option: Images directory (the images to create the mosaic)
String photosDir = "photos";

// User option: Size of the cells
int scl = 14;

/* ****
 * There are no more user options below, but cheer ...
 * touch, break, copy, paste, modify :)
 **** */

// Source main photo
PImage photo;
// Main composed mosaic image
PImage mosaicImg;
// Resize it
PImage smaller;

// List of Imagen objects
ArrayList<Imagen> imagenesList;

String[] cameras; // Do we have any camera
Capture cam;  // Variable for capture device
String Time; 
String lastImagePath; //The path of the image from the webcam

//COLOR
int pixelsLength;
ArrayList<Coordenada> coordenadasList; // 

PImage clickedImg;
int clickedImgX, clickedImgY;
int clickedImgW, clickedImgH;
String clickedImgPath;
boolean animatingStatus = false;

// The x and y positions calculate offsets if any (mainly vertical photos)
int posX, posY = 0;

int w, h;
File[] files;

/***
 ** ZOOM & PAN vars
 **/
ArrayList<PasoHistory> historyList;
int originalW;
int originalH;
int clickedMouseX;
int clickedMouseY;

//Define image vars
int imgW;
int imgH;

int centerX;
int centerY;

//Define the zoom vars
int scale = 1;
int maxScale = 10;
float zoomFactor = 0.2;

//Define the pan vars
int panFromX;
int panFromY;

int panToX;
int panToY;

int xShift = 0;
int yShift = 0;

void settings() {
  size(surfaceW, surfaceH);
}
void setup() {
  frameRate(fps);
  cameras = Capture.list();
  if (cameras.length != 0) {
    cam = new Capture(this, camW, camH, fps);
    cam.start();
  }
  historyList = new ArrayList<PasoHistory>();
  coordenadasList = new ArrayList<Coordenada>();
  processAllImages();
  run(firstPhoto);
} // ENDS setup()

void draw() {
  background(0);
  imageMode(CENTER);
  image(mosaicImg, centerX, centerY, imgW, imgH);

  if (animatingStatus) {
    image(clickedImg, clickedImgX, clickedImgY, clickedImgW, clickedImgH);// old ok

    // We animate the image to its final position
    if (clickedImgX > width/2)  clickedImgX -= Math.sqrt(clickedImgX-(width/2) );
    if (clickedImgY > height/2) clickedImgY -= Math.sqrt(clickedImgY-(height/2) );
    
    if (clickedImgX < width/2)  clickedImgX += Math.sqrt(clickedImgX+(width/2) );
    if (clickedImgY < height/2) clickedImgY += Math.sqrt(clickedImgY+(height/2) );
    

    // We animate the image to its real size
    if (clickedImg.width > clickedImgW)  clickedImgW += Math.sqrt(clickedImg.width - clickedImgW);
    if (clickedImg.height > clickedImgH)  clickedImgH += Math.sqrt(clickedImg.height - clickedImgH);

    // if image is positioned and fully resized
    if (clickedImgX == width/2 && clickedImgY == height/2 && clickedImgW == clickedImg.width
      && clickedImgH == clickedImg.height) {
      println("Animation finished");
      coordenadasList.clear();  // Empty the ccoordenadasList
      run(clickedImgPath);
    }
  }
  //TODO
  //if (cam.available() == true) {
  // cam.read();
  //   println(frameRate + " FPS");
  //}
}  // END draw()
void mouseClicked() {
  println(mouseX);
  println(mouseY);
  clickedMouseX = mouseX;
  clickedMouseY = mouseY;
  if (mouseButton == LEFT) {
    if (scale!=1) {
      undoPanZoom();  // Undoing history steps
      scale=1;
    }
    // Search in coordinates list until it is found
    long startCliking = System.currentTimeMillis();
    for (int i = 0; i<coordenadasList.size(); i++) {
      Coordenada pos = coordenadasList.get(i);
      if ((clickedMouseX > pos.x) && (clickedMouseX < pos.x + scl) 
        && (clickedMouseY > pos.y) && (clickedMouseY < pos.y + scl)) {
        //     println("pos.x: "+pos.x);
        clickedImg = pos.image; 
        clickedImgW = pos.image.width/scl;
        clickedImgH = pos.image.height/scl;
        clickedImgX = pos.x;
        clickedImgY = pos.y;
        clickedImgPath = pos.imagePath; 
        animatingStatus =true;
        break;
      }
    }
    long endCliking = System.currentTimeMillis();
    println("Clicking: " + (endCliking - startCliking) );
  }
} // END mouseClicked()

void keyPressed() {
  if (key =='z' || key == 'Z') {
    // if we have at least one camera we take a shot for the mosaic
    if (cameras.length !=0) loadNewImage();
  }
}

// Function to list all the files in a directory
File[] listFiles(String dir) {
  File file = new File(dir); //<>//
  if (file.isDirectory()) {
    File[] files = file.listFiles(); //<>//
    return files; //<>//
  } else {
    // If it's not a directory
    return null; //<>//
  }
}
// Function to create the mosaic 
void run(String path) {
  photo = loadImage(path);
  // If there are larger images, we reduce them
  if ( photo.width > width || photo.height > height ) {
    if ( photo.width/photo.height > width/height ||  photo.width/photo.height == width/height) {
      photo.resize(width, 0); // it is landscape or equal proportion
    }
    if ( photo.width/photo.height < 1 ) {
      photo.resize(0, height);  // is is portrait (vertical)
    }
  }


  // ZOOM & PAN
  originalW = photo.width;
  originalH = photo.height;
  imgW = photo.width;
  imgH = photo.height;
  centerX = surfaceW / 2;
  centerY = surfaceH / 2;
  //ENDS ZOOM & PAN

  positionImg(photo); // We get the positions `x` `y` to place the photo with its margins

  // Creating the imagen for the mosaic
  mosaicImg = createImage(photo.width, photo.height, RGB);

  // how many cols and rows
  w = photo.width/scl;
  h = photo.height/scl;

  smaller = createImage(w, h, RGB);
  smaller.copy(photo, 0, 0, photo.width, photo.height, 0, 0, w, h);

  long startCompositing = System.currentTimeMillis();
  smaller.loadPixels();
  // Columns and rows
  for (int x =0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      // get the color for each pixel
      int index = x + y * w;
      color c = smaller.pixels[index];

      // Draw an image with nearest colors to source pixel

      // find the RGB of the pixel
      int targetR =  (c >> 16) & 0xFF;
      int targetG =  (c >> 8) & 0xFF;
      int targetB =  c & 0xFF;
      double minDist = 1000;
      double distColor = 0;
      int colorId = 0;

      //finding the average color of the image
      int listIndex = 0;
      for (Imagen img : imagenesList) {
        int r = img.r;
        int g = img.g;
        int b = img.b;
        // We compare euclidean distance https://en.wikipedia.org/wiki/Color_difference 
        distColor = Math.sqrt(Math.pow(targetR-r, 2) + Math.pow(targetG-g, 2) + Math.pow(targetB-b, 2));
        if (minDist > distColor ) {
          colorId = listIndex;
          minDist = distColor;
        }
        listIndex++;
      }

      // noStroke();
      //  rect((x*scl)+posX, (y*scl)+posY, scl, scl);

      // Creating the mosaic    
      mosaicImg.set( x*scl, y*scl, imagenesList.get(colorId).smallerImg);

      // Save cell coordinates to the list
      coordenadasList.add(new Coordenada((x*scl)+posX, (y*scl)+posY, imagenesList.get(colorId).originalImg, imagenesList.get(colorId).filename));
    }
  }
  long endCompositing = System.currentTimeMillis();
  println("DRAW: Compositing, Fill cols and rows: "+(endCompositing-startCompositing));

  animatingStatus = false; // In case the run comes from an animation
} // ENDS run()

// Function to load the image taken from the webcam
void loadNewImage() {
  //TODO
  //cam.start();
  cam.read();
  image(cam, surfaceW/2, surfaceH/2);
  //cam.stop();
  // Save the image
  setTimestamp();
  lastImagePath = "data/" + photosDir + "/"+ Time +".png";
  save(lastImagePath);

  // We change size of the mosaic image to that of the capture of the camera
  mosaicImg.resize(camW, camH);
  mosaicImg.copy(cam, 0, 0, width, height, 0, 0, width, height);
  positionImg(mosaicImg); // We get the positions x and y
  // We add it to the list of images
  imagenesList.add(new Imagen(lastImagePath));

  run(lastImagePath);
} // ENDS loadNewImage()


// Function to get the position of the image to add them to the coords when ckicking the mosaic 
void positionImg(PImage photoTmp) {
  posX = (width-photoTmp.width)/2;
  posY = (height-photoTmp.height)/2;
}


//  Function to process images, list of images, etc
// It is executed only once the sketch has started
void processAllImages() {
  // Find all the images
  //TODO: check they are jpeg, png, gif o tga
  files = listFiles(sketchPath("data/"+ photosDir ));

  long startTimeImagenArrayList = System.currentTimeMillis();
  // We create an empty ArrayList and fill it with images
  imagenesList = new ArrayList<Imagen>();
  for (int i = 0; i < files.length-1; i++) { //<>//
    imagenesList.add(new Imagen(files[i+1].toString()));
  }
  long endTimeImagenArrayList = System.currentTimeMillis();
  println("Imagen ArrayList: "+ (endTimeImagenArrayList-startTimeImagenArrayList));
}

//TODO
// Undo the zoom & pan to get the coordinates equivalent to the mouseX and mouseY
void undoPanZoom() {
  for (int i = historyList.size() - 1; i >= 0; i--) { 
    PasoHistory paso = historyList.get(i);
    paso.undoPaso();
    historyList.remove(i);
  }
}
// Function to get the time and pass it to the Time variable
void setTimestamp() {
  String Year, Month, Day, Hour, Minute, Second, Millisecond;
  Year = nf( year(), 4 );
  Month = nf( month(), 2 );
  Day = nf( day(), 2 );
  Hour = nf( hour(), 2 );
  Minute = nf( minute(), 2 );
  Second = nf( second(), 2 );
  Millisecond = nf( millis(), 4);
  Time = Year + Month + Day + "_T" + Hour + Minute + Second + Millisecond ;
}

//ZOOM & PAN functions
//Pan function
void mousePressed() {
  if (mouseButton == RIGHT) undoPanZoom();  // For debugging

  if (mouseButton == LEFT) {
    panFromX = mouseX;
    panFromY = mouseY;
  }
}

//Pan function continued..
void mouseDragged() {
  if (mouseButton == LEFT) {
    panToX = mouseX;
    panToY = mouseY;

    xShift = panToX - panFromX;
    yShift = panToY - panFromY;

    //Only pan with the image occupies the whole display
    if (centerX - imgW / 2 <= 0
      && centerX + imgW / 2 >= width
      && centerY - imgH / 2 <= 0
      && centerY + imgH / 2 >= height) {
      centerX = centerX + xShift;
      centerY = centerY + yShift;
    }

    //Set the constraints for pan
    if (centerX - imgW / 2 > 0) {
      centerX = imgW / 2;
    }

    if (centerX + imgW / 2 < width) {
      centerX = width - imgW / 2;
    }

    if (centerY - imgH / 2 > 0) {
      centerY = imgH / 2;
    }

    if (centerY + imgH / 2 < height) {
      centerY = height - imgH / 2;
    }

    panFromX = panToX;
    panFromY = panToY;
    historyList.add(new PasoHistory("pan", centerX, centerY));
  }
}

//Zoom function
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  //Zoom in
  if (e == -1) {
    println("IN");
    if (scale < maxScale) {
      scale++;
      historyList.add(new PasoHistory("zoom-", centerX, centerY));   
      imgW = int(imgW * (1+zoomFactor));
      imgH = int(imgH * (1+zoomFactor));
      historyList.add(new PasoHistory("pan", centerX, centerY));  

      centerX = centerX - int(zoomFactor * (mouseX - centerX));
      centerY = centerY - int(zoomFactor * (mouseY - centerY));
      println();
    }
  }

  //Zoom out
  if (e == 1) {
    println("OUT");
    if (scale < 1) {
      scale = 1;
      imgW = photo.width;
      imgH = photo.height;
      println("scale = 1 ");
    }

    if (scale > 1) {
      scale--;
      historyList.add(new PasoHistory("zoom+", centerX, centerY));
      imgH = int(imgH/(1+zoomFactor));
      imgW = int(imgW/(1+zoomFactor));
      centerX = centerX + int((mouseX - centerX)
        * (zoomFactor/(zoomFactor + 1)));
      centerY = centerY + int((mouseY - centerY)
        * (zoomFactor/(zoomFactor + 1)));

      if (centerX - imgW / 2 > 0) {
        centerX = imgW / 2;
      }

      if (centerX + imgW / 2 < width) {
        centerX = width - imgW / 2;
      }

      if (centerY - imgH / 2 > 0) {
        centerY = imgH / 2;
      }

      if (centerY + imgH / 2 < height) {
        centerY = height - imgH / 2;
      }
      //Centrado de la imagen cuando se vuelve a hacer pequeña
      if ( width > imgW) {
        println("width: "+width);
        println("imgW: "+imgW);
        println("centerX: "+centerX);
        int padLeft = (width-imgW)/2;

        println("padleft: "+padLeft);
        centerX -= padLeft;
        println("xxx");
      }
      if ( height > imgH) {
        println("height: "+height);
        println("imgH: "+imgH);
        println("centerY: "+centerY);
        int padTop = (height-imgH)/2;

        println("padTop: "+padTop);
        centerY -= padTop;
        println("yyyy");
      }
      historyList.add(new PasoHistory("pan", centerX, centerY));
    }
  }
}