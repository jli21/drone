class Drone {
  float x, y; 
  float drone_width = 60;
  float drone_height = 30;
  float rotor_length = 20; 
  float rotor_distance = 8;
  float vertical_speed = 10;
  float rotor_angle = 0; 
  
  Drone(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    // Central body of the drone
    fill(120);
    rect(x, y, - drone_width, - drone_height);
    
    stroke(50);
    strokeWeight(3);
    // Rotors on the drone
    
    line(x, y, x + rotor_distance, y + rotor_distance); 
    line(x, y - drone_height, x + rotor_distance, y - drone_height - rotor_distance); 
    line(x - drone_width, y, x - drone_width - rotor_distance, y + rotor_distance); 
    line(x - drone_width, y - drone_height, x - drone_width - rotor_distance, y - drone_height - rotor_distance); 

    draw_rotating_rotor(x + rotor_distance, y + rotor_distance);  
    draw_rotating_rotor(x + rotor_distance, y - drone_height - rotor_distance); 
    draw_rotating_rotor(x - drone_width - rotor_distance, y + rotor_distance);
    draw_rotating_rotor(x - drone_width - rotor_distance, y - drone_height - rotor_distance);

    // Increment the angle for the next frame
    rotor_angle += 0.5;
  }

  void draw_rotating_rotor(float x, float y) {
    pushMatrix(); 
    // Save the current state of the matrix
    translate(x, y); 
    rotate(rotor_angle); 
    
    // Draw the rotor lines
    stroke(50); 
    strokeWeight(1); 
    for (int i = 0; i < 20; i++) {
      float angle = radians(360 / 20 * i);
      float x_end = cos(angle) * rotor_length;
      float y_end = sin(angle) * rotor_length;
      line(0, 0, x_end, y_end);
    }
    
    popMatrix(); // Restore the original state of the matrix
  }

  void move() {
    if (keyPressed) {
      if (keyCode == UP) {
        y -= vertical_speed;
      } else if (keyCode == DOWN) {
        y += vertical_speed;
      }
    }
    // Keep the drone within the game window
    y = constrain(y, 0, height - 20);
  }
}

abstract class Obstacle {
  float x, y, speed;
  
  Obstacle(float x, float y, float speed) {
    this.x = x;
    this.y = y;
    this.speed = speed;
  }

  abstract void display();

  void update() {
    x -= speed; // common update behavior for all obstacles
  }
}

class Laser extends Obstacle {
  float length;

  Laser(float x, float y, float length, float speed) {
    super(x, y, speed);
    this.length = length;
  }

  void display() {
    stroke(255, 0, 0); // Red color for the laser
    strokeWeight(2); 
    line(x, y, x, y + length); 
    
    fill(0); // Nodes
    noStroke();
    rect(x - 5, y - 5, 10, 10); 
    rect(x - 5, y - 5 + length, 10, 10); 
  }
}

class Wall extends Obstacle {
  float wall_width, wall_height;

  Wall(float x, float wall_width, float wall_height, float speed) {
    super(x, 0, speed); 
    this.wall_width = wall_width;
    this.wall_height = wall_height;

    if (random(1) < 0.5) {
      this.y = 0; // Top
    } else {
      this.y = height - wall_height; // Bottom
    }
  }

  void display() {
    fill(0); // Black color for the wall
    noStroke();
    rect(x, y, wall_width, wall_height); // Draw the wall
  }
}

boolean checkIntersection(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
    return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
}

void checkCollisions() {
    for (Obstacle obstacle : obstacles) {
        float obstacle_x, obstacle_y, obstacle_width, obstacle_height;

        if (obstacle instanceof Laser) {
            Laser laser = (Laser) obstacle;
            obstacle_x = laser.x;
            obstacle_y = laser.y;
            obstacle_width = 10; // Assuming the width of the laser is 10
            obstacle_height = laser.length;
        } else if (obstacle instanceof Wall) {
            Wall wall = (Wall) obstacle;
            obstacle_x = wall.x;
            obstacle_y = wall.y;
            obstacle_width = wall.wall_width;
            obstacle_height = wall.wall_height;
        } else {
            continue; // Skip if the obstacle is of an unknown type
        }

        // Check for intersection
        if (checkIntersection(drone.x, drone.y, drone.drone_width, drone.drone_height, obstacle_x, obstacle_y, obstacle_width, obstacle_height)) {
            reset_game();
            return;
        }
    }
}


ArrayList<Obstacle> obstacles;
Drone drone;

int next_obstacle_frame = 0; // Frame count for the next obstacle

void setup() {
  size(800, 600);
  drone = new Drone(100, height / 2);
  obstacles = new ArrayList<Obstacle>();
  setNextObstacleFrame(); // Initialize the first target frame count
}

void draw() {
  background(255);
  drone.move();
  drone.display();

  if (frameCount >= next_obstacle_frame) { // Check if it's time to add a new obstacle
    addObstacle();
    setNextObstacleFrame(); // Set the next target frame count
  }

  updateObstacles();
  checkCollisions(); // Function to check for collisions (to be implemented)
}

void setNextObstacleFrame() {
  int interval_frames = int(random(60, 120)); // Random frame count between 60 to 120 frames
  next_obstacle_frame = frameCount + interval_frames; // Set the next target frame count
}

void addObstacle() {
  float obstacleX = width;
  float wall_width = 20; // Set width for walls
  float wall_height = random(250, 500); // Random height for walls
  float speed = 5; // Speed for obstacles

  if (random(1) < 0.5) {
    float maxLaserLength = height - 200; // Maximum length to fit within screen
    float laser_length = random(200, min(400, maxLaserLength)); // Random length for lasers
    float obstacleY = random(100, height - 100 - laser_length); // Y-coordinate for the laser

    obstacles.add(new Laser(obstacleX, obstacleY, laser_length, speed));
  } else {
    obstacles.add(new Wall(obstacleX, wall_width, wall_height, speed));
  }
}

void reset_game() {
    // Reset drone position
    drone = new Drone(100, height / 2);

    // Clear all obstacles
    obstacles.clear();

    // Reset the frame count for the next obstacle
    setNextObstacleFrame();
}

void updateObstacles() {
  for (Obstacle o : obstacles) {
    o.update();
    o.display();
  }
}
