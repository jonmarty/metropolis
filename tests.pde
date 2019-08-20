void runMCMCTests(){
  //First -- must test all the code
  println("Test 1: Uniform distribution check");
  Uniform uniform = new Uniform(0,10);
  println("Samples");
  for(int i=0;i<10;i++){
    println(uniform.sample());
  }
  println("Prob from -5 to 15");
  for(int i=-5;i<16;i++){
    println(uniform.prob(i));
  }
  
  println("Test 2: Two Dimensional Uniform distribution check");
  TwoDimDistribution twodim = new TwoDimDistribution(uniform, uniform);
  println("Samples");
  for(int i=0;i<10;i++){
    println(twodim.sample());
  }
  println("Prob of -5,0,5,10,15 in x and y");
  for(int i=-5;i<16;i+=5){
    for(int j=-5;j<16;j+=5){
      int[] vect = {i,j};
      println(i,j,twodim.prob(vect));
    }
  }
  
  println("Test 3: Metropolis Proposal check");
  MetropolisProposal metropolis = new MetropolisProposal(10);
  println("3 samples from point (13,13)");
  int[] vect = {13,13};
  for(int i=0;i<3;i++){
    println(metropolis.sample(vect));
  }
  println("Probabilities of [13,14], [13,28], and [14,14] from [13,13]");
  int[][] vects = {{13,13},{13,14},{13,28}, {14,14}};
  println(metropolis.prob(vects[0],vects[1]));
  println(metropolis.prob(vects[0],vects[2]));
  println(metropolis.prob(vects[0],vects[3]));
  
  println("Test 4: Gen Data");
  genData();
  println();
  
  println("Test 5: NEXT & PREV");
  println("1st next");
  next();
  println(step, substep);
  printArray(history[step]);
  println("2nd next");
  next();
  println(step, substep);
  printArray(history[step]);
  println("3rd next");
  next();
  println(step, substep);
  printArray(history[step]);
  println("4th next");
  next();
  println(step, substep);
  printArray(history[step]);
  println("1st prev");
  prev();
  println(step, substep);
  printArray(history[step]);
  println("2nd prev");
  prev();
  println(step, substep);
  printArray(history[step]);
  println("next after prev");
  next();
  println(step, substep);
  printArray(history[step]);
}
