// Version 0.5 Beta //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
// Based in Obamathon
// https://github.com/ITPNYU/Obamathon
// YouTube video tutorial: https://youtu.be/nnlAH1zDBDE
import java.util.Collections;
// USER OPTIONS
// User options: framerate
int fps = 60;


// User options - Size of sketch
// The size of sketch
int surfaceW = 1280;
int surfaceH = 720;


// User options: Size of the cells
int scl = 12;

/* ****
 * There are no more user options below, but cheer ...
 * Touch, break, copy, paste, modify :)
 **** */
 PFont f;
String api_key = "cb36e84ad46aa1a458135cb2bc3fc45a";
XML xml;
XML xmlNew;
int timer;
int totalImgs = 500; //max 500
int loadRate = 8000; //5 segundos cambia imagen

// Source main photo
PImage photo;
// Main composed mosaic image
PImage mosaicImg;
// Resize it
PImage smaller;

// List of Imagen objects
ArrayList<Imagen> imagenesList;
// List of icons for the grig
ArrayList<Icon> iconsList;

boolean ready = false;
String titulo;
int indice =0;

String Time; 

//COLOR
int pixelsLength;


PImage clickedImg;
int clickedImgX, clickedImgY;
int clickedImgW, clickedImgH;
String clickedImgPath;
boolean animatingStatus = false;

// La posicion para centrar la imagen
int posX, posY = 0;
// La posicion para la imagen animada 
int aniPosX, aniPosY = 0;

int w, h;

int centerX;
int centerY;

void settings() {
  size(surfaceW, surfaceH);
}
void setup() {
  f = createFont("NotoSansCJKjp-Black",48);
  textFont(f);
  textAlign(CENTER);
  iconsList = new ArrayList<Icon>();
  frameRate(fps);
  centerX = surfaceW / 2;
  centerY = surfaceH / 2;
  processAllImages();
  run(imagenesList.get(0).filename.replace("_s.jpg", "_h.jpg"));
  timer = millis();
} // ENDS setup()

void draw() {
  background(0);
  imageMode(CENTER);
  image(photo, centerX, centerY, photo.width, photo.height);

  if (indice < iconsList.size() || indice == iconsList.size() ) {
    int speed = iconsList.size() / 150;
    for (int i = 0; i< speed; i++) {
      if ( indice < iconsList.size() ) {
        photo.set( iconsList.get(indice).sclX, iconsList.get(indice).sclY, iconsList.get(indice).icon); 
        indice++;
   //     println("Indice: "+indice+ " iconId.size(): " + iconsList.size() );
      } else {
   //     println("indice es: "+indice);
        //   iconsList.clear();
        ready = true;
        //   indice = 0;
      }
    }
    indice++;
  //  println("Indice: "+indice+ " iconId.size(): " + iconsList.size() );
    
  }
  image(photo, centerX, centerY, photo.width, photo.height);

  if (animatingStatus) {
    //  aniPositionImg(clickedImg); // We get the final x and y positions for the animation
    //  imageMode(CORNER);
    //TODO
    //int targetWidth = photo.width;
    //int targetHeight = photo.height;
    //image(photo, centerX, centerY, photo.width/10, photo.height/10);// old ok
    //  imageMode(CENTER);

    //  // We animate the image to its final position
    //  if (clickedImgX > aniPosX)  clickedImgX -= Math.sqrt(clickedImgX-aniPosX) ;
    //  if (clickedImgY > aniPosY) clickedImgY -= Math.sqrt(clickedImgY-aniPosY) ;

    // // We animate the image to its real size
    // if (clickedImg.width > clickedImgW)  clickedImgW += Math.sqrt(clickedImg.width - clickedImgW);
    // if (clickedImg.height > clickedImgH)  clickedImgH += Math.sqrt(clickedImg.height - clickedImgH);

    //  // if image is positioned and fully resized
    //  if (clickedImgX == aniPosX && clickedImgY ==aniPosY && clickedImgW == clickedImg.width
    //    && clickedImgH == clickedImg.height) {
    //    println("Animation finished");
    //    run(clickedImgPath);
    //  }
  }

  if (ready) {
    background(0);
    image(mosaicImg, centerX, centerY, photo.width, photo.height);
    //New image after some seconds (milliseconds)
    if (millis() - timer >= loadRate) {
      loadNewImage();
      ready = false;
      timer = millis();
    }
  }
   

  text(titulo, width/2,height/2);//,width/10,height/10);
  fill(256,0,0);
//  println("frameRate: " + frameRate);
//  println("frameCount: " +frameCount);
//  saveFrame("pngs-2/alterpixel_02-v1-#####.png");
}  // END draw()






