///**
// **********************************************************************************************************************
// * @file       Haptic_Physics_Template.pde
// * @author     Steve Ding, Colin Gallacher
// * @version    V3.0.0
// * @date       27-September-2018
// * @brief      Base project template for use with pantograph 2-DOF device and 2-D physics engine
// *             creates a blank world ready for creation
// **********************************************************************************************************************
// * @attention
// *
// *
// **********************************************************************************************************************
// */
 
 
 
// /* library imports *****************************************************************************************************/ 
//import processing.serial.*;
//import static java.util.concurrent.TimeUnit.*;
//import java.util.concurrent.*;
///* end library imports *************************************************************************************************/  



///* scheduler definition ************************************************************************************************/ 
//private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
///* end scheduler definition ********************************************************************************************/ 



///* device block definitions ********************************************************************************************/
//Board             haplyBoard;
//Device            widgetOne;
//Mechanisms        pantograph;

//byte              widgetOneID                         = 3;
//int               CW                                  = 0;
//int               CCW                                 = 1;
//boolean           rendering_force                     = false;
///* end device block definition *****************************************************************************************/



///* framerate definition ************************************************************************************************/
//long              baseFrameRate                       = 120;
///* end framerate definition ********************************************************************************************/ 



///* elements definition *************************************************************************************************/

///* Screen and world setup parameters */
//float             pixelsPerCentimeter                 = 40.0;

///* generic data for a 2DOF device */
///* joint space */
//PVector           angles                              = new PVector(0, 0);
//PVector           torques                             = new PVector(0, 0);

///* task space */
//PVector           pos_ee                              = new PVector(0, 0);
//PVector           f_ee                                = new PVector(0, 0); 

///* World boundaries */
//FWorld            world;
//float             worldWidth                          = 25.0;  
//float             worldHeight                         = 10.0; 

//float             edgeTopLeftX                        = 0.0; 
//float             edgeTopLeftY                        = 0.0; 
//float             edgeBottomRightX                    = worldWidth; 
//float             edgeBottomRightY                    = worldHeight;

///* Initialization of virtual tool */
//HVirtualCoupling  s;

///* end elements definition *********************************************************************************************/



///* setup section *******************************************************************************************************/
//void setup(){
//  /* put setup code here, run once: */
  
//  /* screen size definition */
//  size(1000, 400);
  
  
//  /* device setup */
  
//  /**  
//   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
//   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
//   * to explicitly state the serial port will look like the following for different OS:
//   *
//   *      windows:      haplyBoard = new Board(this, "COM10", 0);
//   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
//   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
//   */
//  haplyBoard          = new Board(this, "COM3", 0);
//  widgetOne           = new Device(widgetOneID, haplyBoard);
//  widgetOne.add_analog_sensor("A0");
//  widgetOne.add_analog_sensor("A1");
//  widgetOne.add_analog_sensor("A2");
//  widgetOne.add_analog_sensor("A3");
//  pantograph          = new Pantograph();
  
//  widgetOne.set_mechanism(pantograph);
  
//  widgetOne.add_actuator(1, CW, 1);
//  widgetOne.add_actuator(2, CW, 2);
 
//  widgetOne.add_encoder(1, CW, 180, 13824, 1);
//  widgetOne.add_encoder(2, CW, 0, 13824, 2);
  
//  widgetOne.device_set_parameters();
  
  
//  /* 2D physics scaling and world creation */
//  hAPI_Fisica.init(this); 
//  hAPI_Fisica.setScale(pixelsPerCentimeter); 
//  world               = new FWorld();
  
  
//  /*
//   * Insert physics objects here
//   */
  
  
  
//  /* Setup the Virtual Coupling Contact Rendering Technique */
//  s = new HVirtualCoupling((1)); 
 
//                             //float   free_mass,
//                            //float   stiffness,
//                            //float   damping,
//                            //float   contact_mass )  

//  s.h_avatar.setDensity(2); 
//  s.updateCouplingForce  (0.25F, 250000.0F,700.0F,1.0010F); 
//  s.h_avatar.setFill(255,0,0); 
//  s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 
  
//  /* World conditions setup */
//  world.setGravity((0.0), (300.0)); //1000 cm/(s^2)
//  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
//  world.setEdgesRestitution(0.0);
//  world.setEdgesFriction(0.0);
  
//  world.draw();
  
  
//  /* setup framerate speed */
//  frameRate(baseFrameRate);
  
  
//  /* setup simulation thread to run at 1kHz */ 
//  SimulationThread st = new SimulationThread();
//  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
//}



///* draw section ********************************************************************************************************/
//void draw(){
//  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
//  background(255);
//  world.draw(); 
//}
///* end draw section ****************************************************************************************************/



///* simulation section **************************************************************************************************/
//class SimulationThread implements Runnable{
  
//  public void run(){
//    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
//    rendering_force = true;
    
//    if(haplyBoard.data_available()){
//      /* GET END-EFFECTOR STATE (TASK SPACE) */
//      widgetOne.device_read_data();
    
//      angles.set(widgetOne.get_device_angles()); 
    
//      pos_ee.set(widgetOne.get_device_position(angles.array()));
//      pos_ee.set(pos_ee.copy().mult(10));  
//      //println(pos_ee);
//    }
    
//    s.setToolPosition(-pos_ee.x, pos_ee.y); 
//    s.updateCouplingForce();
//    f_ee.set(-s.getVCforceX(), s.getVCforceY());
//   // f_ee.div(20000); //
    
//    torques.set(widgetOne.set_device_torques(f_ee.array()));
//    //println(torques);
//    widgetOne.device_write_torques();
  
//    world.step(1.0f/1000.0f);
  
//    rendering_force = false;
//    println(widgetOne.get_sensor_data()[3]);
//  }
//}
///* end simulation section **********************************************************************************************/



///* helper functions section, place helper functions here ***************************************************************/

///* end helper functions section ****************************************************************************************/
