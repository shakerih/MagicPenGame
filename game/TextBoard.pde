class Textboard{
  PImage img;
  String text;
 Textboard(String text){
   img = loadImage("board.png");
   this.text = text;
 }
 
 void render(){
 fill(255);
  image(img, 20,20); 
  textSize(50);
  text(text, 300, 300); 
 }
}
