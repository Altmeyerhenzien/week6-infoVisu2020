/**
* class Sphere representing a solid spheric ball that can roll
* @arg location its location on the plate
* @arg velocity its velocity, a PVector in 3D
* @arg friction
* @arg radius the radius of the sphere
*/

class Sphere {
  PVector location;
  PVector velocity;

  PVector friction;
  float radius;
  
  Sphere(float radius) {
    location = new PVector(0, 40, 0);
    velocity = new PVector(0, 0, 0);
    friction = new PVector(0, 0, 0);
    this.radius = radius;
  }

/** @brief to update the velocity, location and friction of the sphere
 * @param plateSize the size of the plate
*/
  void update(float plateSize) {
    updateFrict();
    velocity.add(gravityForce);
    velocity.add(friction);
    location.add(velocity);
    
    checkEdges(plateSize);
  }

/** @brief to update the friction
*/
  void updateFrict() {
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
  }

/** @brief displays the sphere at the right place
*/
  void display() {
    fill(123);
    translate(location.x, location.y, location.z);
    sphere(radius);
  }

/** @brief to know if the sphere is at the end of the plate and prevent it from going further
 * @param plateSize the size of the plate
*/
  void checkEdges(float plateSize) {
    if (location.x - radius < - plateSize/2) {
      velocity.x *= -0.66; 
      location.x = - plateSize/2 + radius; 
    }
      
    if (location.x + radius > plateSize/2) {
      velocity.x *= -0.66;
      location.x = plateSize/2 - radius; 
    }
      
    if (location.z - radius < - plateSize/2) {
      velocity.z *= -0.66;
      location.z = - plateSize/2 + radius; 
    }
      
      
    if (location.z + radius > plateSize/2) {
      velocity.z *= -0.66;
      location.z = plateSize/2 - radius; 
    }

  }
}
