
  
 /* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
import ddf.minim.*;
/* end library imports *************************************************************************************************/  



/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 


Minim minim;
AudioPlayer waterAudio, rockAudio;


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
FWorld            world;
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
Figure fPlayer;
float K = 8.99; 

FigureManager fManager;
//pat--> create new spell recognitction object
SpellRecognition mySpellRec = new SpellRecognition(worldWidth, worldHeight, pixelsPerCentimeter);
boolean inSpellCastingMode = false;

boolean inRockZone = false;
float currentPosX;
float currentPosY;
PImage bg;

int fCount = 0;
PVector last_pos_ee = new PVector(0, 0);
PVector speed = new PVector(0, 0); 




HeightMap myHeightMap = new HeightMap(200, 100, 100, 200);

boolean buzz = false;

boolean negative_feedback = false;

/*
toggles for different modalities
pressing v enables visual
pressing a enables audio
pressing h enables haptic
*/
boolean enable_visual = false;
boolean enable_audio = false;
boolean enable_haptic = false;

/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 800);
    //fig1 = new Figure("gargoyle.png", 50, 50, 44, 65);
    //fig2 = new Figure("gargoyle.png", 350, 130, 44, 65);
    //fig3 = new Figure("gargoyle.png", 250, 400, 44, 65);
    
    //npc = new Opponent("images/npc.png", 100, 100);
    player = new Player("images/player.png", 300, 600);
    
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
  haplyBoard          = new Board(this, "COM4", 0);
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
 s.setVirtualCouplingStiffness(36250);

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
  world.draw();
  
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  

  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
  
   // for sounds
  minim = new Minim(this);
  waterAudio = minim.loadFile("sounds/water.wav");

  fManager = new FigureManager(world);
  fManager.init();

}




void draw(){
 
  // draw this during normal gameplay
  background(140, 140, 120);
  //background(bg);
  textSize(38);
  textAlign(CENTER);
  text("Magic Paradise", width/2, 60);
  textSize(20);
  text("Move magic Pen to sense the magical object and press 's' to go to spell mode to cast a spell.", 500, height-40);
  world.draw();


  player.render(s.getAvatarPositionX()*pixelsPerCentimeter, s.getAvatarPositionY()*pixelsPerCentimeter);

  if(enable_visual){
    myHeightMap.showRamps();
  }
 
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

      //provide some feedback on if the spell was successfully cast or not
      if(mystring == "failed"){
        negative_feedback = true;
      }
      else{
        buzz = true;
      }


    }
  }

}

