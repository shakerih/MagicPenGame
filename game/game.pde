
  
 /* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
import ddf.minim.*;
/* end library imports *************************************************************************************************/  



/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 

boolean enable_audio, enable_visual, enable_haptic = false;
Minim minim;
AudioPlayer waterAudio, rockAudio;

PImage water, dirt;
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
Player player;
Figure fPlayer;
float K = 8.99; 

boolean inRockZone = false;
float currentPosX;
float currentPosY;
PImage bg;

int fCount = 0;
PVector last_pos_ee = new PVector(0, 0);
PVector speed = new PVector(0, 0); 
Water waterDampingSystem;
HeightMap myHeightMap = new HeightMap(200, 100, 100, 200);
/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 800);
    player = new Player("images/player.png", 300, 600);
    
    water = loadImage("images/water.png");
    dirt = loadImage("images/dry.jpg");
    dirt.resize(500,800);
    
    water.resize(500, 800);
    noStroke();
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
  
  waterDampingSystem = new Water();

  
  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
  
   // for sounds
  minim = new Minim(this);
  waterAudio = minim.loadFile("sounds/water.wav");
  rockAudio = minim.loadFile("sounds/scrapping.wav");
}


int fc = 0;

void draw(){
  if(enable_visual){
    tint(255, 100);  // Tint blue and set transparency
    image(water, 0, 0);
    tint(255, 255);
    image(dirt, 500, 0);
    drawWater(); 
    // draw this during normal gameplay
   // background(140, 140, 120);
    //background(bg);
    
    rect(0, 500, 1000, 300);
  }else{
   background(255); 
  }
  textSize(38);
  textAlign(CENTER);
  text("Magic Paradise", width/2, 60);
  textSize(20);
  text("Move magic Pen to sense the magical object and press 's' to go to spell mode to cast a spell.", 500, height-40);

  
  player.render(s.getAvatarPositionX()*pixelsPerCentimeter, s.getAvatarPositionY()*pixelsPerCentimeter);

  world.draw();
  if(enable_audio){
  if (s.getAvatarPositionX() < 11.0 && s.getAvatarPositionY() < 500/pixelsPerCentimeter) {

    waterAudio.play();
    if (rockAudio.position() != 0) {
      rockAudio.rewind();
    }
  } else if(s.getAvatarPositionY() < 500/pixelsPerCentimeter){
    if (rockAudio.position() == rockAudio.length()) {
      rockAudio.rewind();
    }
    if (inRockZone) {
      if (currentPosX != s.getAvatarPositionX() || currentPosY != s.getAvatarPositionY()) {
        rockAudio.play();
        currentPosX = s.getAvatarPositionX();
        currentPosY = s.getAvatarPositionY();
      } else {
        rockAudio.pause();
      }
      
    } else {
      currentPosX = s.getAvatarPositionX();
      currentPosY = s.getAvatarPositionY();
      inRockZone = true;
    }
    
    print(rockAudio.position());
    if (waterAudio.position() == waterAudio.length()) {
      waterAudio.rewind();
    }
    println("in right half");
  }
  }

}

/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  float[] deviceAngles;
  float[] devicePositions;
  float[] forceArray1 = new float[2];
  float[] torquesArray1; 
  
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
    
    waterDampingSystem.recordLastPosition(pos_ee.copy());
    s.setToolPosition(-pos_ee.x, pos_ee.y);
   s.updateCouplingForce();
   f_ee.set(-s.getVCforceX(), s.getVCforceY());
   
   
speed.set(PVector.sub(pos_ee,last_pos_ee).mult(pixelsPerCentimeter));
    if(s.getAvatarPositionX() < 11.0 && s.getAvatarPositionY() < 500/pixelsPerCentimeter && enable_haptic){ //water
      
      PVector myDist = myHeightMap.checkForCollisions(pos_ee, speed);
      //println("speed "+speed);

      f_ee.x = myDist.x * 300;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
      f_ee.y = myDist.y * 300;
    }else if(s.getAvatarPositionY() < 500/pixelsPerCentimeter && enable_haptic){
       PVector myDist = myHeightMap.checkForCollisionsDry(pos_ee, speed);
      //println("speed "+speed);

      f_ee.x = myDist.x * 300;//remember to make it negative as we did wth f_ee.set(-s.getVCforceX(), s.getVCforceY()); as this is what we'll do lower in the code
      f_ee.y = myDist.y * 300;
    }
     if(fc % 10 == 0){
      last_pos_ee.set(pos_ee.copy());
    }
    fc++;
  
     
     
     forceArray1[0] = f_ee.x;
     forceArray1[1] = f_ee.y;
     torquesArray1 = widgetOne.set_device_torques(forceArray1);
     
    torques.set(torquesArray1[0], torquesArray1[1]);
    widgetOne.device_write_torques();
  
    world.step(1.0f/1000.0f);
    rendering_force = false;
  }
}
void drawWater(){
 fill(255, 255);
  for(int i = 0; i< 100; i++){
   ellipse(mouseX, mouseY, 10, 10);
  }
}
/* end simulation section **********************************************************************************************/
void keyPressed() {
if (key == 'v'){//enter spell casting mode
   println("pressed v");
   enable_visual = !enable_visual;

 }
 else if (key == 'a'){
   println("pressed a");
   enable_audio = !enable_audio;
 }
 else if (key == 'h'){
   println("pressed h");
   enable_haptic = !enable_haptic;
 }

}
