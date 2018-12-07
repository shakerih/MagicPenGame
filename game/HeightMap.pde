public class HeightMap{


    private int pixlesPerCentimeter = 40;

    private float wavelength;
    private float amp;


    /* 
    constructor, given an x,y in pixles it will draw 6 ramps from that point as the top left 
    it will also expect width and height of each ramp
    */
    HeightMap( float x, float y, float width, float height){
        
      
        //initialize wavelength
        this.wavelength = 1000/10;
        this.amp = 200;

    }


    public PVector checkForCollisions(PVector toolPosition, PVector speed){
        PVector force = new PVector(0,0);
        float toolx = abs(toolPosition.x * this.pixlesPerCentimeter);
        float tooly = toolPosition.y * pixelsPerCentimeter;
        float density = 500;
        float velocityX = -speed.x;
        float velocityY = -speed.y;
        float drag = 200;
        int signx = -(int)(speed.x/abs(speed.x));        
        int signy = -(int)(speed.y/abs(speed.y));
        force.x = 0.5 * density * velocityX*velocityX * drag * signx;
        force.y = 0.5 * density * velocityY*velocityY * drag * signy;

        return force;

    }
    
    public PVector checkForCollisionsDry(PVector toolPosition, PVector speed){
       PVector force = new PVector(0,0);
       float friction = 1;
       float normal = 7;
        int signx = -(int)(speed.x/abs(speed.x));        
        int signy = -(int)(speed.y/abs(speed.y));
       force.x = friction*normal*signx;
       force.y = friction*normal*signy;

       return force;

   }

}
