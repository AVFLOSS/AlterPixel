class Coordenada {
  float x;
  float y;
  PImage image;
  String imagePath; 
  Coordenada(int _x, int _y, PImage _imagen, String _imagenPath) {
    x = float(_x);
    y = float(_y);
    image = _imagen;
    imagePath = _imagenPath;
  }
  void adjustPan() {
    this.x = this.x + xShift;
    this.y = this.y + yShift;
  }
  void adjustPan(int _offsetX, int _offsetY) {
    if (_offsetX != 0) {
      this.x = this.x + _offsetX;
    }
    if (_offsetY != 0) {
      this.y = this.y + _offsetY;
    }
  }
  void adjustZoomIn() {
    this.x = (this.x-mouseX)*(1+zoomFactor) + mouseX;  
    this.y = (this.y-mouseY)*(1+zoomFactor) + mouseY;
  } //<>//
  void adjustZoomOut(int _offsetX, int _offsetY) {
    this.x = this.x + (mouseX - this.x) * (zoomFactor/(zoomFactor + 1));
    this.y = this.y + (mouseY - this.y) * (zoomFactor/(zoomFactor + 1));
    
    //constraints
    if (_offsetX != 0) {
      this.x = this.x + _offsetX;
    }
    if (_offsetY != 0) {
      this.y = this.y + _offsetY;
    }
  }
}