public class HeightMap{

    //declare 6 ramps
    private Ramp ramp1_up;
    private Ramp ramp2_down;
    private Ramp ramp3_up;
    private Ramp ramp4_down;
    private Ramp ramp5_up;
    private Ramp ramp6_down;

    private int pixlesPerCentimeter = 40;



    /* 
    constructor, given an x,y in pixles it will draw 6 ramps from that point as the top left 
    it will also expect width and height of each ramp
    */
    HeightMap( float x, float y, float width, float height){
        
        //initialize 6 ramps with alternating inclines, starting with an 'up' incline
        this.ramp1_up = new Ramp(x, y, width, height, true);
        this.ramp2_down = new Ramp(x+width, y, width, height, false);
        this.ramp3_up = new Ramp(x+width*2, y, width, height, true);
        this.ramp4_down = new Ramp(x+width*3, y, width, height, false);
        this.ramp5_up = new Ramp(x+width*4, y, width, height, true);
        this.ramp6_down = new Ramp(x+width*5, y, width, height, false);


    }

    /*
    display the ramps
    */
    public void showRamps(){
        this.ramp1_up.display();
        this.ramp2_down.display();
        this.ramp3_up.display();
        this.ramp4_down.display();
        this.ramp5_up.display();
        this.ramp6_down.display();
    }


    public PVector checkForCollisions(int pn){
       PVector force = new PVector(0,0);
       force.x = 100*pn;
       force.y = 100*pn;

       return force;

   }

    public int checkForRampContact(PVector toolPosition){
        
        float toolx = abs(toolPosition.x * this.pixlesPerCentimeter);
        float tooly = toolPosition.y * pixelsPerCentimeter;
        
        if (toolx > this.ramp1_up.getX() && toolx < this.ramp1_up.getX() + this.ramp1_up.getWidth() && tooly > this.ramp1_up.getY() && tooly < this.ramp1_up.getY() + this.ramp1_up.getHeight() ){
            
            return 1;
        }
        else if (toolx > this.ramp2_down.getX() && toolx < this.ramp2_down.getX() + this.ramp2_down.getWidth() && tooly > this.ramp2_down.getY() && tooly < this.ramp2_down.getY() + this.ramp2_down.getHeight() ){
            
            return 2;
        }
        else if (toolx > this.ramp3_up.getX() && toolx < this.ramp3_up.getX() + this.ramp3_up.getWidth() && tooly > this.ramp3_up.getY() && tooly < this.ramp3_up.getY() + this.ramp3_up.getHeight()){
            
            return 1;
        }
        else if (toolx > this.ramp4_down.getX() && toolx < this.ramp4_down.getX() + this.ramp4_down.getWidth() && tooly > this.ramp4_down.getY() && tooly < this.ramp4_down.getY() + this.ramp4_down.getHeight()){
            
            return 2;
        }
        else if (toolx > this.ramp5_up.getX() && toolx < this.ramp5_up.getX() + this.ramp5_up.getWidth() && tooly > this.ramp5_up.getY() && tooly < this.ramp5_up.getY() + this.ramp5_up.getHeight()){
            
            return 1;
        }
        else if (toolx > this.ramp6_down.getX() && toolx < this.ramp6_down.getX() + this.ramp6_down.getWidth() && tooly > this.ramp6_down.getY() && tooly < this.ramp6_down.getY() + this.ramp5_up.getHeight()){
            return 2;
        }
        else{
            return 0;
        }


    }

    public PVector applyDamping(PVector toolPosition, PVector speed){
        PVector force = new PVector(0,0);
        float toolx = abs(toolPosition.x * this.pixlesPerCentimeter);
        float tooly = toolPosition.y * pixelsPerCentimeter;
        float density = 500;
        float drag = 1000;
        float x_direction = 1;
        float y_direction = 1;

        if(speed.x < 0){
            x_direction = 1;
        } else{
            x_direction = -1;
        }

        if(speed.y < 0 ){
            y_direction = -1;
        }else {
            y_direction = 1;
        }

        force.x = 0.5 * density * x_direction * drag;
        force.y = 0;
        
        return force;

    }



}
