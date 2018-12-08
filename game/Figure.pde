class Figure extends FCircle {
  
 String figureName;  // name of the figure
 boolean spelled = false; // whether the figure is spelled
 PImage img; // image of the figure to show in the game
 int FIG_WIDTH = 10;   // width of figure in cm
 int FIG_HEIGHT = 15;  // heigt of figure in cm
 int RADIUS = 30;
 int q = 120;
 int colour;
 
 Figure(String name, String img, float x, float y, boolean spelled){
   super(3);
   this.figureName = name;
   this.img = loadImage(img);
   this.img.resize(44, 44);
   this.attachImage(this.img);
   this.setStroke(5);
   this.setFill(255);
   this.spelled = spelled;
   this.setStatic(true);
   this.setFill(130,130,130);
   this.setPosition(x, y);
   
   if(spelled == true) {
    //positive:
    colour = #FF0000;
    q = 120;
    } else if(spelled == false) {
    colour = #FFFFFF;
    q = 0;}else{
    //negative:
    colour = #0070FF;
    q = -120;
    }
   
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
  
  void displayMagic() {
    PImage img2 = loadImage("images/npc.png");
    img2.resize(70, 70);
    this.attachImage(img2);
  }
  
  void undoMagic() {
    this.attachImage(this.img);
  }

}
