public class GridEllipse{

    //properties
    private float x;
    private float y;
    private float radius;

    //constructor with setter
    GridEllipse(float x, float y, float radius){
        this.x = x;
        this.y = y;
        this.radius = radius;
    }

    public void display(boolean isHit){
        if(isHit){
            
            fill(255,200,200, 90);
             //default ellispeMode is center (ie. draws ellipse from center of point)
            ellipse(this.x, this.y, this.radius*2, this.radius*2);
        } else{
            
            noFill();
            ellipse(this.x, this.y, this.radius*2, this.radius*2);
        }
       
    }

    //getters
    public float getX(){
        return this.x;
    }
    public float getY(){
        return this.y;
    }
    public float getRadius(){
        return this.radius;
    }
}
