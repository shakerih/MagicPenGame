class Wizard {
  PImage img;
  int x,y;
 Wizard(String img, int x, int y){
   this.img = loadImage(img);
   this.img.resize(61,100);
   this.x=x;
   this.y=y;
 }
 
 void render(){
  image(img, x,y); 
 }
}
