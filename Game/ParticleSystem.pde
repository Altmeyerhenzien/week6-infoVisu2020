/** class ParticleSystem: a class to describe a group of Particles
* @arg cylinders the array of position of centers of cylinders
* @arg origin the center of the first cylinder which is the origin of the Particle System
* @arg cylinderRadius the radius of a cylinder
* @arg sphere the moving sphere
* @arg villain posted on top of the origin cylinder
*
* @arg freq the frequence of appearance of the cylinders
* @arg counter to count the time according to the frequence
* @arg currTime
* @arg currAngle 
*
*/
class ParticleSystem {
  ArrayList<PVector> cylinders;
  PVector origin;
  float cylinderRadius = Cylinder.cylinderBaseSize;
  Sphere sphere;
  Villain villain;

  final float freq = 5;
  float counter;
  float currTime;
  
  float currAngle;


  ParticleSystem(ArrayList<PVector> cylinders, PVector origin, Sphere sphere) {
    this.origin = origin.copy();
    this.cylinders = cylinders;
    this.sphere = sphere;
    counter = freq;
    currTime = millis() / 1000f;
    cylinders.add(origin);
    
    currAngle = calcAngle();
    
    villain = new Villain();
    villain.shape.rotateY(currAngle + PI);
    
  }

/** @brief tries to add a cylinder considering n attempts right next to an already created cylinder
*/
  void addCylinder() {
    PVector center;
    int numAttempts = 100;
    for (int i=0; i<numAttempts; i++) {

      // Pick a cylinder and its center.
      int index = int(random(cylinders.size()));
      center = cylinders.get(index).copy();
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2*cylinderRadius;
      center.y += cos(angle) * 2*cylinderRadius;
      if (checkPosition(center)) {
        cylinders.add(center);
        break;
      }
    }
  }


/** @brief Check if a position is available, i.e.
 *   - would not overlap with particles that are already created
 *   (for each particle, call checkOverlap())
 *   - is inside the board boundaries       
 *
 * @param center of type PVector, the center of the cylinder we want to check positions for
 * @return boolean if their is an overlapping between two objects
 *
*/
  boolean checkPosition(PVector center) {
    for (PVector cylinderCenter : cylinders) {
      if (!checkOverlap(center, cylinderCenter))
        return false;
    }
   
    return checkOverlap(center, sphere.location) && Math.abs(center.x) <= plateSize/2 && Math.abs(center.y) <= plateSize/2;
  }


  
/** @brief Check if a particle with center c1 and another particle with center c2 overlap.
 * @param c1, c2 of type PVector
 * @return boolean true if overlap, false if not
*/
  boolean checkOverlap(PVector c1, PVector c2) {
    return Math.sqrt((c1.x - c2.x) * (c1.x - c2.x) + (c1.y - c2.y) * (c1.y - c2.y)) > 2 * cylinderRadius;
  }




/** @brief Iteratively update and display every particle
*/
  void run() {
    float newTime = millis() / 1000f;
    float deltaTime = newTime - currTime;
    currTime = newTime;
    counter -= deltaTime;
    if (counter <= 0) {
      addCylinder();
      counter = freq;
    }
    //put it in the origin cylinder
    
    float newAngle = calcAngle();
    float deltaAngle = newAngle - currAngle;
    pushMatrix();
    villain.shape.rotateY(deltaAngle);
    villain.draw(origin);
    popMatrix();
    currAngle = newAngle;
  }
  
/** @brief method to calculate the angle of the new position between the original cylinder and the sphere
 * @return float the angle
*/
  float calcAngle() {
    float angle = (float) Math.atan((origin.x - sphere.location.x)/ (origin.y - sphere.location.z));
     return sphere.location.z > origin.y ? angle + (float)PI : angle; 
  }
}
