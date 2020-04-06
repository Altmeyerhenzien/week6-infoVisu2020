/** class Cylinder: to represent cylinders of type PShape
 * @arg cylinderBaseSize the base of the cylinder
 * @arg cylinderHeight the height of the cylinder
 * @arg cylinderResolution, the accuracy with which the cylinder is drawn
 *
 * @arg cylinder of type PShape
 * @arg center the coordinates of the center of the cylinder
 */

public class Cylinder {
  static final float cylinderBaseSize = 30;
  static final float cylinderHeight = 100;
  int cylinderResolution = 25;
  PShape cylinder = new PShape();
  PVector center;

  Cylinder(PVector center) {
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    this.center = center;

    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    
    cylinder = createShape();

    cylinder.beginShape(TRIANGLE_FAN);
    for (int i = 0; i < x.length; ++i) {
      cylinder.vertex(x[i], y[i], 0);
      cylinder.vertex(0, 0, 0);
    }
    cylinder.endShape();

    cylinder.beginShape(TRIANGLE_FAN);
    for (int i = 0; i < x.length; ++i) {
      cylinder.vertex(x[i], y[i], cylinderHeight);
      cylinder.vertex(0, 0, cylinderHeight);
    }
    cylinder.endShape();

    cylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      cylinder.vertex(x[i], y[i], 0);
      cylinder.vertex(x[i], y[i], cylinderHeight);
    }
    cylinder.endShape();
  }
  
/** @brief draws the cylinder and translate it to its center
*/
  private void shapeCylinder() { 
    translate(center.x, center.y, center.z);
    rotateX(PI/2);
    shape(cylinder);
  }
}
