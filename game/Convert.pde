public static class Convert {
   
  float toPixel(float cm) {
    return cm * 40;
  }
  
  float toCm(int pixels) {
    return (float) pixels/40;
  }
}
