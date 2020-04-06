/** class Mover: represents any movable or moving objecs such as objects of type
* Cylinder, ParticleSystem and Sphere
* 
* @arg cylinders ArrayList of PVector that contain the coordinates of all the cylinders added to the game
* @arg sphere the rolling sphere
* @arg ps the particle system 
*/


public class Movers {

  ArrayList<PVector> cylinders; 
  Sphere sphere;
  ParticleSystem ps;

  Movers() {
    sphere = new Sphere(30);
    cylinders = new ArrayList();
  }

/** @brief displays the sphere and the cylinders
*/
  private void displayMovers() {
    if (drawing) {
      pushMatrix();
      float x = -(mouseX - width/2);
      float y = mouseY - height/2;
      PVector coords = clampToPlate(x, y);
      new Cylinder(new PVector(coords.x, 100, coords.y)).shapeCylinder();
      popMatrix();
    }

    for (PVector coord : cylinders) {
      pushMatrix();
      fill(255);
      new Cylinder(new PVector(coord.x, 100, coord.y)).shapeCylinder();
      popMatrix();
    }


    sphere.display();
  }

/** @brief updates the position of the sphere and the ps
*/
  private void updateMovers() {
    checkCylinderCollision();
    pushMatrix();
    sphere.update(plateSize);
    popMatrix();

    if (!cylinders.isEmpty()) {
      ps.run();
    }
  }

/** @brief adds the first cylinder as the origin of the ps
* @param float x, y the position where the cylinder will be added
*/
 private void addFirstCylinder(float x, float y) {
    PVector coords = clampToPlate(x, y);

    ps = new ParticleSystem(cylinders, coords, sphere);
  }


/** @brief 
*/
  private PVector clampToPlate(float x, float y) {
    float newX = x;
    float newY = y;
    if (newX - Cylinder.cylinderBaseSize <= -plateSize/2)
      newX = - plateSize/2 + Cylinder.cylinderBaseSize;
    else if (newX + Cylinder.cylinderBaseSize >= plateSize/2)
      newX = plateSize/2 - Cylinder.cylinderBaseSize;

    if (newY - Cylinder.cylinderBaseSize <= - plateSize/2)
      newY = -plateSize/2 + Cylinder.cylinderBaseSize;
    else if (newY + Cylinder.cylinderBaseSize >= plateSize/2)
      newY = plateSize/2 - Cylinder.cylinderBaseSize;

    return new PVector(newX, newY);
  }

/** @brief checks if there is any collision between the sphere and the cylinders and changes the velocity and location of the sphere if there is
*/
 private void checkCylinderCollision() {
    float x = sphere.location.x;
    float z = sphere.location.z;
    int toRemove = Integer.MAX_VALUE;
    for (PVector v : cylinders) {
      if (Math.sqrt((x - v.x) * (x - v.x) + (z - v.y) * (z - v.y)) <= Cylinder.cylinderBaseSize + sphere.radius) {
        PVector n = new PVector(x - v.x, 0, z - v.y).normalize();
        sphere.location.x = v.x + (n.x * (Cylinder.cylinderBaseSize + sphere.radius));
        sphere.location.z = v.y + (n.z * (Cylinder.cylinderBaseSize + sphere.radius));
        sphere.velocity.sub(n.mult(PVector.dot(sphere.velocity, n) * 2));
        sphere.velocity.mult(0.66);
        toRemove = cylinders.indexOf(v);
      }
    }
    if (toRemove != 0 && toRemove < cylinders.size()) {
      cylinders.remove(toRemove);
    } else if (toRemove == 0 && toRemove < cylinders.size()) {
       cylinders.clear();
    }
  }
}
