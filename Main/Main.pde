Player p;
Bar b;
StageList stages;
int score;
int highScore;
ArrayList<Fish> fishies = new ArrayList<Fish>();
ArrayList<Powerup> powers = new ArrayList<Powerup>();
int timer, eventTimer;
int barHeight;
int multi;
PFont font;
String fName = "Champagne & Limousines";
boolean nextLevelAnimation;
boolean win;

void setup() {
  score = 0;
  size(1000, 600); 
  frameRate(60);
  noStroke();
  timer = 0;
  eventTimer = 0;
  barHeight = 80;
  background(0);
  p = new Player(width/2, 0);
  p.invulnerable = 0;
  b = new Bar();
  stages = new StageList();
  loadStages();
  multi = 1;
  p.lifeAnimation = true;
  win = false;
}

void draw() {
  if (stages.head.name.equals("start")) {
    stages.head.startScreen();
  } else {
    displayLevel();
    multi = stages.head.multiplier;
    if (p.invulnerable > 0)
      p.invulnerable -= 1;
    if (p.speedBoost > 0){
      p.speedBoost -= 1;
      p.springing += .001;
    }
    timer = timer + 1;
    if (score > highScore)
      highScore = score;
    if (win) {
      winScreen();
    } else if (!(p.dead) && !win) {
      fillBlack(); 
      p.update();
      updatePowers();
      updateFish();
      nextLevelCheck();
      if (!nextLevelAnimation) 
        addFish();   
        addPowers();
      //menu bar
      drawBar();
      b.redraw();
      p.displayLives();
    } else 
      gameOver();
  }
}

void updatePowers(){
  for (Powerup po : powers){
    po.update();
    if (po.outOfBounds()){
      powers.remove(po);
      break;
    }
    else if (touching(po)){
      absorb(po);
      break;
    }
  }
}
      
    

void updateFish() {
  for (Fish f : fishies) {
    f.update();
    if (f.outOfBounds()) {
      fishies.remove(f);
      break;
    }
    if (canEat(f)) {
      eat(f);
      if (b.frenzy)
        score += f.size * multi * 2;
      else 
        score += f.size * multi;
      break;
    } 
    if (canBeEaten(f)) {
      p.loseLife();
      p.invulnerable += 270;
      break;
    }
  }
}

void nextLevelCheck() {
  if (p.size >= 55) 
    nextLevelAnimation = true; 
  if (nextLevelAnimation && fishies.size() == 0 && powers.size() == 0) {
    p.size -= 0.25;
    if (p.size <= 15) {
      nextLevelAnimation = false;
      if (stages.head.getNextStage() == null) 
        win = true;
      else {
        stages.moveToNextStage();
        multi = stages.head.multiplier;
        eventTimer = timer;
      }
    }
  }
  displayLevel();
}

boolean touching(Fish t) {
  float distance = p.size / 2 + t.size / 2;
  boolean x = abs(t.centerX - p.centerX) < distance;
  boolean y = abs(t.centerY - p.centerY) < distance;
  return x && y;
}

boolean canEat(Fish t) {
  return touching(t) && (t.size < p.size) && !p.lifeAnimation;
}

boolean canBeEaten(Fish t) {
  return touching(t) && (t.size >= p.size) && !p.lifeAnimation && !(p.invulnerable > 0);
}

Fish randomFish(int s) {
  return new Fish(s, width / 2 + ((int)random(2) * 2 - 1) * (width + s) / 2, random(height - barHeight) + barHeight, false);
}

void absorb(Powerup pow){
  if (random(2) < 1){
    if (p.lives < 3)
      p.lives++;
  }
  else if (random(500) < 1){
    score = (round(score * 1.5));
    if (b.frenzy)
      score = (round(score * 1.5));
  }
  else if (random(10) < 1){
    p.speedBoost = 50;
    p.springing = 0.05;
  }
  else{
    p.invulnerable = 250;
  }
  powers.remove(pow);
}

void eat(Fish f) {
  p.upsize((f.size + 5) / p.size * 0.25);
  if (!b.frenzy)
    b.addPercent((f.size + 5) / p.size * f.size * multi);
  fishies.remove(f);
}

void addFish() {
  if (timer % 30 == 0) 
    fishies.add(randomFish(10));
  if (timer % 60 == 0) 
    fishies.add(randomFish(20));
  if (timer % 180 == 0) 
    fishies.add(randomFish(30));
  if (timer % 270 == 0) 
    fishies.add(randomFish(40)); 
  if (timer % 600 == 0) 
    fishies.add(randomFish(50));
}

void addPowers(){
  if (random(2000) < 1)
    powers.add(new Powerup(10));
}

void gameOptions() {
  font = createFont(fName, 30);
  textFont(font);
  text("restart level?", width / 2 - 100, height / 2 + 30);
  text("start over?", width / 2 + 100, height / 2 + 30);
  fill(255);
  if (mousePressed) {
    if (abs(mouseY - (height / 2 + 30)) < 30) {
      if (abs(mouseX - (width / 2 - 100)) < 55) {
        p = new Player(width/2, 0);
        p.lifeAnimation = true;
      } else if (abs(mouseX - (width / 2 + 100)) < 80)
        setup();
      fishies = new ArrayList<Fish>();
      powers = new ArrayList<Powerup>();
    }
  }
  p.invulnerable += 40;
}

void replayOptions() {
  font = createFont(fName, 30);
  textFont(font);
  text("replay?", width / 2, height / 2 + 30);
  if (mousePressed) {
    if (abs(mouseY - (height / 2 + 30)) < 30) {
      if (abs(mouseX - (width / 2)) < textWidth("replay?") / 2)
        setup();
      fishies = new ArrayList<Fish>();
      powers = new ArrayList<Powerup>();
    }
  }
}

void gameOver() {
  screen();
  fill(255);
  font = createFont(fName, 50);
  textFont(font);
  textAlign(CENTER);
  text("GAME OVER", width / 2, height / 2);
  gameOptions();
}

void winScreen() {
  screen();
  textAlign(CENTER);
  font = createFont(fName, 50);
  textFont(font);
  fill(255);
  text("YOU WIN", width / 2, (height + barHeight) / 2 - 50);
  replayOptions();
}

void displayLevel() {
  if (timer <= eventTimer + 120) {
    fill(255);
    font = createFont(fName, 50);
    textFont(font);
    textAlign(CENTER);
    text("Level " + multi, width / 2, height / 2);
  }
}

void loadStages() {
  stages.add(new Stage("one", 1)); 
  stages.add(new Stage("two", 2));  
  stages.add(new Stage("three", 3)); 
  //need this to cheat past stages;
  //stages.moveToNextStage();
  //stages.moveToNextStage();
  //stages.moveToNextStage();
}

void screen() {
  fillBlack();
  for (Fish f : fishies) 
    f.update();
  for (Powerup po : powers)
    po.update();
  addFish();
  addPowers();
  drawBar();
  b.redraw();
  p.displayLives();
  fill(0, 150);
  rect(0, 0, width, height);
}

void fillBlack() {
  fill(0, 90);
  rect(0, 0, width, height);
}

void drawBar() {
  fill(255, 255);
  rect(0, 0, width, barHeight);
}


