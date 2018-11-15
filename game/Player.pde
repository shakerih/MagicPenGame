class Player extends Wizard{
  float cx, cy;
  boolean freeze;
  int freezecounter;
Player(String img, int x, int y){
  super(img, x, y);

 }
 
 void render(float x, float y){
   if(keyPressed){ // when feeling feedback, the player's position will appear static
      freeze = true;
      freezecounter = 80;
   }else{
     freeze=false;
     if(freezecounter>0){
       freezecounter--;
     }
   }
   if(!freeze && freezecounter <= 0){ 
     cx = x;
     cy = y;
    image(img, x-30,y-50); 
   }else{
     image(img, cx-30,cy-50); 
   }
 }
 

}
