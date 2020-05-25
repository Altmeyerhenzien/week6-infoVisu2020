import java.util.List;
import java.util.TreeSet;
import java.util.Collections;

class Hough {

  // Hough algorithm
  List<PVector> hough(PImage edgeImg, int nLines) {
    float discretizationStepsPhi = 0.03f; 
    float discretizationStepsR = 1f;
    int minVotes=50;
    
    
    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative 
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
      edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);

    // pre-compute the sin and cos values
    float[] sin = new float[phiDim]; 
    float[] cos = new float[phiDim];
    for (int phi = 0; phi < phiDim; phi++) {
      float anglePhi = phi*discretizationStepsPhi;
      cos[phi] = (float) (Math.cos(anglePhi)/ discretizationStepsR);
      sin[phi] = (float) (Math.sin(anglePhi)/ discretizationStepsR);
    }


    // our accumulator
    int[] accumulator = new int[phiDim * rDim];

    // Fill the accumulator: on edge points (ie, white pixels of the edge 
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?  
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the accumulator
          for (int i = 0; i < phiDim; i++) {
            int r = (int)(rDim/2 + (x*cos[i] + y*sin[i]));

            // increment accordingly the accumulator.
            accumulator[i*rDim+r] += 1;
          }
        }
      }
    }

    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    // only the best line in a neighborhood is taken
    int neighborhoodWidth = 10;

    for (int idx = 0; idx < accumulator.length; idx++) { 
      if (accumulator[idx] > minVotes) {
        // scan the neighborhood and find the biggest value
        int min = idx - neighborhoodWidth/2;
        if (min < 0) min = 0;
        int max = idx + neighborhoodWidth/2;
        if (max > accumulator.length) max = accumulator.length;
        int biggest = 0;
        for (int j = min; j <= max; ++j) {
          if (accumulator[j] > biggest && j != idx) 
            biggest = accumulator[j];
        }

        // add the index if it has the most votes in the neighborhood
        if (accumulator[idx] >= biggest) {
          bestCandidates.add(idx);
        }
      }
    }

    // select the nLines best candidates
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    if (nLines > bestCandidates.size()) nLines = bestCandidates.size();

    ArrayList<PVector> lines = new ArrayList<PVector>(); 

    for (int i = 0; i < nLines; i++) {
      // compute back the (r, phi) polar coordinates:
      int idx = bestCandidates.get(i); 
      int accPhi = (int) (idx / (rDim));
      int accR = idx - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi; 
      lines.add(new PVector(r, phi));
    }

    // plot the accumulator
    PImage houghImg = createImage(rDim, phiDim, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(400, 400);
    houghImg.updatePixels();

    return lines;
  }
}
