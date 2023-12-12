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
        rect(x, y, -drone_width, -drone_height);
        
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
        translate(x, y); 
        rotate(rotor_angle); 
        
        stroke(50); 
        strokeWeight(1); 
        for (int i = 0; i < 20; i++) {
            float angle = radians(360 / 20 * i);
            float x_end = cos(angle) * rotor_length;
            float y_end = sin(angle) * rotor_length;
            line(0, 0, x_end, y_end);
        }
        
        popMatrix();
    }
    

    void move() {
        if (keyPressed) {
            if (keyCode == UP) {
                y -= vertical_speed;
            } else if (keyCode == DOWN) {
                y += vertical_speed;
            }
        }
        // Keeps the drone from moving outside the game window
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
    abstract String getDescription();

    void update() {
        x -= speed; // common behavior of all obstacles
    }
}

// Wall subclass
class Laser extends Obstacle {
    float length;

    Laser(float x, float y, float length, float speed) {
        super(x, y, speed);
        this.length = length;
    }

    void display() {
        stroke(255, 0, 0);
        strokeWeight(2); 
        line(x, y, x, y + length); 
        
        fill(0);
        noStroke();
        rect(x - 5, y - 5, 10, 10); 
        rect(x - 5, y - 5 + length, 10, 10); 
    }

    @Override
    String getDescription() {
        // Returns in console the collision information
        return "Laser - Length: " + length + ", Speed: " + speed;
    }
}

// Wall Subclass
class Wall extends Obstacle {
    float wall_width, wall_height;

    Wall(float x, float wall_width, float wall_height, float speed) {
        super(x, 0, speed); 
        this.wall_width = wall_width;
        this.wall_height = wall_height;
        this.y = random(1) < 0.5 ? 0 : height - wall_height;
    }

    void display() {
        fill(0);
        noStroke();
        rect(x, y, wall_width, wall_height);
    }

    @Override
    String getDescription() {
        return "Wall - Width: " + wall_width + ", Height: " + wall_height;
    }
}


// Global variables and functions
boolean isHomeScreen = true;
float startTime;
float bestTime = 0;
Drone drone;
ArrayList<Obstacle> obstacles;
int next_obstacle_frame = 0;

void setup() {
    size(800, 600);
    drone = new Drone(100, height / 2);
    obstacles = new ArrayList<Obstacle>();
    setNextObstacleFrame();
}

void draw() {
    if (isHomeScreen) {
        drawHomeScreen();
    } else {
        resetDrawingState(); 
        background(255);
        drone.move();
        drone.display();
        updateTimer();
        
        // check if it is time to add a new obstacke
        if (frameCount >= next_obstacle_frame) {
            addObstacle();
            setNextObstacleFrame();
        }

        updateObstacles();
        checkCollisions();
    }
}

void drawHomeScreen() {
    background(200);
    textSize(48);
    textAlign(CENTER, CENTER);
    fill(0);
    text("Drone Game", width / 2, height / 3);

    fill(100);
    rectMode(CENTER);
    rect(width / 2, height / 2, 200, 60);

    textSize(32);
    fill(255);
    text("Start Game", width / 2, height / 2);

    textSize(24);
    text("Best Time: " + nf(bestTime, 0, 2) + " seconds", width / 2, height / 2 + 100);
}

void resetDrawingState() {
    // Resets the modes initiated by the drawHomeScreen to not interfere with program
    rectMode(CORNER);
    textAlign(LEFT, TOP);
    textSize(12);
}


void mousePressed() {
  if (isHomeScreen && mouseX > width / 2 - 100 && mouseX < width / 2 + 100 && mouseY > height / 2 - 30 && mouseY < height / 2 + 30) {
    // Check if the 'Start Game' button is clicked
    isHomeScreen = false; 
    startGame(); 
  }
}

void startGame() {
    // Initialize or reset game-specific variables and states

    drone = new Drone(100, height / 2);
    obstacles.clear();
    setNextObstacleFrame();
    startTimer();
}

void startTimer() {
    startTime = millis();
}

void updateTimer() {
    // Method that displays the hundredth of a second "score"
    float elapsed = (millis() - startTime) / 10.0;
    float seconds = elapsed / 100;
    String formattedTime = String.format("%.2f", seconds);
    text("Time: " + formattedTime, width - 100, 20);
}

void setNextObstacleFrame() {
    // Randomly determine the next obstacle appearance (in frames)
    int interval_frames = int(random(60, 120));
    next_obstacle_frame = frameCount + interval_frames;
}

void addObstacle() {
    float obstacleX = width;
    float wall_width = 20;
    float wall_height = random(250, 500);
    float speed = 5;

    if (random(1) < 0.5) {
        float maxLaserLength = height - 200;
        float laser_length = random(200, min(400, maxLaserLength));
        float obstacleY = random(100, height - 100 - laser_length);
        obstacles.add(new Laser(obstacleX, obstacleY, laser_length, speed));
    } else {
        obstacles.add(new Wall(obstacleX, wall_width, wall_height, speed));
    }
}

void reset_game() {
    float sessionTime = (millis() - startTime) / 1000.0; 
    if (sessionTime > bestTime) {
        bestTime = sessionTime; 
    }
    // Reset drone position
    startTimer();
    drone = new Drone(100, height / 2);

    // Clear all obstacles
    obstacles.clear();

    // Reset the frame count for the next obstacle
    setNextObstacleFrame();
    isHomeScreen = true;


}

void updateObstacles() {
  for (Obstacle o : obstacles) {
    o.update();
    o.display();
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
            obstacle_width = 10;
            obstacle_height = laser.length;
        } else if (obstacle instanceof Wall) {
            Wall wall = (Wall) obstacle;
            obstacle_x = wall.x;
            obstacle_y = wall.y;
            obstacle_width = wall.wall_width;
            obstacle_height = wall.wall_height;
        } else {
            continue;
        }

        if (checkIntersection(drone.x, drone.y, drone.drone_width, drone.drone_height, obstacle_x, obstacle_y, obstacle_width, obstacle_height)) {
            println("Collision with: " + obstacle.getDescription());
            reset_game();
            return;
        }
    }
}
