import java.util.List;
import java.util.TreeSet;
import java.util.Collections;
/*import processing.video.*;

Capture cam;*/

PImage img;
HScrollbar barMin;
HScrollbar barMax;
Hough hough;
QuadGraph quad;

void settings() {
  size(1200, 300);
}

void setup() {
  img = loadImage("board1.jpg");
  img.resize(400, 300);
  //img = loadImage("hough_test.bmp");
  barMax = new HScrollbar(600, 780, 600, 20);
  barMin = new HScrollbar(600, 760, 600, 20);
  hough = new Hough();
  quad = new QuadGraph();

  noLoop();
}

void draw() {

  PImage img2 = thresholdHSB(img, 80, 140, 70, 255, 0, 255);

  PImage img3 = convolute(img2);

  PImage img4 = findConnectedComponents(img3, true);

  PImage img5 = detectEdge(img4);
  
  PImage img6 = thresholdHSB(img5, 0, 255, 0, 255, 100, 255);
  println(imagesEqual(img6, img5));


  barMin.display();
  barMin.update();
  barMax.display();
  barMax.update();

  List<PVector> lines = hough.hough(img6, 10);
  
  
  image(img, 0, 0);
  plotLines(img, lines);
  image(img5, img.width, 0);
  image(img4, img.width * 2,0);
  for (PVector corner : quad.findBestQuad(lines, img.width, img.height, 1000000, 1000, false)) {
    fill(color(random(255), random(255), random(255), 128));
    ellipse(corner.x, corner.y, 50, 50);
  }
}

/* setup a camera
void setupCamera() {
  String[] cameras = Capture.list(); 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, 1280, 720, cameras[0]);
    cam.start();
  }
}

// display the camera
void drawCamera() {
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  image(img, 0, 0);
}
*/
PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  colorMode(HSB, 255);
  PImage img2 = createImage(img.width, img.height, HSB);
  for (int i = 0; i < img.width; ++i) {
    for (int j = 0; j < img.height; ++j) {
      color pix = img.pixels[j * img.width + i];
      if (hue(pix) < minH || hue(pix) > maxH || saturation(pix) < minS || saturation(pix) > maxS || brightness(pix) < minB || brightness(pix) > maxB)
        img2.pixels[j*img.width + i] = color(hue(pix), saturation(pix), 0);
      else 
        img2.pixels[j*img.width + i] = color(hue(pix), saturation(pix), 255);
    }
  }
  return img2;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}