/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  float[] deviceAngles;
  float[] devicePositions;
  float[] forceArray1 = new float[2];
  float[] torquesArray1; 
  int what_ramp_am_i_on = 0;
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    rendering_force = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      deviceAngles = widgetOne.get_device_angles();
      devicePositions = widgetOne.get_device_position(deviceAngles);
      
      angles.set(deviceAngles[0], deviceAngles[1]); 
      pos_ee.set(devicePositions[0], devicePositions[1]);
      pos_ee.set(pos_ee.copy().mult(10));
 
    }

    s.setToolPosition(-pos_ee.x, pos_ee.y); 
    s.updateCouplingForce();
    f_ee.set(-s.getVCforceX(), s.getVCforceY());
    
    //put custom force code in here
    speed.set(PVector.sub(pos_ee,last_pos_ee).mult(pixelsPerCentimeter));

    //code for negative feedback
    if(negative_feedback){
      PVector myDist = myHeightMap.checkForCollisions(1);

      for(int i = 0; i<100; i++){
        f_ee.x = myDist.x * 0;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
        f_ee.y = myDist.y * 100;
        forceArray1[0] = f_ee.x;
        forceArray1[1] = f_ee.y;

        torquesArray1 = widgetOne.set_device_torques(forceArray1);
        torques.set(torquesArray1[0], torquesArray1[1]);
        widgetOne.device_write_torques();

      }

      println("negative feedback happened");
      negative_feedback = false;
    }
    //codek for positive feedback
    if(buzz == true ){

      PVector myDist = myHeightMap.checkForCollisions(1);
      
      for(int i = 0; i<100; i++){
        f_ee.x = myDist.x * 0;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
        f_ee.y = myDist.y * 100;
        forceArray1[0] = f_ee.x;
        forceArray1[1] = f_ee.y;

        torquesArray1 = widgetOne.set_device_torques(forceArray1);
        torques.set(torquesArray1[0], torquesArray1[1]);
        widgetOne.device_write_torques();

      }

      forceArray1[0] = 0;
        forceArray1[1] = 0;

        torquesArray1 = widgetOne.set_device_torques(forceArray1);
        torques.set(torquesArray1[0], torquesArray1[1]);
        widgetOne.device_write_torques();
      delay(100);
      for(int i = 0; i<100;i++){
        f_ee.x = myDist.x * 0;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
        f_ee.y = myDist.y * 100;
        forceArray1[0] = f_ee.x;
        forceArray1[1] = f_ee.y;

        torquesArray1 = widgetOne.set_device_torques(forceArray1);
        torques.set(torquesArray1[0], torquesArray1[1]);
        widgetOne.device_write_torques();
      }
      forceArray1[0] = 0;
        forceArray1[1] = 0;

        torquesArray1 = widgetOne.set_device_torques(forceArray1);
        torques.set(torquesArray1[0], torquesArray1[1]);
        widgetOne.device_write_torques();
      delay(200);
      for(int i = 0; i<100; i++){
        f_ee.x = myDist.x * 0;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
        f_ee.y = myDist.y * 100;
        forceArray1[0] = f_ee.x;
        forceArray1[1] = f_ee.y;

        torquesArray1 = widgetOne.set_device_torques(forceArray1);
        torques.set(torquesArray1[0], torquesArray1[1]);
        widgetOne.device_write_torques();
      }

      println("positive feedback happened");
      buzz = false;

    }

    if(enable_haptic){
      //code for triange wave texture
      what_ramp_am_i_on = myHeightMap.checkForRampContact(pos_ee);
      
      if(what_ramp_am_i_on == 1){//were on red ramps, they hould make us slide left
        PVector myDist = myHeightMap.applyDamping(pos_ee, speed);

        //positive 100 will make things slide right on ramps
        //negative 100 will make things slide left on ramps
        f_ee.x = myDist.x * -50;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
        f_ee.y = myDist.y * 100;
      }
      if( what_ramp_am_i_on == 2){//were on a blue ramp, they should make us slide right
        PVector myDist = myHeightMap.applyDamping(pos_ee, speed);

        //positive 100 will make things slide right on ramps
        //negative 100 will make things slide left on ramps
        f_ee.x = myDist.x * 50;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
        f_ee.y = myDist.y * 100;
      }
    }

    //new spot for last position calcuation
    last_pos_ee.set(pos_ee.copy());

    // end custom force code

    forceArray1[0] = f_ee.x;
    forceArray1[1] = f_ee.y;
    torquesArray1 = widgetOne.set_device_torques(forceArray1);
     
    torques.set(torquesArray1[0], torquesArray1[1]);
    widgetOne.device_write_torques();
  
    world.step(1.0f/1000.0f);
    rendering_force = false;
  }

}

/* end simulation section **********************************************************************************************/
void keyPressed() {

  if (key == 'n'){//enter spell casting mode
    negative_feedback = true;
    println("trigger negative feedback");

  }

  if(key=='p'){
    buzz = true;
    println("trigger positive feedback");
  }

  if (key == 'v'){
    enable_visual = !enable_visual;
    String state = enable_visual ? "on": "off";
    println("visual modality is ", state);

  }

  if (key == 'h'){
    enable_haptic = !enable_haptic;
    String state = enable_haptic ? "on": "off";
    println("haptic modality is ", state);
  }

  if (key == 's'){//enter spell casting mode
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
