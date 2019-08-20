class Distribution {
  Distribution() {}
  int sample(){return(0);}
  float prob(float num){
    if(num == 0.0){return(1);}
    else{return(0.0);}
  }
}

class Uniform extends Distribution {
  float min, max;
  Uniform(float minIN, float maxIN){
    super();
    min = minIN;
    max = maxIN;
  }
  int sample(){
    return round(min + random(0,1) * (max - min));
  }
  float prob(int num){
    if (num >= min && num <= max){
      return(1.0/(max - min));
    }
    else {
      return(0);
    }
  }
}

class TwoDimDistribution {
  Distribution dist1, dist2;
  TwoDimDistribution(Distribution dist1IN, Distribution dist2IN) {
    dist1 = dist1IN;
    dist2 = dist2IN;
  }
  int[] sample(){
    int[] samples = new int[2];
    samples[0] = dist1.sample();
    samples[1] = dist2.sample();
    return(samples);
  }
  float prob(int[] pt){
    return(dist1.prob(pt[0]) * dist2.prob(pt[1]));
  }
}

class MetropolisProposal {
  int s;
  MetropolisProposal(int sIN){
    s = sIN;
  }
  int[] sample(int[] pt){
    int[] samples = new int[2];
    arrayCopy(pt, samples);
    int n = int(random(0,1) * (4*s));
    if (n < s){
      samples[0] = pt[0] - (n + 1);
    }
    else if (n < 2*s){
      samples[0] = pt[0] + (n - s + 1);
    }
    else if (n < 3*s){
      samples[1] = pt[1] - (n - 2*s + 1);
    }
    else {
      samples[1] = pt[1] + (n - 3*s + 1);
    }
    return(samples);
  }
  float prob(int[] pt1, int[] pt2){
    if((pt1[0] == pt2[0] || pt1[1] == pt2[1]) && abs(pt2[0] - pt1[0]) <= s && abs(pt2[1] - pt1[1]) <= s){
      return(1.0/(4*s));
    }
    else {
      return(0.0);
    }
  }
}

float gravPotentialEnergy(float d, float m){
  float G = 6.67408 * pow(10, -11);
  return G*pow(m,2)/d;
}

float euclideanDistance(int[] pt1, int[] pt2){
  return sqrt(pow(pt1[0] - pt2[0], 2) + pow(pt1[1] - pt2[1], 2));
}

class MetropolisIsingModel {
  float k, T;
  MetropolisIsingModel(float kIN, float TIN){
    k = kIN;
    T = TIN;
  }
  float call(int[][] pts){
    float e = 0;
    for (int i = 0; i < pts.length; i++){
      for (int j = 0; j < pts.length; j++){
        if(i==j){continue;}
        int[] pt1 = new int[2];
        arrayCopy(pts[i], pt1);
        int[] pt2 = new int[2];
        arrayCopy(pts[j], pt2);
        float[] d = new float[9];

        pt2[0] = pt2[0] - bounds[0];
        pt2[1] = pt2[1] - bounds[1];
        d[0] = euclideanDistance(pt1, pt2);

        pt2[1] = pt2[1] + bounds[1];
        d[1] = euclideanDistance(pt1, pt2);

        pt2[1] = pt2[1] + bounds[1];
        d[2] = euclideanDistance(pt1, pt2);

        pt2[0] = pt2[0] + bounds[0];
        pt2[1] = pt2[1] - 2 * bounds[1];
        d[3] = euclideanDistance(pt1, pt2);

        pt2[1] = pt2[1] + bounds[1];
        d[4] = euclideanDistance(pt1, pt2);

        pt2[1] = pt2[1] + bounds[1];
        d[5] = euclideanDistance(pt1, pt2);

        pt2[0] = pt2[0] + bounds[0];
        pt2[1] = pt2[1] - 2 * bounds[1];
        d[6] = euclideanDistance(pt1, pt2);

        pt2[1] = pt2[1] + bounds[1];
        d[7] = euclideanDistance(pt1, pt2);

        pt2[1] = pt2[1] + bounds[1];
        d[8] = euclideanDistance(pt1, pt2);

        e += gravPotentialEnergy(min(d), mass);
      }
    }
    return exp(-e/(k*T));
  }
}

void genData(){
  history = new int[1][n_pts][2];
  samples = new int[n_pts][2];
  heatmap = new float[bounds[0] + 1][bounds[1] + 1];
  step = 0;
  for(int i = 0; i < n_pts; i++){
    samples[i] = prior.sample();
    addToHeatmap(samples[i]);
  }
  history[0] = samples;
}

boolean noOverlap(int[] pt, int[][] set){
  for (int i = 0; i < set.length; i++){
    if(pt == set[i]){
      return false;
    }
  }
  return true;
}

void setProposalTiles(){
    int[] hist = history[history.length - 1][selectedPoint];
    for (int i = 0; i < s; i++){
      proposalTiles[i][0] = hist[0] + i + 1;
      proposalTiles[i][1] = hist[1];
      proposalTiles[i + 5][0] = hist[0] - i - 1;
      proposalTiles[i + 5][1] = hist[1];
      proposalTiles[i + 10][0] = hist[0];
      proposalTiles[i + 10][1] = hist[1] + i + 1;
      proposalTiles[i + 15][0] = hist[0];
      proposalTiles[i + 15][1] = hist[1] - i - 1;
    }
}

void next(){
  if (substep == 3){
    substep = 0;
    step++;
    if (step > last_recorded_step){
      last_recorded_step++;
      int ind = selectedPoint;
      int[] curr = history[history.length - 1][ind];
      int[] prop = proposal.sample(curr);
      int[][] pts_prop = new int[n_pts][2];
      arrayCopy(history[history.length - 1], pts_prop);
      pts_prop[ind] = prop;

      if (prop[0] < 0) {prop[0] = bounds[0] + prop[0];}
      else if (prop[0] > bounds[0]) {prop[0] = prop[0] - bounds[0];}
      if (prop[1] < 0) {prop[1] = bounds[1] + prop[1];}
      else if (prop[1] > bounds[1]){prop[1] = prop[1] - bounds[1];}

      float r = prob.call(pts_prop) / prob.call(history[history.length - 1]);
      int moved = 0;
      int[] pt = curr;
      if (r >= random(0,1) && noOverlap(prop, history[history.length - 1])) {pt = prop; moved=1;}
      samples = (int[][]) append(samples, pt);
      int[][] hist = new int[n_pts][2];
      arrayCopy(history[history.length - 1], hist);
      hist[ind] = pt;
      history = (int[][][]) append(history, hist);
      println(step, prob.call(hist),"R", r, moved);
    }
  }
  else {
    substep++;
  }
  if (substep == 1){
    if (step > last_sampled_step){
      last_sampled_step++;
      selectedPoint = int(random(0,1) * n_pts);
      selectedPointHistory = append(selectedPointHistory, selectedPoint);
    }
    else {
      selectedPoint = selectedPointHistory[step + 1];
    }
    setProposalTiles();
  }
}

void prev() {
  if(substep > 0){substep--;}
  else if (step > 0) {
    step--;
    substep = 3;
    selectedPoint = selectedPointHistory[step + 1];
    setProposalTiles();
  }
  else{print("No steps to back up");}
}
