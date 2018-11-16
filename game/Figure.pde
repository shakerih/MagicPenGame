class Figure extends FBox {
  
 PImage img;
 int FIG_WIDTH = 10;   // in cm
 int FIG_HEIGHT = 15;  // in cm
 boolean spelled = false;
 String figureName;
 
 Figure(String name, String img, float x, float y, boolean spelled){
   super(3, 2);
   this.figureName = name;
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
 
 void removeSpell() {
   this.spelled = false;
   text("Spell on figure " + figureName + " removed!", 500, height-60);
 }


  void revealActualFigure() {
    if (this.spelled) {
      text("No spell was casted on " + figureName, 500, height - 60);
    } else {
      this.spelled = false;
      text("Actual figure revealed. It is a " + figureName + " object.", 500, height - 60);
    }
  }


}
