/**
* Program to play a game where a rolling sphere is on a plate and has to eliminate all cylinders
*
* @arg plateSize the size of the plate
* @arg depth the depth from where we can see the plate
* @arg wheelingSpeed the speed at which the plate can be tilted
* 
* @arg rx, rx both floats
* @arg gravityForce a PVector in 3D
* @arg boolean drawing to know if we are in draw mode
* @arg movers an object of type Movers instancing all the moving objects on the plate
*/


final float plateSize = 600;

float depth = 1000;
float wheelingSpeed = 0.002;

void settings() {
  size(1000, 1000, P3D);
}

void setup() {
  noStroke();
  movers = new Movers();
  gravityForce = new PVector(0, 0, 0);
}

float rx;
float rz;
PVector gravityForce;
boolean drawing;

Movers movers;

/** @brief methode to draw the elements on the screen
*/
void draw() {
  camera(0, 0, depth, 0, 0, 0, 0, -1, 0);
  directionalLight(50, 100, 125, 0, -1, -1);
  ambientLight(102, 102, 102);
  background(200);
  //ps.run();

  if (drawing) {
    rotateX(PI/2);
  } else {
    rotateX(PI/12);
    rotateX(rx);
    rotateZ(rz);
  }

  pushMatrix();
  noStroke();
  fill(100);
  box(plateSize, 20, plateSize);
  popMatrix();

  if (!drawing)
    updateGrav();
    
  if (!drawing)
    movers.updateMovers();

  movers.displayMovers();
  
}

/** @brief updates the gravity force 
*/
void updateGrav() {
  gravityForce.x = -sin(rz);
  gravityForce.z = sin(rx);
}


/** @brief manages actions when different keys are pressed
*/
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    } else if (keyCode == DOWN) {
      depth += 50;
    }
    if (keyCode == SHIFT)
      drawing = true;
  }
}

/** @brief manages actions when keys are released
*/
void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT)
      drawing = false;
  }
}

/** @brief adds cylinders when the mouse is clicked
*/
void mouseClicked() {
  if (drawing) {
    movers. cylinders.clear();;
    int x = -(mouseX-width/2);
    int y = (mouseY-height/2);
    movers.addFirstCylinder(x,y);
    
  }
}

/** @brief reacts to the mouse being dragged and modifies the orientation of the plate
*/
void mouseDragged() {
  if (drawing)
    return;
  float deltaY = mouseY - pmouseY;
  rx += (deltaY * wheelingSpeed);
  if (rx > PI/6)
    rx = PI/6;
  if (rx < - PI/6)
    rx = - PI/6;


  float deltaX = mouseX - pmouseX;
  rz += (deltaX * wheelingSpeed);
  if (rz > PI/6)
    rz = PI/6;
  if (rz < - PI/6)
    rz = - PI/6;
}

/** @brief reacts to the mouse wheel to change the speed of the dragging
*/
void mouseWheel(MouseEvent event) {
  wheelingSpeed -= event.getCount() * 0.0005;
  if (wheelingSpeed < 0.0005)
    wheelingSpeed = 0.0005;
  if (wheelingSpeed > 0.005)
    wheelingSpeed = 0.005;
}
