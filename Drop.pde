class Drop {
  
  float x, y, w;
  float dotDelta;
  
  Drop(float tempX, float tempY, float tempW) {
    x = tempX;
    y = tempY;
    w = tempW;
    dotDelta = 1;
  }
  
  void grow() {
  w = w + dotDelta;
    if(w>50){
      w = 0;
    }
        
  }

  boolean finished() {
    // Drops disapear
  
    if (w == 0) {
      return true;
    } else {
      return false;
    }
  }
  
  void display() {
    fill(0);
    ellipse(x,y,w,w);

  //tint(valueHue,100,valueBright);
  //image(dot, 250-dotSize/2, 250-dotSize/2, dotSize, dotSize);
  }
}  