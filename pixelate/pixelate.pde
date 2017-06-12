// Version 0.7 Beta //<>// //<>// //<>// //<>// //<>// //<>// //<>//
// 12/06/2017
// Based in Obamathon
// https://github.com/ITPNYU/Obamathon
// YouTube video tutorial: https://youtu.be/nnlAH1zDBDE


import processing.video.*;
import g4p_controls.*;
import java.awt.Font;

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
// List of icons for the grid
ArrayList<Icon> iconsList;

String[] cameras; // Do we have any camera
Capture cam;  // Variable for capture device
String Time; 
String lastImagePath; //The path of the image from the webcam

//COLOR
int pixelsLength;
ArrayList<Coordenada> coordenadasList; // 
ArrayList<Coordenada> coordenadasListCopy; // 

int compIndex = 0;
boolean isComposited = false;
PImage clickedImg;
int clickedImgX, clickedImgY;
int clickedImgW, clickedImgH;
String clickedImgPath;
boolean isAnimating = false;

// The x and y positions calculate offsets if any (mainly vertical photos)
int posX, posY = 0;

int w, h;
File[] files;

/**
 ** Text field
 **/
GTextField mailField;
GLabel lblMail, lblError;
boolean textfieldShow = false;
String lastImageName;
String lastEmail;


String mailStatus = "   Preparing e-mail...";

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
  //¿Habemus cámaras?
  cameras = Capture.list();
}
void setup() {
  frameRate(30);
  // Check to see if there is a webcam
  if (cameras.length != 0) {
    cam = new Capture(this, camW, camH, fps);
   // cam.start();
  }
  iconsList = new ArrayList<Icon>();
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
    text("Cargando...", width/2 - textWidth("Loading...")/2, height/2 - 25);
  } else if (sendingMail) {//sendingMail
    textSize(50);
    fill(255);
    text(mailStatus, (width/2 - textWidth("Enviando mail..."))+50, height/2 - 25);
 //   textSize(20);
 //   text("E-mail enviado.", width/2 - textWidth("Enviando mail..."), height/2 );
    
  } else {
    //  background(0);
    imageMode(CENTER);
    //image(mosaicImg, centerX, centerY, imgW, imgH);
    image(photo, centerX, centerY, imgW, imgH);

    //  noTint();
    //  if (textfieldShow) tint(255, 150);
    if(!isComposited){
      int speed = photo.width / 70;
      for (int i = 0; i< speed; i++) {
        if ( compIndex < iconsList.size() ) {
          //    photo.set( iconsList.get(compIndex).sclX, iconsList.get(compIndex).sclY, iconsList.get(compIndex).icon);
          photo.copy(iconsList.get(compIndex).icon, 0, 0, scl, scl, iconsList.get(compIndex).sclX, iconsList.get(compIndex).sclY, scl, scl );
          compIndex++;
        } else {
          isComposited = true;
          println();
        }
      }
    }

    if (isAnimating) {
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
  if (isAnimating) return;
  if (!isComposited) return;
  println("iconsList.size(): "+iconsList.size()); //<>//
  if (textfieldShow) return; //<>//
  println("click mouseX: "+mouseX);
  println("click mouseY: "+mouseY);
  clickedMouseX = mouseX;
  clickedMouseY = mouseY;
  if (mouseButton == LEFT) {
    // Search in coordinates list until it is found
    long startCliking = System.currentTimeMillis();
    for (int i = 0; i<coordenadasList.size(); i++) {
      Coordenada pos = coordenadasList.get(i);
      if ( (mouseX >= pos.x) && ( mouseX <= pos.x + (scl * pow(1+zoomFactor, scale-1)) )
        && (mouseY >= pos.y) && ( mouseY <= pos.y + (scl * pow(1+zoomFactor, scale-1)) ) ) {
        clickedImg = pos.image; 
        clickedImgW = pos.image.width/scl;
        clickedImgH = pos.image.height/scl;
        clickedImgX = int(pos.x);
        clickedImgY = int(pos.y);
        clickedImgPath = pos.imagePath; 
        isAnimating =true;
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
  if (isAnimating) return;
  if (!isComposited) return;
  lblError.setVisible(false);
  if (key =='z' || key == 'Z') {
    // if we have at least one camera we take a shot for the mosaic
    
    if (cameras.length !=0){
      cam.start();
      loadNewImage();
      cam.stop();
    }
    //loadNewImage();
  } 

  if (key==ESC) {
    key=0;  //Para que no se cierre con Escape
    mailField.setText("");
    mailField.setVisible(false);
    lblMail.setVisible(false);
    lblError.setVisible(false);
  }
  if (key== 7) { //control+g
    if (isAnimating) return;
    if (!isComposited) return;
    mailField.setVisible(true);
    delay(100);
    mailField.setFocus(true);
    lblMail.setVisible(true);
  }

  if (key==ENTER) {
    if (mailField.getText().replaceAll("[\u0000-\u001f]", "").trim() != "") { 
      String email = mailField.getText();
      email= email.replaceAll("[\u0000-\u001f]", ""); //remove control characters

      procesaMail(email);
      println("Mail es: " + email);
    }
  }
}
String saveImage() {
  setTimestamp();
  save("imagenes/pixelate_"+Time+".jpg");
  return  "pixelate_"+Time+".jpg";
}

// Function to create the mosaic 
void run(String path) {
  isComposited = false;
  compIndex = 0;
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
  // ajustamos el tamaño de photo al tamaño final del mosaico para que encaje.
  photo = photo.get(0, 0, (photo.width/scl)*scl, (photo.height/scl)*scl);


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
  ArrayList<Icon> tmpIconsList = new ArrayList <Icon>();


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
        distColor = Math.sqrt( Math.pow(targetR-r, 2) + Math.pow(targetG-g, 2) + Math.pow(targetB-b, 2) );
        if (minDist > distColor ) {
          colorId = listIndex;
          minDist = distColor;
        }
        listIndex++;
      }

      // noStroke();
      //  rect((x*scl)+posX, (y*scl)+posY, scl, scl);
      tmpIconsList.add( new Icon(x*scl, y*scl, imagenesList.get(colorId).smallerImg));

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
  iconsList = tmpIconsList;



  isAnimating = false; // In case the run comes from an animation
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