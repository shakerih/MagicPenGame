class FigureManager {
  
  int FIGURE_COUNT = 10;
  String[] images = {
     "images/gargoyle.png",
     "images/gargoyle2.png",
     "images/gargoyle3.png",
     "images/cat.png",
     "images/mouse.png"
  };
  
  String[] names = {
    "Ravioli",
    "Hippogriff",
    "Niffler",
    "Coin",
    "Apple",
    "Garbage",
    "Gold",
    "Gelatin",
    "Mushrooms",
    "Croissant"
  };
  
  Timer timer;
  Figure[] collection;
  FWorld world;
  Figure player;
  
  FigureManager(FWorld world) {
    this.world = world;
    timer = new Timer(5000);
    collection = new Figure[FIGURE_COUNT];
  }
  
  void init() {
    this.timer.start();
    for(int i = 0; i < FIGURE_COUNT; i++) {
     float x = random(2, 24);
     float y = random(2, 18);
     String img = images[int(random(images.length))];
     String name = names[int(random(names.length))];
     boolean spell = int(random(10, 50)) > 25 ? true : false;
     collection[i] = new Figure(name, img, x, y, spell);
     this.world.add(collection[i]);
    }
    
  }
  
   
   void switchSpells() {
     if (this.timer.isOff()) {
       for (int i = 0; i < FIGURE_COUNT; i++) {
           collection[i].setSpelled(int(random(1)) == 1 ? true : false);
       }
       this.timer.start();
     }
   }
   
   Figure getPlayer() {
     if (this.player == null) {
      float x = random(2, 24);
      float y = random(2, 18);
      this.player = new Figure("player","images/player.png", x, y, true);
      this.player.setFill(156);
      this.world.add(this.player);
     }
     return this.player;
     
   }
}
