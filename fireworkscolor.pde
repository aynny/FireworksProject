// グローバル変数としてのFireworkクラス
ArrayList<Firework> fireworks;
float interval = 2000;
float lastFireworkTime = 0;

void setup() {
  size(1000, 700);
  background(0, 0, 20);
  fireworks = new ArrayList<Firework>();
}

void draw() {
  background(10, 10, 30);
  festival();

  if (millis() - lastFireworkTime >= interval) {
    lastFireworkTime = millis();
    fireworks.add(new Firework(random(width), height + random(200, 400)));
  }

  for (int i = 0; i < fireworks.size(); i++) {
    fireworks.get(i).update();
  }
}

void festival() {
  for (int i = fireworks.size() - 1; i >= 0; i--) {
    if (fireworks.get(i).t > 400) {
      fireworks.remove(i);
    }
  }
}

void mousePressed() {
  fireworks.add(new Firework(mouseX, height + random(200, 400)));
}

class Firework {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float t;
  color fireworkColor;
  boolean explode;
  PVector expL;
  float etime;
  boolean preExplode;
  float fade;
  float g;

  ArrayList<PVector> oldL;
  ArrayList<Particle> expPar;
  ArrayList<Particle> par;

  Firework(float xpos, float ypos) {
    location = new PVector(xpos, ypos);
    velocity = new PVector(random(-0.8, 0.8), -5);
    g = 0.02;
    acceleration = new PVector(0, g);
    t = 0;
    float r = random(255);
    float g = random(255);
    float b = random(255);
    fireworkColor = color(r, g, b);
    oldL = new ArrayList<PVector>();
    oldL.add(new PVector(xpos, ypos));
    explode = false;
    preExplode = false;
    fade = 0;
    etime = 0;
    expL = new PVector(xpos, ypos);
    expPar = new ArrayList<Particle>();
    par = new ArrayList<Particle>();
  }

  void update() {
    preExplodeFade();
    system();
    display();
    explotion();
  }

  void system() {
    PVector f = new PVector(0, -0.02);
    velocity.add(acceleration);
    location.add(velocity);

    if (t < 30) {
      applyForce(f);
      location.x += sin(radians(t * 30)) / 4.0;
    } else if (t < 120) {
      location.x += sin(radians(t * 25)) / 4.0;
    } else if (t < 220) {
      location.x += sin(radians(t * 15)) / 4.0;
      preExplode = true;
    } else if (t > 250) {
      explode = true;
    }
    if (t < 300) {
      t++;
    }
    if (oldL.size() < 160) {
      oldL.add(new PVector(location.x, location.y));
    }
    if (fade > 253) {
      for (int i = 0; i < oldL.size(); i++) {
        oldL.remove(i);
      }
    }
  }

  void preExplodeFade() {
    if (preExplode) {
      if (fade < 255) {
        fade += 1.8;
      }
    }
  }

  void explotion() {
    int expN = 14;
    float parN = 12.0;
    if (explode) {
      if (etime == 0) {
        expL = new PVector(location.x, location.y);
        for (int i = 0; i < expN; i++) {
          Particle p = new Particle(random(expL.x - 5, expL.x + 5), random(expL.y - 5, expL.y + 5), random(-0.5, 0.5), random(-0.5, 0.5));
          p.setColor(red(fireworkColor), green(fireworkColor), blue(fireworkColor), alpha(fireworkColor));
          p.size = random(5, 10);
          expPar.add(p);
        }
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < parN * (i + 1); j++) {
            Particle p = new Particle(expL.x, expL.y, random(i * sin(i / 8.0) + 0.3, i * sin(i / 8.0) + 0.9) * cos(radians(j * 360.0 / parN / (i + 1))) / 1.0,
                random(i * sin(i / 8.0) + 0.3, i * sin(i / 8.0) + 0.9) * sin(radians(j * 360.0 / parN / (i + 1))) / 1.0);
            p.setG(0.0025);
            p.setColor(red(fireworkColor), green(fireworkColor), blue(fireworkColor), alpha(fireworkColor));
            p.isOrbit = true;
            par.add(p);
          }
        }
      }
      etime++;
      if (etime < 50) {
        for (Particle p : expPar) {
          p.update();
          p.display();
          p.subAlpha(etime);
        }
      }
      if (etime > 2) {
        for (Particle p : par) {
          p.update();
          p.airResistance();
          p.displayOrbit();
        }
      }
    }
  }

  void applyForce(PVector f) {
    velocity.add(f);
  }

  void display() {
    noStroke();

    for (float i = 1.1; i < oldL.size() - 1; i++) {
      PVector old = oldL.get((int) i);
      fill(fireworkColor, 255.0 * i / oldL.size() - fade);
      ellipse(old.x, old.y, 3.0 + 2.0 * sin(i / oldL.size()), 3.0 + 2.0 * sin(i / oldL.size()));
    }
  }
}

class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float size;
  color thisC;
  float t;
  color particleColor;
  float R, G, B, alpha;
  boolean isOrbit;
  float fade;
  ArrayList<PVector> orbit;
  float air;

  Particle(float xpos, float ypos, float xsp, float ysp) {
    location = new PVector(xpos, ypos);
    velocity = new PVector(xsp, ysp);
    acceleration = new PVector(0, 0.001);
    size = 2.0;
    R = 255;
    G = 255;
    B = 255;
    alpha = 255;
    thisC = color(255, 255, 255);
    t = 0;
    particleColor = color(random(255), random(255), random(255));
    orbit = new ArrayList<PVector>();
    orbit.add(new PVector(xpos, ypos));
    isOrbit = false;
    fade = 0.0;
    air = 0.99;
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    t++;
    if (isOrbit) {
      if (t < 500) {
        orbit.add(new PVector(location.x, location.y));
      }
      if (orbit.size() > 100) {
        orbit.remove(0);
      }
    }
    if (t > 100) {
      if (fade < 260) {
        fade += 3;
      }
    }
    if (fade > 255) {
      for (int i = 0; i < orbit.size(); i++) {
        orbit.remove(i);
      }
    }
  }

  void airResistance() {
    velocity.mult(air);
  }

  void applyForce(PVector f) {
    velocity.add(f);
  }

  void setG(float sg) {
    acceleration = new PVector(0, sg);
  }

  void setColor(float sR, float sG, float sB, float sA) {
    R = sR;
    G = sG;
    B = sB;
    alpha = sA;
    thisC = color(R, G, B, alpha);
  }

  void subAlpha(float A) {
    alpha -= A;
    thisC = color(R, G, B, alpha);
  }

  void display() {
    fill(thisC);
    ellipse(location.x, location.y, size, size);
  }

  void displayOrbit() {
    fill(R, G, B, alpha - fade);
    for (float i = 1.0; i < orbit.size() + 1; i++) {
      PVector pos = orbit.get((int) i - 1);
      ellipse(pos.x, pos.y, size * i / orbit.size(), size * i / orbit.size());
    }
  }
}
