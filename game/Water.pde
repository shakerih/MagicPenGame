class Water {
   
   int fc = 0;
   PVector lastPosition;
   
   Water() {
     this.lastPosition = new PVector(0, 0);
   }
   public PVector checkForCollisions(PVector toolPosition) {
        PVector speed = PVector.sub(toolPosition, lastPosition);
        PVector force = new PVector(0,0);
        float toolx = abs(toolPosition.x) * 40;
        float tooly = toolPosition.y * 40;
        float density = 500;
        float velocityX = -speed.x;
        float velocityY = -speed.y;
        float drag = 1000;
        force.x = 0.5 * density * velocityX*velocityX * drag;
        force.y = 0.5 * density * velocityY*velocityY * drag;
        return force;
        
    }
    
   void recordLastPosition(PVector currentPosition) {
       if (this.fc % 10 == 0) {
         
         this.lastPosition.set(currentPosition.copy());
         //println("lastPosition:", this.lastPosition);
       }
       fc++;
    }
}
