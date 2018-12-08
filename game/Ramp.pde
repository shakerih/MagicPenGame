public class Ramp{

    //properties
    private float x;
    private float y;
    private float width;
    private float height;
    private boolean incline;//true is up, false is down, ie. a decline, downward ramp

    //constructor with setter
    Ramp(float x, float y, float width, float height, boolean incline){
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.incline = incline;
    }

    public void display(){
        if(incline){//if incline = true, then lets mae a red rect indicating an upward ramp
            fill(255,0,0,90);
            rect(this.x, this.y, this.width, this.height);
        } else{//if incline = false, then lets mae a blue rect indicating an downward ramp
            fill(0,0,255,90);
            rect(this.x, this.y, this.width, this.height);
        }
       
    }

    //getters
    public float getX(){
        return this.x;
    }
    public float getY(){
        return this.y;
    }
    public float getWidth(){
        return this.width;
    }
    public float getHeight(){
        return this.height;
    }
    public boolean getIncline(){
        return this.incline;
    }
}