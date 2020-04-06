/**
* class Villain to modelize an object that will move when looking at the sphere
* @arg shape a PShape to create the figure
* @arg size the size of the figure
*
*/

class Villain {
  PShape shape = new PShape();
  float size = 75;

  Villain() {
    PImage texture = loadImage("villain/robotnik.png");
    
    beginShape();
    shape = loadShape("villain/robotnik.obj");
    
    shape.scale(size);
   // villain.rotateX(PI);
    texture(texture);
    endShape();
  }
  
/** @brief draws the villain
 * @param origin the origin of the cylinder to draw the villain onto
*/
  void draw(PVector origin) {
    pushMatrix();
    translate(origin.x, origin.z + Cylinder.cylinderHeight, origin.y);
    shape(shape, 0, 0);
    popMatrix();
  }
}
