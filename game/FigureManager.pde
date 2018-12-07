class FigureManager {
  
  int FIGURE_COUNT = 10;
  int spelledObjectIndex = -1;
  
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
    timer = new Timer(15000);
    collection = new Figure[FIGURE_COUNT];
  }
  
  void init() {
    this.timer.start();
    for(int i = 0; i < FIGURE_COUNT; i++) {
     float x = random(2, 24);
     float y = random(2, 18);
     String img = images[int(random(images.length))];
     String name = names[int(random(names.length))];
     collection[i] = new Figure(name, img, x, y, false);
     this.world.add(collection[i]);
    }
    int k = int(random(0, this.collection.length-1));
    this.collection[k].spelled = true;
    println(this.collection[k].figureName, " is spelled");
    this.spelledObjectIndex = k;
    this.switchSpells();
  }
  
   
   void switchSpells() {
     if (this.timer.isOff()) {
       print("Time is up! spell object changed");
       this.collection[this.spelledObjectIndex].spelled = false;
       int k = int(random(0, this.collection.length-1));
       this.collection[k].spelled = true;
       println(this.collection[k].figureName, " is spelled now");
       this.spelledObjectIndex = k;
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
   
   
   Figure findNearestSpelledTarget(PVector position) {
     
     float d;
     for(int i = 0; i < this.collection.length; i++) {
       
       if (!this.collection[i].spelled) {
         continue;
       }
       
       Figure fig = this.collection[i];
       d = dist(-position.x, position.y, fig.getX(), fig.getY());
       if (d < 5) {
         println(" this object is near, " + fig.figureName);
         return fig;
       }
     }
     return null;
   }
}