PImage convolute(PImage img) {
  float[][] kernel = { { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};
  float normFactor = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  // kernel size N = 3
  //
  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by normFactor
  // - set result.pixels[y * img.width + x] to this value
  color[] pixels = img.pixels;
  for (int i = 1; i < img.width - 1; ++i) {
    for (int j = 1; j < img.height - 1; ++j) {
      int alpha = 0;
      for (int a = -1; a < 2; ++a) {
        for (int b = -1; b < 2; ++b) {
          alpha += brightness(pixels[(i + a) + (j + b) * img.width]) * kernel[a+1][b+1];
        }
      }

      result.pixels[j * img.width + i] = color(alpha / normFactor);
    }
  }
  return result;
}

PImage detectEdge(PImage img) {
  float[][] hKernel = { { 3, 10, 3 }, 
    { 0, 0, 0 }, 
    { -3, -10, -3 }};
  float[][] vKernel = { { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 }};
  float normFactor = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  float[] buffer = new float[img.width * img.height];
  float maxVal = -1;
  color[] pixels = img.pixels;
  for (int i = 1; i < img.width - 1; ++i) {
    for (int j = 1; j < img.height - 1; ++j) {
      int sumH = 0;
      int sumV = 0;
      for (int a = -1; a < 2; ++a) {
        for (int b = -1; b < 2; ++b) {
          sumH += brightness(pixels[(i + a) + (j + b) * img.width]) * hKernel[a+1][b+1];
          sumV += brightness(pixels[(i + a) + (j + b) * img.width]) * vKernel[a+1][b+1];
        }
      }
      float sum = sqrt(sumH * sumH + sumV * sumV);
      if (sum > maxVal)
        maxVal = sum;

      buffer[i + j*img.width] = sum;
    }
  }

  for (int i = 0; i < buffer.length; ++i) {
    result.pixels[i] = color(buffer[i] / maxVal * 255);
  }
  return result;
}

PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
  // First pass: label the pixels and store labels' equivalences
  colorMode(RGB, 255);
  color[] pix = input.pixels;
  int[] labels = new int [input.width*input.height];
  List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
  int currentLabel = 0;

  for (int j = 0; j < input.height; ++j) {
    for (int i = 0; i < input.width; ++i) {
      if (pix[i + j*input.width] == color(255, 255, 255)) {
        int lab;
        if (i != 0) {
          if (j != 0) {
            int[] labs = new int[4];
            labs[0] = labels[(j-1) * input.width + (i-1)];
            labs[1] = labels[(j-1) * input.width + i];
            labs[3] = labels[(j-1) * input.width + (i+1)];
            labs[2] = labels[j*input.width + (i-1)];

            lab = -1;
            for (int k = 0; k < (i == input.width - 1 ? labs.length - 1 : labs.length); ++k) if (labs[k] != -1) {
              if (lab != -1) {
                labelsEquivalences.get(labs[k]-1).addAll(labelsEquivalences.get(lab-1)); 
                labelsEquivalences.get(lab-1).addAll(labelsEquivalences.get(labs[k]-1));
              }

              if (lab == -1 || labs[k] < lab)
                lab = labs[k];
            }
          } else 
          lab = labels[j*input.width + (i-1)];
        } else {
          if (j != 0) {
            int[] labs = new int[] {
              labels[(j-1) * input.width + i], 
              labels[(j-1) * input.width + (i+1)] };

            lab = -1;  
            for (int k : labs) if (k != -1) {
              if (lab != -1) {
                labelsEquivalences.get(k-1).addAll(labelsEquivalences.get(lab-1)); 
                labelsEquivalences.get(lab-1).addAll(labelsEquivalences.get(k-1));
              }

              if (lab == -1 || k < lab)
                lab = k;
            }
          } else 
          lab = -1;
        }
        if (lab == -1) {
          labels[j*input.width + i] = ++currentLabel;
          TreeSet newSet = new TreeSet();
          newSet.add(currentLabel);
          labelsEquivalences.add(newSet);
        } else labels[j*input.width + i] = lab;
      } else
        labels[j*input.width + i] = -1;
    }
  }

  int[] nbPixelsPerCluster = new int[labelsEquivalences.size()];

  for (int i = 0; i < labels.length; ++i) {
    if (labels[i] != -1) {
      int newLabel = labelsEquivalences.get(labels[i]-1).first();
      labels[i] = newLabel;
      ++nbPixelsPerCluster[newLabel-1];
    }
  }
  
  int biggestCluster = -1;
  int currBiggest = -1;
  for (int i = 0; i < nbPixelsPerCluster.length; ++i) if (nbPixelsPerCluster[i] > currBiggest) {
    biggestCluster = i;
    currBiggest = nbPixelsPerCluster[i];
  }

  color[] colors = new color[labelsEquivalences.size()];
  for (int i = 0; i < colors.length; ++i) colors[i] = (onlyBiggest ? (i == biggestCluster ? color(255, 255, 255) : color(0, 0, 0)) : color(random(255), random(255), random(255)));

  PImage result = createImage(input.width, input.height, ALPHA);
  for (int i = 0; i < labels.length; ++i) {
    int label = labels[i];
    //println(label);
    result.pixels[i] = label == -1 ? color(0, 0, 0) : colors[label-1];
  }

  return result;
}

// Helper function to plot a list of lines
void plotLines(PImage edgeImg, List<PVector> lines) {
  for (int idx = 0; idx < lines.size(); idx++) { 
    PVector line = lines.get(idx);
    float r = line.x; 
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)

    // compute the intersection of this line with the 4 borders of 
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));

    int x1 = (int) (r / cos(phi));
    int y1 = 0;

    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi)); 

    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

    // Finally, plot the lines
    stroke(204, 102, 0); 
    if (y0 > 0) {
      if (x1 > 0) {
        line(x0, y0, x1, y1);
      } else if (y2 > 0) {
        line(x0, y0, x2, y2);
      } else {
        line(x0, y0, x3, y3);
      }
    } else {
      if (x1 > 0) {
        if (y2 > 0) {
          line(x1, y1, x2, y2);
        } else {
          line(x1, y1, x3, y3);
        }
      } else {
        line(x2, y2, x3, y3);
      }
    }
  }
}
