public class SpellRecognition{

    //these will come from main class and be in centimeters
    private float gameBoardWidthPixles;
    private float gameBoardHeightPixles;

    //spacing for our grid ellipse objects
    private float verticalSpacing;
    private float horizontalSpacing;

    //radius for grid ellipse objects
    private float radius = 50;

    //declare the 9 ellipses that make up the grid
    private GridEllipse ellipse1;
    private GridEllipse ellipse2;
    private GridEllipse ellipse3;
    private GridEllipse ellipse4;
    private GridEllipse ellipse5;
    private GridEllipse ellipse6;
    private GridEllipse ellipse7;
    private GridEllipse ellipse8;
    private GridEllipse ellipse9;

    //track when grid ellipses are hit
    private boolean e1Hit = false;
    private boolean e2Hit = false;
    private boolean e3Hit = false;
    private boolean e4Hit = false;
    private boolean e5Hit = false;
    private boolean e6Hit = false;
    private boolean e7Hit = false;
    private boolean e8Hit = false;
    private boolean e9Hit = false;

    //failed counter, more than 3 means you failed a spell sequnce
    private int failedSpellCounter = 0;

    //constructor
    SpellRecognition(float gameBoardWidthCentimeters, float gameBoardHeightCentimeters, float pixelsPerCentimeter){
        //set the gameboad with and height to draw everytthing within
        this.gameBoardWidthPixles = gameBoardWidthCentimeters * pixelsPerCentimeter;
        this.gameBoardHeightPixles = gameBoardHeightCentimeters * pixelsPerCentimeter;

        this.horizontalSpacing = this.gameBoardWidthPixles / 4.0;
        this.verticalSpacing =  this.gameBoardHeightPixles / 4.0;


        //initialize 9 grid ellipse objects to represent the grid 
        this.ellipse1 = new GridEllipse(this.horizontalSpacing, this.verticalSpacing * 3, this.radius);
        this.ellipse2 = new GridEllipse(this.horizontalSpacing * 2, this.verticalSpacing * 3, this.radius);
        this.ellipse3 = new GridEllipse(this.horizontalSpacing * 3, this.verticalSpacing * 3, this.radius);
        this.ellipse4 = new GridEllipse(this.horizontalSpacing, this.verticalSpacing * 2, this.radius);
        this.ellipse5 = new GridEllipse(this.horizontalSpacing * 2, this.verticalSpacing * 2, this.radius);
        this.ellipse6 = new GridEllipse(this.horizontalSpacing * 3, this.verticalSpacing * 2, this.radius);
        this.ellipse7 = new GridEllipse(this.horizontalSpacing, this.verticalSpacing, this.radius);
        this.ellipse8 = new GridEllipse(this.horizontalSpacing * 2, this.verticalSpacing, this.radius);
        this.ellipse9 = new GridEllipse(this.horizontalSpacing * 3, this.verticalSpacing, this.radius);
    }

    //display the 9 x 9 grid 
    public void showGrid(){
        this.ellipse1.display(e1Hit);
        this.ellipse2.display(e2Hit);
        this.ellipse3.display(e3Hit);
        this.ellipse4.display(e4Hit);
        this.ellipse5.display(e5Hit);
        this.ellipse6.display(e6Hit);
        this.ellipse7.display(e7Hit);
        this.ellipse8.display(e8Hit);
        this.ellipse9.display(e9Hit);
        
    }

    // check each spell that can be cast, return a string of the type if it's cast
    public String checkIfSpellCast(){
        
        if (this.failedSpellCounter > 3){
            this.Reset();
            return "failed";
        }
        if(this.checkRevelio()){
            this.Reset();//since we've successfully cast a spell, reset spell gesture tracking
            return "revelio";//report that we've cast this spell
        }
        if(this.checkAttack()){
            this.Reset();//since we've successfully cast a spell, reset spell gesture tracking
            return "attack";//report that we've cast this spell
        }
        if(this.checkDefense()){
            this.Reset();//since we've successfully cast a spell, reset spell gesture tracking
            return "defense";//report that we've cast this spell
        }
        return "none";

    }

    
    //check for revelio spell
    public boolean checkRevelio(){
        //need to check proper sequence of collisions
        if(e1Hit){//chcek if e1 hit, can proceed to next check

            if(e4Hit){//check if e4 hit

                if(e7Hit){//check if e7 hit
                    return true; // we've hit all 3 in order to cast revelio
                }
            }
        }
        return false;
    }

