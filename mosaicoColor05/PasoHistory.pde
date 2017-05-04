class PasoHistory {
  String tipo;
  int prevCenterX;
  int prevCenterY;
  PasoHistory(String _tipo, int _prevCenterX, int _prevCenterY) {
    tipo = _tipo;
    prevCenterX = _prevCenterX;
    prevCenterY = _prevCenterY;
  }
  void undoPaso() {
    if (tipo=="pan") {
      int offsetX = prevCenterX - centerX;
      int offsetY = prevCenterY - centerY;
      centerX = centerX + offsetX;
      centerY = centerY + offsetY;
      clickedMouseX = clickedMouseX+offsetX;
      clickedMouseY = clickedMouseY+offsetY;
    }
    if (tipo=="zoom-") {
      imgH = round(imgH / (1+zoomFactor));
      imgW = round(imgW / (1+zoomFactor));
      clickedMouseX = round(clickedMouseX / (1+zoomFactor));
      clickedMouseY = round(clickedMouseY / (1+zoomFactor));
    }
    if (tipo=="zoom+") {
      imgH = round(imgH * (1+zoomFactor));
      imgW = round(imgW * (1+zoomFactor));
      clickedMouseX = round(clickedMouseX * (1+zoomFactor));
      clickedMouseY = round(clickedMouseY * (1+zoomFactor));
    }
  }
  
 
}