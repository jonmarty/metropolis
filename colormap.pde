class ColorMap {
  ColorMap(){}
  float[] call(float val){
    float[] out = new float[3];
    return out;
  }
}

class Gray extends ColorMap {
  Gray(){
    super();
  }
  float[] call(float val){
    float[] out = new float[3];
    out[0] = 155 * val + 100;
    out[1] = 155 * val + 100;
    out[2] = 155 * val + 100;
    return out;
  }
}

class Red extends ColorMap {
  Red(){
    super();
  }
  float[] call(float val){
    float[] out = new float[3];
    out[0] = 155*val + 100;
    out[1] = 100;
    out[2] = 100;
    return out;
  }
}

class CustomColorMap extends ColorMap {
  float[] base, target, diff;
  CustomColorMap(float[] baseColor, float[] targetColor){
    super();
    base = baseColor;
    target = targetColor;
    diff = new float[3];
    diff[0] = target[0] - base[0];
    diff[1] = target[1] - base[1];
    diff[2] = target[2] - base[2];
  }
  float[] call(float val){
    float[] out = new float[3];
    out[0] = base[0] + diff[0] * val;
    out[1] = base[1] + diff[1] * val;
    out[2] = base[2] + diff[2] * val;
    return out;
  }
}

class MultiCustomColorMap extends ColorMap {
  float[][] targets;
  float[][] diffs;
  float[] breaks;
  MultiCustomColorMap(float[][]targetColors){
    targets = targetColors;
    diffs = new float[targets.length - 1][3];
    for (int i = 0; i < diffs.length; i++){
      diffs[i][0] = targets[i+1][0] - targets[i][0];
      diffs[i][1] = targets[i+1][1] - targets[i][1];
      diffs[i][2] = targets[i+1][2] - targets[i][2];
      breaks[i] = i / (targets.length - 1);
    }
  }
  float[] call(float val){
    int cm = 0;
    for (int i = 0; i < diffs.length; i++){
      if (breaks[i] >= val){
        cm = i;
        break;
      }
    }
    float[] out = new float[3];
    float val_ = (val - breaks[cm]) * (targets.length - 1);
    out[0] = targets[cm][0] + diffs[cm][0] * val_;
    out[1] = targets[cm][1] + diffs[cm][1] * val_;
    out[2] = targets[cm][2] + diffs[cm][2] * val_;
    return out;
  }
}
