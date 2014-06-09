class Player {
  float centerX, centerY;
  float accelX, accelY;
  float springing = 0.005, damping = 0.85;
  float size;

  Player(float x, float y) {
    centerX = x;
    centerY = y;
    size = 20;
  }
  
  void update() {
    float deltaX = mouseX-centerX;
    float deltaY = mouseY-centerY;
    deltaX *= springing;
    deltaY *= springing;
    accelX += deltaX;
    accelY += deltaY;
    centerX += accelX;
    centerY += accelY;
    checkBounds();
    accelX *= damping;
    accelY *= damping;
    redraw();
  }
  
  void redraw() {
    fill(255);
    ellipse(centerX, centerY, size, size);
  }  
  
  void checkBounds() {
    if (centerX < size / 2)
      centerX = size / 2;
    if (centerX > width - size / 2) 
      centerX = width - size / 2;
    if (centerY < barHeight + size / 2)
      centerY = barHeight + size / 2;
    if (centerY > height - size / 2) 
      centerY = height - size / 2;
  }
}

