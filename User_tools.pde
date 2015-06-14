boolean scribeText=true;
int pictureCounter=0;
PImage myFace1, myFace2; 
String title ="CS6491 | Fall 2014 | Assignment 4: \nImplementation of a mesh data structure that uses vertices, half-edges and faces", 
       name1 ="Gokul Raghuraman", name2 = "Rohan Somni",
       menu="?: (show/hide) help      ~: (start/stop) recording frames for movie",
       guide1 = "Controls:",
       guide2 = "'E' : Drawing mode: Click and release anywhere to draw first vertex. \n      Then drag out from vertex and release to form new vertices and edges.",
       guide3 = "'W' : Moving mode : Click on vertex and drag to move it around.", 
       guide4 = "'D' : Delete mode: click on a uni- or bi-valent vertex to delete it.",
       guide5 = "'F' : Display all the face outlines.",
       guide6 = "'C' : Display all the corners.",
       guide7 = "'H' : Display all the half-edges.",
       guide8 = "'A' : Show face indices and areas.",
       guide9 = "'V' : Show vertex indices.",
       guide10 = "'P' : Print the internal data structure.",
       guide = guide1 + '\n' + guide2 + '\n' + guide3 + '\n' + guide4 + '\n' + guide5 + '\n' + guide6 + '\n' + guide7 + '\n' + guide8 + '\n' + guide9 + '\n' + guide10;

//*****Capturing Frames for a Movie*****
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)

void checkIfFilming()
{
 if(filming)
  {
    saveFrame("FRAMES/"+nf(frameCounter++,4)+".png");
    fill(red);
    stroke(red);
    ellipse(width - 20, height - 20, 5, 5);
  }  
}

//********Display Header/Footer*********
void displayOverlay()
{
 displayHeader();
 if(scribeText && !filming) 
   displayFooter();
}

void displayHeader()
{
  fill(0); 
  text(title, 10, 20); 
  text(name1, width - 13.0 * name1.length(), 40);
  text(name2, width - 7.5 * name2.length(), 40);
  noFill();
  image(myFace1, width - myFace1.width/3 - 100, 45, myFace1.width/3,myFace1.height/3);  
  image(myFace2, width - myFace1.width/3 - 30, 45, myFace1.width/3,myFace1.height/3);
}

void displayFooter()
{  
  scribeFooter(guide, 9);
  scribeFooter(menu, 0);
}

void scribeFooter(String s, int i)  
{
  fill(0); 
  text(s, 10, height - 10 - i * 20); 
  noFill();
}
