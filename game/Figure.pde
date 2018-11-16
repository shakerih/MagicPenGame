class Figure extends FBox {
  
 PImage img;
 int FIG_WIDTH = 10;   // in cm
 int FIG_HEIGHT = 15;  // in cm
 boolean spelled = false;
  
 Figure(String img, float x, float y, boolean spelled){
   super(3, 2);
   this.img = loadImage(img);
   this.img.resize(44, 44);
   this.attachImage(this.img);
   this.setStroke(5);
   this.setFill(0);
   this.spelled = spelled;
   println(spelled);
   this.setStatic(true);
   this.setFill(130,130,130);
   this.setPosition(x, y);
   this.setForce(2,2);
   
 }
 
 boolean isSpelled() {
   return spelled;
 }
 
 void setSpelled(boolean value) {
   this.spelled = value;
 }
}
