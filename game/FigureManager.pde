class FigureManager {
  
  int FIGURE_COUNT = 9; //hardocde this to 9, don't change!!!!
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
    float x_offset = 6.25;
    float y_offset = 5;
    int figure_counter = 0;


    //set the position of image 1 
    float x = x_offset;
    float y = y_offset;
    //grabs a random name and picture to apply to the objects
    String img = images[int(random(images.length))];
    String name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

    //set the position of image 2
    x = x_offset*2;
    y = y_offset;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

     //set the position of image 3
    x = x_offset*3;
    y = y_offset;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

     //set the position of image 4
    x = x_offset;
    y = y_offset*2;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

     //set the position of image 5
    x = x_offset*2;
    y = y_offset*2;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

     //set the position of image 6
    x = x_offset*3;
    y = y_offset*2;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

     //set the position of image 7
    x = x_offset;
    y = y_offset*3;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

     //set the position of image 8
    x = x_offset*2;
    y = y_offset*3;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;

     //set the position of image 9
    x = x_offset*3;
    y = y_offset*3;
    //grabs a random name and picture to apply to the objects
    img = images[int(random(images.length))];
    name = names[int(random(names.length))];
    collection[figure_counter] = new Figure(name, img, x, y, false);
    this.world.add(collection[figure_counter]);
    figure_counter++;


    


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
