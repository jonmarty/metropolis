int step = 0;
int last_recorded_step = 0;
int last_sampled_step = -1;
int substep = 0;
int step_limit = 100000;
boolean runContinuously = false;
boolean showText = true;

float lenPerBound = 10;
int[] bounds = {100,100};
int s = 5;
float[][] heatmap = new float[bounds[0] + 1][bounds[1] + 1];
boolean heatmapOn = true;
float[][] board = new float[bounds[0] + 1][bounds[1] + 1];
float[] base = {100,100,100};
float[] target = {255,0,0};
ColorMap colormap = new CustomColorMap(base, target);

int n_pts = 10;
int[][][] history = new int[1][n_pts][2];
int[][] samples = new int[n_pts][2];
PrintWriter output;
String output_file = "data/hello.txt";
float[] pointColor = {0, 0, 255};
int selectedPoint;
int[] selectedPointHistory = new int[1];
float[] selectedPointColor = {0,255,0};
float[][] proposalTiles = new float[4*s][2];
int[] proposalTileColor = {0,100,0};

boolean saveVideo = false;
String frameFile = "./data/frame-####.tif";
int framePeriod = 100;

TwoDimDistribution prior = new TwoDimDistribution(new Uniform(0,bounds[0]), new Uniform(0,bounds[1]));
MetropolisProposal proposal = new MetropolisProposal(s);

//Ising model variables
float k = 1.380649 * pow(10,-23); // Boltzmann constant (J/K)
float T = 500.0; //Find a good temperature (K)
float mass = 5 * pow(10,-5); //Mass of each particle (kg)
MetropolisIsingModel prob = new MetropolisIsingModel(k,T);

void setup(){
  size(2000,2000);
  genData();
  output = createWriter(output_file);
  for (int i = 0; i < n_pts; i++){
    output.println(str(samples[i][0]) + " " + str(samples[i][0]));
  }
}

void draw(){
  background(128);
  
  if (step >= step_limit){
    output.flush();
    output.close();
    exit();
  }
  
  if (frameCount % 10 == 0 && runContinuously){
    nextFull();
  }
  
  float cellHeight = height/bounds[0];
  float cellWidth = width/bounds[1];
  
  for (int row = 0; row < bounds[0] + 1; row++) {
    for(int column = 0; column < bounds[1] + 1; column++) {
      float cellX = cellWidth * column;
      float cellY = cellHeight * row;
      
      float[] col;
      if (heatmapOn){col = colormap.call(heatmap[row][column]/(step+n_pts) * 200);}
      else {col = colormap.call(board[row][column]);}
      fill(col[0], col[1], col[2]);
      
      rect(cellX, cellY, cellWidth, cellHeight);
    }
  }
  
  // Highlight proposal distribution
  if (step > 0 || substep > 0){
    for (int i = 0; i < proposalTiles.length; i++){
      fill(proposalTileColor[0], proposalTileColor[1], proposalTileColor[2]);
      
      if (proposalTiles[i][0] < 0) {proposalTiles[i][0] = bounds[0] + proposalTiles[i][0];}
      else if (proposalTiles[i][0] > bounds[0]) {proposalTiles[i][0] = proposalTiles[i][0] - bounds[0] - 1;}
      if (proposalTiles[i][1] < 0) {proposalTiles[i][1] = bounds[1] + proposalTiles[i][1];}
      else if (proposalTiles[i][1] > bounds[1]){proposalTiles[i][1] = proposalTiles[i][1] - bounds[1] - 1;}
      
      rect(cellWidth * proposalTiles[i][1], cellHeight * proposalTiles[i][0], cellWidth, cellHeight);
    }
  }
  
  // Draw particles
  for (int i = 0; i < n_pts; i++){
    int[] h = history[step][i];
    fill(pointColor[0], pointColor[1], pointColor[2]);
    ellipse(cellWidth * h[1] + cellWidth/2, cellHeight * h[0] + cellHeight/2, cellWidth, cellHeight);
  }
  
  // Highlight selected point in green
  if(step > 0 || substep > 0){
    int[] h = history[step][selectedPoint];
    fill(selectedPointColor[0], selectedPointColor[1], selectedPointColor[2]);
    ellipse(cellWidth * h[1] + cellWidth/2, cellHeight * h[0] + cellHeight/2, cellWidth, cellHeight);
  }
  
  int tsize = 50;
  textSize(tsize);
  
  if (showText){
    fill(255,255,255);
    int xloc;
    if (step == 0) {xloc = width - 10 * tsize;}
    else {xloc = width - 10 * tsize - tsize/2 * int(log(step)/log(10));}
    text(str(step) + " - " + str(prob.call(history[step])), xloc, tsize);
  }
  
  if (saveVideo && frameCount % framePeriod == 0){
    saveFrame(frameFile);
  }
  
}

void prevFull(){
    int prevStep = step;
    prev();
    if(step != prevStep){
      removeFromHeatmap(samples[n_pts + prevStep - 1]);
    }
}

void nextFull(){
  int prevStep = step;
  next();
  if(step != prevStep ){
    if(step > last_recorded_step){
      output.println(str(samples[n_pts + step - 1][0]) + " " + str(samples[n_pts + step - 1][0]));
    }
    addToHeatmap(samples[n_pts + step - 1]);
  }
}

void keyPressed(){
  if(keyCode == 69){
    heatmapOn = !heatmapOn;
  }
  if(keyCode == LEFT){
    prevFull();
  }
  if(keyCode == RIGHT){
    nextFull();
  }
  if(keyCode == UP){
    runContinuously = !runContinuously;
  }
  if(keyCode == DOWN){
    showText = !showText;
  }
}

void mousePressed(){
  println(mouseX, mouseY);
  int y = round(mouseY * bounds[0] / height);
  int x = round(mouseX * bounds[1] / width);
  board[y][x] += 1.0/200.0;
}

void addToHeatmap(int[] pt){
  int y = round(pt[0]);
  int x = round(pt[1]);
  heatmap[y][x] += 1;
}

void removeFromHeatmap(int[] pt){
  int y = round(pt[0]);
  int x = round(pt[1]);
  heatmap[y][x] -= 1;
}

void fillHeatmap(){
  heatmap = new float[bounds[0] + 1][bounds[1] + 1];
  for (int i = 0; i < n_pts + step; i++){
    addToHeatmap(samples[i]);
  }
}
