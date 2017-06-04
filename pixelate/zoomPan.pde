
//ZOOM & PAN functions
//Pan function
void mousePressed() {
  //  if (mouseButton == RIGHT) undoPanZoom();  // For debugging

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
      for (Coordenada pos : coordenadasList) {
        pos.adjustPan();
      }
    }
    int tmpCenterX = centerX;
    int tmpCenterY = centerY;


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
    int offsetX = centerX -tmpCenterX;
    int offsetY = centerY -tmpCenterY;
    for (Coordenada coord : coordenadasList) {
      coord.adjustPan(offsetX, offsetY);
    }

    panFromX = panToX;
    panFromY = panToY;
  }
}

//Zoom function
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  //Zoom in
  if (e == -1) {
    println("IN");
    if (scale < maxScale) { //<>//
      scale++;
      imgW = int(imgW * (1+zoomFactor));
      imgH = int(imgH * (1+zoomFactor));

      centerX = centerX - int(zoomFactor * (mouseX - centerX));
      centerY = centerY - int(zoomFactor * (mouseY - centerY));

      for (Coordenada coord : coordenadasList) {
        coord.adjustZoomIn();
      }
      println();
    }
    println("0 coord.x: "+coordenadasList.get(0).x); //<>//
    println("0 coord.y: "+coordenadasList.get(0).y);
    println("1 coord.x: "+coordenadasList.get(1).x);
    println("1 coord.y: "+coordenadasList.get(1).y);
    println("scale: "+scale); //<>//
  }

  //Zoom out
  if (e == 1) {
    println("OUT");
    if (scale <= 1) {
      scale = 1;
      imgW = photo.width;
      imgH = photo.height;
      println("scale = 1 ");

      centerX = width/2;
      centerY = height/2;

      coordenadasList = coordenadasListCopy;
    }

    if (scale > 1) {
      scale--;
      imgH = ceil(imgH/(1+zoomFactor));
      imgW = ceil(imgW/(1+zoomFactor));
      centerX = centerX + int((mouseX - centerX) * (zoomFactor/(zoomFactor + 1)));
      centerY = centerY + int((mouseY - centerY) * (zoomFactor/(zoomFactor + 1)));


      int tmpCenterX = centerX;
      int tmpCenterY = centerY;

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
      int offsetX = centerX -tmpCenterX;
      int offsetY = centerY -tmpCenterY;
      for (Coordenada coord : coordenadasList) {
        coord.adjustZoomOut(offsetX, offsetY);
      }
    }
    println("coord.x: "+coordenadasList.get(0).x);
    println("coord.y: "+coordenadasList.get(0).y);
    println("scale: "+scale);
  }
}