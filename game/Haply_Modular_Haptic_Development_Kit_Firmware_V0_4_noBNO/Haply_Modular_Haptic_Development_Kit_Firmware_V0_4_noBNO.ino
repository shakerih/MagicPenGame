/**
 ************************************************************************************************
 * @file       Haply_Arduino_Firmware.ino
 * @author     Steve Ding, Colin Gallacher
 * @version    V1.5.0
 * @date       11-September-2017
 * @brief      Haply board firmware for encoder and sensor read and torque write using on-board 
 *             actuator ports
 ************************************************************************************************
 * @attention
 *
 *
 ************************************************************************************************
 */

/* includes ************************************************************************************/ 
#include <stdlib.h>
#include <Encoder.h>
#include <pwm01.h>
#include "Haply_Modular_Haptic_Development_Kit_Firmware_V0_4.h"
#include <DueTimer.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

/* Actuator, Encoder, Sensors parameter declarations *******************************************/
actuator actuators[TOTAL_ACTUATOR_PORTS];
encoder encoders[TOTAL_ACTUATOR_PORTS];
pwm pwmPins[PWM_PINS];
sensor analogSensors[ANALOG_PINS];
//sensor digitalSensors[DIGITAL_PINS];
/* Set the delay between fresh samples */
//Adafruit_BNO055 bno = Adafruit_BNO055(55);

/* Actuator Status and Command declarations ****************************************************/

/* Address of device that sent data */
byte deviceAddress;

/* communication interface control, defines type of instructions recieved */
byte cmdCode;

/* communication interface control, defines response to send */
byte replyCode = 3;

/* Iterator and debug definitions **************************************************************/
long lastPublished = 0;

int      ledPin = 13;

int state = HIGH;      // the current state of the output pin
int reading;           // the current reading from the input pin
int previous = LOW;    // the previous reading from the input pin
long time1 = 0;         // the last time the output pin was toggled
long debounce = 200;   // the debounce time, increase if the output flickers
/* main setup and loop block  *****************************************************************/

/**
 * Main setup function, defines parameters and hardware setup
 */
void setup() {
  SerialUSB.begin(0);
  reset_device(actuators, encoders, analogSensors, pwmPins);
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  SerialUSB.begin(0);
  pinMode(Lft, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(Lft), Right, CHANGE);
  pinMode(Rht,INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(Rht), Left, CHANGE);
  pinMode(Up, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(Up), Upa, CHANGE);
  pinMode(Dwn, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(Dwn), Down, CHANGE);
  pinMode(btn, INPUT);
 // Timer3.attachInterrupt(orientation).start(15000);
 // Timer3.start();
//  if(!bno.begin())
//  {
//    float roll=1.0F;
//
//    float pitch=1.0F;
//
//    float yaw=1.0F;
//  }
//  bno.setExtCrystalUse(true);
}
//
//void orientation(){
//   //buttonState = digitalRead(btn);
//     sensors_event_t event;
//     bno.getEvent(&event);
//
//  /* Board layout:
//         +----------+
//         |         *| RST   PITCH  ROLL  HEADING
//     ADR |*        *| SCL
//     INT |*        *| SDA     ^            /->
//     PS1 |*        *| GND     |            |
//     PS0 |*        *| 3VO     Y    Z-->    \-X
//         |         *| VIN
//         +----------+
//  */
//
//    imu::Quaternion quat = bno.getQuat();
//    toEulerAngl(quat.w(),quat.x(),quat.y(),quat.z());
//}
/**
 * Main loop function
 */
void loop() {
    reading = digitalRead(btn);
    if (reading == HIGH && previous == LOW && millis() - time1 > debounce) {
          if (state == HIGH)
            state = LOW;
          else
            state = HIGH;
      
          time1 = millis();    
        }
      
        buttonState=state;
      
        previous = reading;
  if(micros() - lastPublished >= 50){

    lastPublished = micros();

    if(SerialUSB.available() > 0){

      cmdCode = command_instructions();

      switch(cmdCode){
        case 0:
          deviceAddress = reset_haply(actuators, encoders, analogSensors, pwmPins);
          break;
        case 1:
          deviceAddress = setup_device(actuators, encoders, analogSensors, pwmPins);
          break;
        case 2:
          deviceAddress = write_states(pwmPins, actuators);
          replyCode = 1;
          break;
        default:
          break;
      }
    }

    switch(replyCode){
      case 0:
        break;
      case 1:
        read_states(encoders, analogSensors, deviceAddress);
        replyCode = 3;
        break;
      default:
        break;
    }
  }
}
static void toEulerAngl(double w, double x, double y, double z)
{
  // roll (x-axis rotation)
  double sinr_cosp = +2.0 * (w * x + y * z);
  double cosr_cosp = +1.0 - 2.0 * (x * x + y * y);
  roll = atan2(sinr_cosp, cosr_cosp)*180/3.1415;

  // pitch (y-axis rotation)
  double sinp = +2.0 * (w * y - z * x);
  if (abs(sinp) >= 1)
    pitch = copysign(M_PI / 2, sinp)*180/3.1415; // use 90 degrees if out of range
  else
    pitch = asin(sinp)*180/3.1415;

  // yaw (z-axis rotation)
  double siny_cosp = +2.0 * (w * z + x * y);
  double cosy_cosp = +1.0 - 2.0 * (y * y + z * z);  
  yaw = atan2(siny_cosp, cosy_cosp)*180/3.1415;
}

