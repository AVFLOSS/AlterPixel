// Version 0.7 Beta //<>// //<>// //<>// //<>// //<>//
// Based in Obamathon
// https://github.com/ITPNYU/Obamathon
// YouTube video tutorial: https://youtu.be/nnlAH1zDBDE

// Zoom and pan from https://github.com/jinlong25/ProcessingMapZoomPan 

import processing.video.*;
import controlP5.*;

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
int scl = 16;

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
ArrayList<Coordenada> coordenadasListCopy; // 

PImage clickedImg;
int clickedImgX, clickedImgY;
int clickedImgW, clickedImgH;
String clickedImgPath;
boolean animatingStatus = false;

// The x and y positions calculate offsets if any (mainly vertical photos)
int posX, posY = 0;

int w, h;
File[] files;

/**
 ** Text field
 **/
ControlP5 cp5;
boolean textfieldShow = false;
String lastImageName;
String lastEmail;
Textlabel emailLabel;
Textlabel msgLabel;
Label labelMsg;
boolean imagesProcessed = false;
boolean sendingMail = false;


/***
 ** ZOOM & PAN vars
 **/
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
int maxScale = 5;
float zoomFactor = 0.3;

//Define the pan vars
int panFromX;
int panFromY;

int panToX;
int panToY;

int xShift = 0;
int yShift = 0;

void settings() {
  size(surfaceW, surfaceH, P2D);
}
void setup() {
  frameRate(fps);
  //Check to see if there is a webcam
  cameras = Capture.list();
  if (cameras.length != 0) {
    cam = new Capture(this, camW, camH, fps);
    cam.start();
  }
  coordenadasList = new ArrayList<Coordenada>();
  setTextField();  //in functions
  thread("processAllImages");
} // ENDS setup()

//https://forum.processing.org/two/discussion/19731/#Comment_83034
synchronized void draw() {
  background(0);
  if (!imagesProcessed) {
    textSize(50);
    fill(255);
    text("Loading...", width/2 - textWidth("Loading...")/2, height/2 - 25);
  } else if(sendingMail){
    textSize(50);
    fill(255);
    text("Enviando mail...", width/2 - textWidth("Enviando mail...")/2, height/2 - 25); 
  }else{
    //  background(0);
    imageMode(CENTER);
    image(mosaicImg, centerX, centerY, imgW, imgH);
    //  noTint();
    //  if (textfieldShow) tint(255, 150);

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
        //    println("Animation finished");
        coordenadasList.clear();  // Empty the ccoordenadasList
        run(clickedImgPath);
      }
    }
  }
}  // END draw()

void mouseClicked() {
  if (textfieldShow) return;
  println("click mouseX: "+mouseX);
  println("click mouseY: "+mouseY);
  clickedMouseX = mouseX;
  clickedMouseY = mouseY;
  if (mouseButton == LEFT) {
    // Search in coordinates list until it is found
    long startCliking = System.currentTimeMillis();
    for (int i = 0; i<coordenadasList.size(); i++) {
      Coordenada pos = coordenadasList.get(i);
      if ( (mouseX >= pos.x) && (mouseX <= pos.x + scl) 
        && (mouseY >= pos.y) && (mouseY <= pos.y + scl) ) {
        clickedImg = pos.image; 
        clickedImgW = pos.image.width/scl;
        clickedImgH = pos.image.height/scl;
        clickedImgX = int(pos.x);
        clickedImgY = int(pos.y);
        clickedImgPath = pos.imagePath; 
        animatingStatus =true;
        println("clickedImgX = pos.x: "+pos.x);
        println("clickedImgY = pos.y: "+pos.y);
        break;
      }
    }
 //   println("nada encontrado");
    long endCliking = System.currentTimeMillis();
    println("Clicking: " + (endCliking - startCliking) );
  }
} // END mouseClicked()

void keyPressed() {
  labelMsg.hide();
  if (key =='z' || key == 'Z') {
    // if we have at least one camera we take a shot for the mosaic
    if (cameras.length !=0) loadNewImage();
  } 
  
  if (key==ESC) {
    key=0;  //Para que no se cierre con Escape
    cp5.hide(); 
    cp5.get(Textfield.class, "").clear();
    textfieldShow = false;
  }
  if (key== 7) { //control+g
    //lastImageName = saveImage();
    cp5.get(Textfield.class, "").clear();
    labelMsg.hide();
    textfieldShow = true;
    cp5.show();
  }
}
String saveImage() {
  setTimestamp();
  save("imagenes/pixelate_"+Time+".jpg");
  return  "pixelate_"+Time+".jpg";
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
  //println("inicio pos.x: "+ coordenadasList.get(0).x);
  //println("inicio pos.y: "+ coordenadasList.get(0).y);
  long endCompositing = System.currentTimeMillis();
  println("DRAW: Compositing, Fill cols and rows: "+(endCompositing-startCompositing));
  coordenadasListCopy = coordenadasList;

  animatingStatus = false; // In case the run comes from an animation
  scale=1;
  
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
  lastImagePath = "data/" + photosDir + "/"+ Time +".jpg";
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
  for (int i = 0; i < files.length-1; i++) {
    imagenesList.add(new Imagen(files[i+1].toString()));
  }
  long endTimeImagenArrayList = System.currentTimeMillis();
  println("Imagen ArrayList: "+ (endTimeImagenArrayList-startTimeImagenArrayList));
  run(firstPhoto);
  synchronized(this) {
    imagesProcessed = true;
  }
}
