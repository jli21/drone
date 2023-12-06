// Aero Dash Game Sketch

class Drone {
  float x, y;
  float speed = 2;

  Drone(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    fill(255);
    rect(x, y, 20, 20); // The drone is represented as a square for now
  }

  void move() {
    y += (mouseY - y) * 0.1; // Move the drone towards the mouse's Y position
    // Keep the drone within the game window
    y = constrain(y, 0, height - 20);
  }
}

class Obstacle {
  float x, y, w, h;
  float speed;

  Obstacle(float x, float y, float w, float h, float speed) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.speed = speed;
  }

  void display() {
    fill(255, 0, 0);
    rect(x, y, w, h);
  }

  void update() {
    x -= speed;
    if (x < -w) {
      // Reset the obstacle to a new position after it moves off screen
      x = width;
      y = random(height - h);
    }
  }
}

Drone drone;
Obstacle obstacle;

void setup() {
  size(800, 600);
  drone = new Drone(100, height/2);
  obstacle = new Obstacle(width, height/2, 30, 80, 5);
}

void draw() {
  background(0);
  drone.move();
  drone.display();

  obstacle.update();
  obstacle.display();
}

void mousePressed() {
  // Restart the game when the mouse is pressed (for demonstration purposes)
  obstacle = new Obstacle(width, height/2, 30, 80, 5);
}
