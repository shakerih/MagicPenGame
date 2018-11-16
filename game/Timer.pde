class Timer {

  int startTime;
  int timerLength;
  
  Timer(int duration) {
    this.timerLength = duration;
  }
  
  void start() {
    startTime = millis();
  }
  
  boolean isOff() {
    if ((millis() - startTime) >= timerLength) {
      return true;
    } else {
      return false;
    }
  }
}