// Function to create the mosaic 
void run(String path) {
  photo = loadImage(path);
  // If there are larger images, we reduce them
  //TODO: queremos recortarlas para ajustarlas? ahora si recorta un poco
  if ( photo.width > width || photo.height > height ) {
    if ( photo.width > width ) {
      photo.resize(width, 0);  // it is portrait (vertical)
    } else {
      photo.resize(0, height); // it is landscape or equal proportion
    }
  }
  if (photo.height > height) photo.resize(0,height);



  positionImg(photo); // We get the positions `x` `y` to place the photo with margins

  // Creating the imagen for the mosaic
    mosaicImg = createImage(photo.width, photo.height, RGB);
  //mosaicImg = photo;
  iconsList.clear();

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

      //  rect((x*scl)+posX, (y*scl)+posY, scl, scl);
      iconsList.add( new Icon(x*scl, y*scl, imagenesList.get(colorId).smallerImg));


      // Creating the mosaic    
      mosaicImg.set( x*scl, y*scl, imagenesList.get(colorId).smallerImg);

      //  delay(1);
      //try {
      //  Thread.sleep(4);
      //}
      //catch(InterruptedException e) {
      //  System.out.println("got interrupted!");
      //}
    }
    //Collections.shuffle(iconsList);
  }
  long endCompositing = System.currentTimeMillis();
  println("DRAW: Compositing, Fill cols and rows: "+(endCompositing-startCompositing));

  animatingStatus = false; // In case the run comes from an animation
} // ENDS run()


//¿Obsoleto?
// Function to get the position x and y to center the image with respect to the size of the sketch
void positionImg(PImage photoTmp) {
  posX = (width-photoTmp.width)/2;
  posY = (height-photoTmp.height)/2;
}
//¿Obsoleto?
// Function to get the position x and y to center the image during the animation 
void aniPositionImg(PImage photoTmp) {
  aniPosX = (width-photoTmp.width)/2;
  aniPosY = (height-photoTmp.height)/2;
}

//Function lo load a new image to the first of the list and remove the last one 
void loadNewImage() {
  indice = 0;
  int photoId =0;;
  //we get the xml query 
 xmlNew = loadXML("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key="+api_key+"&license=1%2C2%2C4%2C5%2C7%2C9%2C10&content_type=1&extras=license&per_page=1&format=rest");
//   xmlNew = loadXML("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key="+api_key+"&license=1%2C2%2C4%2C5%2C7%2C9%2C10&content_type=1&extras=license&text=china&per_page=1&format=rest");
  //create a XML array with the results
  XML[] photoNew = xmlNew.getChildren("photos/photo");
  //and fill it with images 
  for (int i = 0; i < photoNew.length; i++) {
    String farm = photoNew[i].getString("farm");
    String server = photoNew[i].getString("server");
    String id = photoNew[i].getString("id");
    String secret = photoNew[i].getString("secret"); 
    titulo = photoNew[i].getString("title");
   photoId = int(photoNew[i].getString("id"));

    String imgPath = "http://farm"+farm+".static.flickr.com/"+server+"/"+id+"_"+secret+"_s.jpg";

    imagenesList.add(0, new Imagen( imgPath ));
    imagenesList.remove(imagenesList.size()-1);
    //TODO: ¿Como queremos la animación de las nuevas?
    //    animatingStatus = true;
    println("Añadiendo 1 nueva: " +imgPath);
    run(imagenesList.get(imagenesList.size()-1).filename.replace("_s.jpg", "_h.jpg"));
    println("Añadida: " +imgPath);
    println("Título: "+titulo);
    println();
  }
  //find if any tags
  
  XML photoTags = loadXML("https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key="+api_key+"photo_id="+photoId+"&format=rest");
  XML[] tags = photoTags.getChildren("photo/tags");
  for (int i = 0; i < tags.length; i++){
    String tag = tags[i].getString("tag");
    println("Tags: "+tag);
    println(); //<>//
    
  }
  
}


//  Function to process images, list of images, etc
// It is executed only once the sketch has started
void processAllImages() {
  // Find all the images

  long startTimeImagenArrayList = System.currentTimeMillis();
  //we get the xml query 
  xml = loadXML("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key="+api_key+"&license=1%2C2%2C4%2C5%2C7%2C9%2C10&content_type=1&extras=license&per_page="+totalImgs+"&format=rest");
  //create a XML array with the results
  XML[] photoTag = xml.getChildren("photos/photo");

  // We create an empty ArrayList 
  imagenesList = new ArrayList<Imagen>();
  imagenesList.ensureCapacity(totalImgs);
  //and fill it with images 
  for (int i = 0; i < photoTag.length; i++) {
    String farm = photoTag[i].getString("farm");
    String server = photoTag[i].getString("server");
    String id = photoTag[i].getString("id");
    String secret = photoTag[i].getString("secret"); 
    titulo = photoTag[i].getString("title"); 

    String imgPath = "http://farm"+farm+".static.flickr.com/"+server+"/"+id+"_"+secret+"_s.jpg"; //https://www.flickr.com/services/api/misc.urls.html

    imagenesList.add(new Imagen( imgPath ));
    println("Cargando imagen "+ i + " : " +imgPath);
  }
  long endTimeImagenArrayList = System.currentTimeMillis();
  println("Carga de "+totalImgs+" : "+ (endTimeImagenArrayList-startTimeImagenArrayList)+" miliseconds");
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
