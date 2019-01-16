import processing.sound.*;
void setup() {
  fullScreen(P3D);
  sound = new SoundFile(this,"bg.mp3");
  sound.play();
  
  amp = new Amplitude(this);
  fft = new FFT(this);
  amp.input(sound);
  fft.input(sound);
  ffto = new float[512];
  bxs = new float[500][4];
  for(int i=0;i<bxs.length;i++) {
    bxs[i][0] = int(random(-(width/2), width/2));
    bxs[i][0]-= bxs[i][0]%scl;
    bxs[i][1] = 0;
    bxs[i][2] = int(random(-128000,-400));
    bxs[i][2]-= bxs[i][2]%scl;
    bxs[i][3] = int(random(1,20));
  }
  font = createFont("Arial",30);
  textFont(font,20);
  frameRate(100);
}
Amplitude amp;
FFT fft;
SoundFile sound;
float ffto[];
PFont font;
int bg=255;
float bxs[][];
int scl=50;
float ball[] = {0,0,0};
float dir[] = {0,0};
float speed = 2.4;
boolean shoot=false;
int score=0;
int hscore=0;
void restart() {
  if (score > hscore) hscore = score;
  ball[0]=0;
  ball[1]=0;
  ball[2]=0;
  for(int i=0;i<bxs.length;i++) {
    bxs[i][0] = int(random(-(width/2), width/2));
    bxs[i][0]-= bxs[i][0]%scl;
    bxs[i][1] = 0;
    bxs[i][2] = int(random(random(-128000,-8000),-200));
    bxs[i][2]-= bxs[i][2]%scl;
    bxs[i][3] = int(random(1,20));
  }
  shoot = false;
}
void keyPressed() {
  if ((key == 'i') | (key == 'I')) bg=255-bg;
  if ((key == 'r') | (key == 'R')) restart();
}
void mousePressed() {
  if (!shoot) {
    shoot=true;
    dir[0] = -map((mouseX-((width/2))),-(width/2),width/2,-10,10);
    if(dir[0] <0) dir[1]=9+dir[0];
    else dir[1]=9-dir[0];
  }
}
void draw() { 
  fft.analyze(ffto);
  background(bg);
  pushMatrix();
  color tmp=color(
    map(sin(float(frameCount)/50),-1.0,1.0,20,100)+map(amp.analyze(),0.0,1.0,0,155),
    map(cos(float(frameCount)/50),-1.0,1.0,20,100)+map(amp.analyze(),0.0,1.0,0,155),
    map(sin(float(frameCount)/47),-1.0,1.0,20,100)+map(amp.analyze(),0.0,1.0,0,155)
  );
  fill(tmp);
  //text(str(int(ball[0]))+" "+str(width/2),100,100);
  translate(width/2,float(height)/4.6,50);
  rotateY(float(frameCount)/50);
  box(300,100,300);
  fill(255-red(tmp),255-green(tmp),255-blue(tmp));
  text("Score: "+str(score),-70,0,152);
  rotateY(PI/2);
  text("hight Score: "+str(hscore),-70,0,152);
  rotateY(PI/2);
  text("Press 'R' to restart.\nPress 'I' to invert\ncolor.",-70,-30,152);
  rotateY(PI/2);
  textFont(font,30);
  text("Royal balz\n  3D",-80,0,152);
  textFont(font,20);
  popMatrix();
  translate((width/2)+ball[0],height/2,ball[2]);
  //rotateY(map(dir[0],-8,8,-TWO_PI,TWO_PI));
  
  for(int i=-200;i>-28000;i-=50) {
    pushMatrix();
    translate(width/2,0,i);
    //println(noise(float((i/50)+frameCount)/120));
    int th=int(map(ffto[(((i*-1)-200)/50)%ffto.length],0.0,1.0,0,3200))+50;
    println(th);
    //int(map(noise(float((i/50)+frameCount)/12),0,1.0,100,200));
    fill(map(th,100,200,0,255)-100);
    stroke(255-(map(th,100,200,0,255)-100));
    box(50,th,50);
    popMatrix();
    pushMatrix();
    translate(-width/2,0,i);
    box(50,th,50);
    popMatrix();
  }
  stroke(bg);
  for (int i=0;i<bxs.length;i++) {
    if (bxs[i][3] != 0) {
      pushMatrix();
      if (shoot & ((bxs[i][2]+ball[2] >= (height-180)) & (bxs[i][2]+ball[2] <=(height-180)+(scl/2)))) {
        fill(255-bg,bg,bg);
        if ((bxs[i][0]+ball[0] >= -(scl/1)) & (bxs[i][0]+ball[0] <=scl/1)) {
          fill(bg,255-bg,255-bg);
          dir[1]*=-1;
          ball[2]+=dir[1];
          bxs[i][3]--;
          score++;
        }
      }
      else
        fill(map(bxs[i][3]%20,0,20,100,255),map(bxs[i][3]%18,0,18,120,255),255-bg);
      translate(bxs[i][0],bxs[i][1],bxs[i][2]);
      box(scl);
      fill(bg);
      text(int(bxs[i][3]),-(scl/10),scl/3,scl/2);
      pushMatrix();
      rotateY(HALF_PI);
      text(int(bxs[i][3]),-(scl/10),scl/3,scl/2);
      rotateY(HALF_PI);
      text(int(bxs[i][3]),-(scl/10),scl/3,scl/2);
      rotateY(HALF_PI);
      text(int(bxs[i][3]),-(scl/10),scl/3,scl/2);
      popMatrix();
      popMatrix();
      if(bxs[i][2]>=10){
        restart();
      }
    }
  }
  pushMatrix();
  translate(-300,scl/2,100);
  fill(255-bg,255-bg,bg);
  box((width/2)+600,10,250);
  popMatrix();
  if (shoot) {
    ball[0]+=dir[0]*speed;
    ball[2]+=dir[1]*speed;
    if ((ball[0]>(width/2)-(scl)) | (ball[0]<-((width/2)-(scl)))) dir[0]*=-1;
    if (ball[2]<-scl) {
      shoot=false;
      for(int i=0;i<bxs.length;i++) bxs[i][2]+=scl*2;
    }
  }else{
    stroke(255-bg);
    line(-ball[0],100,-ball[2],map(mouseX,0,width,-width,width)-ball[0],mouseY/10,-mouseY-ball[2]);
    stroke(bg);
 }
}