    //check for attack spell
    public boolean checkAttack(){
        //need to check proper sequence of collisions
        if(e1Hit){//chcek if e1 hit, can proceed to next check

            if(e5Hit){//check if e5 hit

                if(e9Hit){//check if e9 hit
                    return true; // we've hit all 3 in order to cast attack spell
                }
            }
        }
        return false;
    }

    //check for defense spell
    public boolean checkDefense(){
        //need to check proper sequence of collisions
        if(e1Hit){//chcek if e1 hit, can proceed to next check

            if(e2Hit){//check if e2 hit

                if(e3Hit){//check if e3 hit
                    return true; // we've hit all 3 in order to cast defense spell
                }
            }
        }
        return false;
    }

    //check collision
    // takes the avatars coordinates and radius and sets any of the collisions to true for the ellipse grid objets if it's hit them
    public void checkForCollisions( float avatarX, float avatarY, float avatarRadius){

        if(!this.e1Hit){
            if(dist(avatarX, avatarY, this.ellipse1.getX(), this.ellipse1.getY()) < this.ellipse1.getRadius() + avatarRadius){
            this.e1Hit = true;
            this.failedSpellCounter++;  
            }
        }
        if(!this.e2Hit){
            if(dist(avatarX, avatarY, this.ellipse2.getX(), this.ellipse2.getY()) < this.ellipse2.getRadius() + avatarRadius){
                this.e2Hit = true;
                this.failedSpellCounter++;
            }
        }
        if(!this.e3Hit){
            if(dist(avatarX, avatarY, this.ellipse3.getX(), this.ellipse3.getY()) < this.ellipse3.getRadius() + avatarRadius){
                this.e3Hit = true;
                this.failedSpellCounter++;   
            }
        }
        if(!this.e4Hit){
            if(dist(avatarX, avatarY, this.ellipse4.getX(), this.ellipse4.getY()) < this.ellipse4.getRadius() + avatarRadius){
                this.e4Hit = true;
                this.failedSpellCounter++;    
            }
        }
        if(!this.e5Hit){
            if(dist(avatarX, avatarY, this.ellipse5.getX(), this.ellipse5.getY()) < this.ellipse5.getRadius() + avatarRadius){
                this.e5Hit = true;
                this.failedSpellCounter++;    
            }
        }
        if(!this.e6Hit){
            if(dist(avatarX, avatarY, this.ellipse6.getX(), this.ellipse6.getY()) < this.ellipse6.getRadius() + avatarRadius){
                this.e6Hit = true; 
                this.failedSpellCounter++;  
            }
        }
        if(!this.e7Hit){
            if(dist(avatarX, avatarY, this.ellipse7.getX(), this.ellipse7.getY()) < this.ellipse7.getRadius() + avatarRadius){
                this.e7Hit = true;
                this.failedSpellCounter++;   
            }
        }
        if(!this.e8Hit){
            if(dist(avatarX, avatarY, this.ellipse8.getX(), this.ellipse8.getY()) < this.ellipse8.getRadius() + avatarRadius){
                this.e8Hit = true;
                this.failedSpellCounter++;    
            }
        }
        if(!this.e9Hit){
            if(dist(avatarX, avatarY, this.ellipse9.getX(), this.ellipse9.getY()) < this.ellipse9.getRadius() + avatarRadius){
                this.e9Hit = true; 
                this.failedSpellCounter++;   
            }
        }
        
    }
    //if we successfully cast a spell reset our tracking variables
    public void Reset(){
        this.e1Hit = false;
        this.e2Hit = false;
        this.e3Hit = false;
        this.e4Hit = false;
        this.e5Hit = false;
        this.e6Hit = false;
        this.e7Hit = false;
        this.e8Hit = false;
        this.e9Hit = false;
        this.failedSpellCounter = 0;
    }

}