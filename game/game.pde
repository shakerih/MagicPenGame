
  
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
FBox shudder;
FigureManager fManager;
Figure fPlayer;
float K = 8.99; 
//pat--> create new spell recognitction object
SpellRecognition mySpellRec = new SpellRecognition(worldWidth, worldHeight, pixelsPerCentimeter);


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
  haplyBoard          = new Board(this, "COM3", 0);
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
  
   // for sounds
  minim = new Minim(this);
  waterAudio = minim.loadFile("sounds/water.wav");
  rockAudio = minim.loadFile("sounds/scrapping.wav");
}


boolean inRockZone = false;
float currentPosX;
float currentPosY;

void draw(){
 
  // draw this during normal gameplay
  background(140, 140, 120);
  textSize(38);
  textAlign(CENTER);
  text("Magic Paradise", width/2, 60);
  textSize(20);
  text("Move magic Pen to sense the magical object and press 's' to go to spell mode to cast a spell.", 500, height-40);
  
  fManager.switchSpells();
 // npc.render();
  
  player.render(s.getAvatarPositionX()*pixelsPerCentimeter, s.getAvatarPositionY()*pixelsPerCentimeter);

  world.draw();
  
  if (s.getAvatarPositionX() < 11.0) {
    println("in left half");
    waterAudio.play();
    //waterAudio.rewind();
    if (rockAudio.position() != 0) {
      rockAudio.rewind();
    }
  } else {
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
  
  if(false){
    //spell recognition code
    mySpellRec.showGrid();// show the  9 x 9 casting grid
    mySpellRec.checkForCollisions(s.getAvatarPositionX()*pixelsPerCentimeter, s.getAvatarPositionY()*pixelsPerCentimeter, pixelsPerCentimeter/2);//call this to check if theyve hit differnt parts of the 9x9 grid
    String mystring = mySpellRec.checkIfSpellCast();//check if a spell has successfully been cast (they hit the corrext cicles on the grid)
    if(mystring != "none"){
        println(mystring);
        //should move the avatar to the bottom left starting point
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
    
    //for(int i = 0; i < 10; i++) {
    //  f_ee.set((f_ee.x - random(10)), (f_ee.y + random(10)));  
    //}
    for (int i = 0; i < fManager.collection.length; i++) {
      Figure charge = fManager.collection[i];
      if (charge.spelled) {
         float dx = s.getAvatarPositionX() - charge.getX();
         float dy = s.getAvatarPositionY() - charge.getY();
         float dd = sqrt( dx*dx + dy*dy);
         float ft = K* charge.q * (-120)/(dd*dd);
         PVector vector = new PVector(-ft*dx/dd, ft*dy/dd);
         f_ee.add(vector);
      }
    }    
    
    f_ee.div(100);
    //println("coupling force: ", -s.getVCforceX()); 
    //f_ee.set(-0.001, -0.0001);
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
    println("pressed s");

  }

}

void draw_instructions() {
 
}

//ArrayList<PVector> computeEachForce() {
//    ArrayList<PVector> vectors = new ArrayList<PVector>();   
  
//   for(ElectricCharge c : charges){
//     if (c != current_charge){
//       float dx = c.x_pos - current_charge.x_pos;
//       float dy = c.y_pos - current_charge.y_pos;
//       float dd = sqrt( dx*dx + dy*dy);
       
//      // println("dd: ", dd);
       
//       float ft = K* current_charge.q * c.q/(dd*dd); // current_charge.q * c.q = qp*qn    
//       PVector vector = new PVector(ft*dx/dd, ft*dy/dd);
//       vectors.add(vector);
//     }
//   }
   
//  return vectors;
//}
//ArrayList<PVector> computeForceOn(ElectricCharge selCharge) {
//    ArrayList<PVector> vectors = new ArrayList<PVector>();   
  
//   for(ElectricCharge c : charges){
//     if (c != selCharge){
//       float dx = c.x_pos - selCharge.x_pos;
//       float dy = c.y_pos - selCharge.y_pos;
//       float dd = sqrt( dx*dx + dy*dy);
       
//      // println("dd: ", dd);
       
//       float ft = K* selCharge.q * c.q/(dd*dd); // current_charge.q * c.q = qp*qn    
//       PVector vector = new PVector(ft*dx/dd, ft*dy/dd);
//       vectors.add(vector);
//     }
//   }
   
//  return vectors;
//}
//float[] computeTotalForce1(ArrayList<PVector> vectors){ //sets f_ee to what it should be
//  float fx_total = 0;
//  float fy_total = 0;
//  float[] forces = new float[2];   
//  for(PVector v : vectors) {
//       fx_total += v.x;
//       fy_total += v.y;
//       //actualForce = new PVector(fx_total, fy_total);  
//       actualForce = new PVector(fx_total, fy_total);  
//           forces[0]=-fx_total/25;
//           forces[1]=fy_total/25;
//           //println(abs(-fx_total),abs(fy_total));
//           if((30<=abs(fx_total)&abs(fx_total)<50)|30<=abs(fy_total)&abs(fy_total)<50) {
//             forces[0]=0;
//             forces[1]=0;
//              //player.setGain(1);
//           }
//           else if((50<=abs(fx_total))|50<=abs(fy_total)) {
//            forces[0]=.571*fx_total/(abs(fx_total));
//            forces[1]=-.571*fy_total/(abs(fy_total));
//             forces[0]=0;
//             forces[1]=0;
//              //player.setGain(1);
//           }else{
//             forces[0]=-fx_total/25;
//             forces[1]=fy_total/25;
//             //player.setGain(-10/(fy_total*fy_total+fx_total*fx_total));
//         }
     
//      // forces[0]=(-fx_total/25);
//      // forces[1]=(fy_total/25);
       
//  }
//  force_vector = new PVector(5*fx_total, 5*fy_total);
//  //force_vector = new PVector(5*fx_total, 5*fy_total);
//  return forces;
//}
