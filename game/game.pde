
  
 /* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
/* end library imports *************************************************************************************************/  



/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 



/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 3;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           rendering_force                     = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerCentimeter                 = 40.0;

/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           pos_ee                              = new PVector(0, 0);
PVector           f_ee                                = new PVector(0, 0); 

/* World boundaries */
FWorld            world, world2;
float             worldWidth                          = 25.0;  
float             worldHeight                         = 20.0; 

float             edgeTopLeftX                        = 0.0; 
float             edgeTopLeftY                        = 0.0; 
float             edgeBottomRightX                    = worldWidth; 
float             edgeBottomRightY                    = worldHeight;

HVirtualCoupling s;
Figure fig1, fig2, fig3;
Opponent npc;
Player player;
FBox shudder;
FigureManager fManager;

//pat--> create new spell recognitction object
SpellRecognition mySpellRec = new SpellRecognition(worldWidth, worldHeight, pixelsPerCentimeter);
boolean inSpellCastingMode = false;

/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 800);
    //fig1 = new Figure("gargoyle.png", 50, 50, 44, 65);
    //fig2 = new Figure("gargoyle.png", 350, 130, 44, 65);
    //fig3 = new Figure("gargoyle.png", 250, 400, 44, 65);
    
    npc = new Opponent("images/npc.png", 100, 100);
    player = new Player("images/player.png", 300, 600);
    
    shudder = new FBox(10,10);
    shudder.setStatic(true);
    shudder.setDensity(8000);
    shudder.setFriction(8000);
    shudder.setDrawable(false);
/* device setup */
  
  /**  
   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
   * to explicitly state the serial port will look like the following for different OS:
   *
   *      windows:      haplyBoard = new Board(this, "COM10", 0);
   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
   */
  haplyBoard          = new Board(this, "COM5", 0);
  widgetOne           = new Device(widgetOneID, haplyBoard);
  widgetOne.add_analog_sensor("A0");
  widgetOne.add_analog_sensor("A1");
  widgetOne.add_analog_sensor("A2");
  widgetOne.add_analog_sensor("A3");
  pantograph          = new Pantograph();
  
  widgetOne.set_mechanism(pantograph);
  
  widgetOne.add_actuator(1, CW, 1);
  widgetOne.add_actuator(2, CW, 2);
 
  widgetOne.add_encoder(1, CW, 180, 13824, 1);
  widgetOne.add_encoder(2, CW, 0, 13824, 2);
  
  widgetOne.device_set_parameters();
  
  
  /* 2D physics scaling and world creation */
  hAPI_Fisica.init(this); 
  hAPI_Fisica.setScale(pixelsPerCentimeter); 
  world               = new FWorld();
  
  
  /*
   * Insert physics objects here
   */
  
  
  /* Setup the Virtual Coupling Contact Rendering Technique */
  s = new HVirtualCoupling((1)); 
 
 //                            float   free_mass,
 //                           float   stiffness,
 //                           float   damping,
 //                           float   contact_mass ) 
 //s.setVirtualCouplingStiffness(36250);

  s.h_avatar.setDensity(2); 
  s.updateCouplingForce  (0.25F, 250000.0F,700.0F,1.0010F); 
  s.h_avatar.setFill(255,0,0,0); 
  s.h_avatar.setStroke(0,0,0,0);
  s.init(world, edgeBottomRightX - 2, edgeBottomRightY - 2);
  
  /* World conditions setup */
  world.setGravity((0.0), (300.0)); //1000 cm/(s^2)
  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
  world.setEdgesRestitution(0.0);
  world.setEdgesFriction(0.0);
  world.add(shudder);
  shudder.setPosition(0,0);
  world.draw();
  
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  fManager = new FigureManager(world);
  fManager.init();
  
  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
}




void draw(){

  // draw this during normal gameplay
  background(140, 140, 120);
  textSize(38);
  textAlign(CENTER);
  text("Magic Paradise", width/2, 60);
  textSize(20);
  text("Move magic Pen to sense the magical object and press 's' to go to spell mode to cast a spell.", 500, height-40);
  world.draw();
  fManager.switchSpells();
  npc.render();
  player.render(s.getAvatarPositionX()*pixelsPerCentimeter, s.getAvatarPositionY()*pixelsPerCentimeter);
  

  if(inSpellCastingMode){
    //spell recognition code
    fill(0,0,0,50);
    rect(0,0,1000,800);  
    mySpellRec.showGrid();// show the  9 x 9 casting grid
    mySpellRec.checkForCollisions(s.getAvatarPositionX()*pixelsPerCentimeter, s.getAvatarPositionY()*pixelsPerCentimeter, pixelsPerCentimeter/2);//call this to check if theyve hit differnt parts of the 9x9 grid
    String mystring = mySpellRec.checkIfSpellCast();//check if a spell has successfully been cast (they hit the corrext cicles on the grid)
    if(mystring != "none"){
      player.spellmode = false;
        println(mystring);
        //should move the avatar to the bottom left starting point
        mySpellRec.Reset();  
        this.inSpellCastingMode = false;
    s.h_avatar.setFill(255,0,0,0);
      for(int i = 0; i < fManager.collection.length; i++){
       world.add(fManager.collection[i]);
      }
      world.draw();
    }
  }
}

/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    rendering_force = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      angles.set(widgetOne.get_device_angles()); 
    
      pos_ee.set(widgetOne.get_device_position(angles.array()));
      pos_ee.set(pos_ee.copy().mult(10));  
      //println(pos_ee);
    }
    
    s.setToolPosition(-pos_ee.x, pos_ee.y); 
    s.updateCouplingForce();
    f_ee.set(-s.getVCforceX(), s.getVCforceY());
   // f_ee.div(20000); //
    
    torques.set(widgetOne.set_device_torques(f_ee.array()));
    //println(torques);
    widgetOne.device_write_torques();
  
    world.step(1.0f/1000.0f);
  
    rendering_force = false;
    //println(widgetOne.get_sensor_data()[3]);
  }
}
/* end simulation section **********************************************************************************************/
void keyPressed() {

  if(keyCode == 32){//if spacebar pressed then shudder
    println("pressed spacebar");
    float originalPos = s.getAvatarPositionY()-2;
    shudder.setPosition(s.getAvatarPositionX(), s.getAvatarPositionY()-1);
    shudder.setStatic(false);

    if(s.getAvatarPositionY() - originalPos > 3){
      shudder.setPosition(0,0);
      shudder.setStatic(true);
    }
  }else if (key == 's'){//enter spell casting mode
   ArrayList<FBody> b = world.getBodies();
      for(int i = 0; i < b.size(); i++)
       world.remove(b.get(i));
      println(fManager.collection.length);
 //  world = new FWorld();
  s.init(world, edgeBottomRightX - 2, edgeBottomRightY - 2);
  
    println("pressed s");
    if(this.inSpellCastingMode){
      this.inSpellCastingMode = false;
      player.spellmode = false;
    s.h_avatar.setFill(255,0,0,0);
      for(int i = 0; i < fManager.collection.length; i++){
       world.add(fManager.collection[i]);
      }
      world.draw();
       println(b);
    }
    else{
      s.setToolPosition(2, 24);
      s.setAvatarPosition(2, 24);
      this.inSpellCastingMode = true;
      player.spellmode = true;
    s.h_avatar.setFill(255,0,0,255);
     
    }
  }

}

void draw_instructions() {
 
}
