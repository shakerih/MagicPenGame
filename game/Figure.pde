class Figure{
  PImage img;
  int x,y;
 Figure(String img, int x, int y, int w, int h){
   this.img = loadImage(img);
   this.img.resize(w,h);
   this.x=x;
   this.y=y;
 }
 
 void render(){
  image(img, x,y); 
 }
}
