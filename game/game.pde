Figure fig1, fig2, fig3;
Opponent npc;
Player player;
void setup(){
  size(600,600);
  fig1 = new Figure("gargoyle.png", 50, 50, 44, 65);
  fig2 = new Figure("gargoyle.png", 350, 130, 44, 65);
  fig3 = new Figure("gargoyle.png", 250, 400, 44, 65);
  
  npc = new Opponent("npc.png", 100, 100);
  player = new Player("player.png", 300, 300);
}

void draw(){
background(140, 140, 120);
fig1.render();
fig2.render();
fig3.render();

npc.render();
player.render();
}
