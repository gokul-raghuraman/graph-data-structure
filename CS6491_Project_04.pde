/**************************** HEADER ****************************
 Author: Gokul Raghuraman, Rohan Somni
 Class: CS6491 Fall 2014
 Project number: 4
 Project title: Implementation of a mesh data structure
 Date of submission: 10/06/2014
*****************************************************************/

color black=#000000, white=#FFFFFF, red=#FF0000, green_true=#00FF01, green=#31CB94, blue=#75C4F7, blue_true=#0300FF, 
      yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB, grey=#5F5F5F;

int DRAW = 0;
int MOV = 1;
int DEL = 2;

GUIManager guiManager;

class GUIManager
{ 
  int mode = 0;
  
  private Mesh m;
  private int activeVertexIndex = -1;
  private int[] activeEdge = {-1, -1};
  
  boolean renderHalfEdges = false;
  boolean renderCorners = false;
  boolean renderFaces = false;
  boolean showArea = false;
  boolean showVertexIndices = false;
  
  //Register the mesh with GUIManager
  GUIManager(Mesh inputMesh)
  {
    m = inputMesh;
  }
  
  void setMode(int requestMode)
  {
    if (requestMode == 0 || requestMode == 1 || requestMode == 2)
    {
      unloadActiveVertexIndex();
      mode = requestMode;
    }
  }
  
  int getMode()
  {
    return mode;
  }
  
  int addNewVertex(int x, int y)
  {
    return m.addVertex(x, y);
  }
  
  void moveVertex(int x, int y)
  {
    m.moveVertex(activeVertexIndex, x, y);
  }
  
  void deleteVertex()
  {
    print("Going to delete Vertex!");
    boolean deleted = m.deleteVertex(activeVertexIndex);
    
    if (deleted)
    {
      print("Vertex Deleted");
      
    }
  }
  
  void addNewHalfEdges(int newVertexIndex)
  {
    //When this is called, we know that activeVertexIndex is giving rise to a new half edge within the mesh
    m.addHalfEdges(activeVertexIndex, newVertexIndex);
  }
  
  void loadActiveEdge(int x, int y)
  {
    //Too involved to imple
    
  }
  
  boolean edgeActive()
  {
    if (activeEdge[0] > -1 && activeEdge[1] > -1)
      return true;
    return false;
  }

  void unloadActiveEdge()
  {
    activeEdge[0] = -1;
    activeEdge[1] = -1;
  }
  
  //Load index of vertex closest to mouse cursor when clicking
  void loadActiveVertexIndex(int x, int y)
  {
    for (int index : m.G.keySet())
    {
      if (m.deletedVertices.get(index) != null)
        continue;
      if (sqrt(pow(m.G.get(index).x - x, 2) + pow(m.G.get(index).y - y, 2)) <= 10)
      {
        activeVertexIndex = index;
        break;
      }
    }
  }
  
  //Load index of vertex closest to mouse cursor when releasing
  int getReleaseVertexIndex(int x, int y)
  {
    int releaseVertexIndex = -1;
    for (int index : m.G.keySet())
    {
      if (sqrt(pow(m.G.get(index).x - x, 2) + pow(m.G.get(index).y - y, 2)) <= 10)
      {
        releaseVertexIndex = index;
        break;
      }
    }
    return releaseVertexIndex;
  }
  
  //Unload active vertex index
  void unloadActiveVertexIndex()
  {
    activeVertexIndex = -1;
  }
  
  //Return active vertex index
  int getActiveVertexIndex()
  {
    return activeVertexIndex;
  }
  
  //Is mesh empty
  boolean isMeshEmpty()
  {
    if (m.G.size() == 0)
      return true;
    return false;
  }
  
  //Render the transient edge during mouse drag
  void renderInteractiveEdge()
  {
    if (activeVertexIndex > -1)
    {
      line(m.G.get(activeVertexIndex).x, m.G.get(activeVertexIndex).y, mouseX, mouseY);
    }
  }
  
  Mesh getMesh()
  {
    return m;
  }
  
  void renderMesh()
  {
    m.render(renderHalfEdges, renderCorners, renderFaces, showArea, showVertexIndices);
  }
  
  void toggleViewHalfEdges()
  {
    renderHalfEdges = !renderHalfEdges;
  }
  
  void toggleViewCorners()
  {
    renderCorners = !renderCorners;
  }
  
  void toggleViewFaces()
  {
    renderFaces = !renderFaces;
  }
  
  void toggleViewArea()
  {
    showArea = !showArea;
  }
  
  void toggleViewVertexIndices()
  {
    showVertexIndices = !showVertexIndices;
  }
  
}


void setup()
{
  size(750, 700);
  myFace1 = loadImage("Data/pic1.jpg");
  myFace2 = loadImage("Data/pic2.JPG");
  guiManager = new GUIManager(new Mesh());
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    if (guiManager.getMode() == DEL)
    {
      guiManager.loadActiveVertexIndex(mouseX, mouseY);
      guiManager.loadActiveEdge(mouseX, mouseY);
      if (guiManager.edgeActive())
      {
        print("Edge selected for deletion");
      }
      else if (guiManager.getActiveVertexIndex() > -1)
      {
        print("Vertex Active");
        guiManager.deleteVertex();
      }
      guiManager.unloadActiveEdge();
      
    }
    
    else if (guiManager.isMeshEmpty())
      guiManager.addNewVertex(mouseX, mouseY);
      //mesh.addVertex(mouseX, mouseY);
  }
}


void mousePressed()
{
  if (mouseButton == LEFT)
    guiManager.loadActiveVertexIndex(mouseX, mouseY);
}


void mouseDragged()
{
  if (mouseButton == LEFT)
  {
    if (guiManager.getActiveVertexIndex() > -1 && guiManager.getMode() == MOV)
      guiManager.moveVertex(mouseX, mouseY);
  }
}


void mouseReleased()
{
  if (guiManager.getMode() == MOV)
  {
    guiManager.unloadActiveVertexIndex();
    return;
  }
  
  
    
  else if (guiManager.getActiveVertexIndex() > -1 && guiManager.getMode() == DRAW)
  {
    int releaseVertexIndex = guiManager.getReleaseVertexIndex(mouseX, mouseY);
    int newVertexIndex;
    if (releaseVertexIndex == -1)
      newVertexIndex = guiManager.addNewVertex(mouseX, mouseY);
    else
      newVertexIndex = releaseVertexIndex;
    //print("\nGoing to draw Half-Edge!!!");
    guiManager.addNewHalfEdges(newVertexIndex);
  }
  
  //Important: must release active vertex
  guiManager.unloadActiveVertexIndex();
  
}



void keyPressed()
{   
  if(key=='?') 
    scribeText=!scribeText; 
    
  if(key=='~')
    filming=!filming;
  
  if (key == 'w' || key == 'W')
  {
    guiManager.setMode(MOV);
  }
  
  else if (key == 'e' || key == 'E')
  {
    guiManager.setMode(DRAW);
  }
  
  else if (key == 'd' || key == 'D')
  {
    guiManager.setMode(DEL);
  }
  
  else if (key == 'a' || key == 'A')
  {
    guiManager.toggleViewArea();
  }
  
  else if (key == 'p' || key == 'P')
  {
    guiManager.getMesh().printVertices();
  }
  
  else if (key == 'v' || key == 'V')
  {
    guiManager.toggleViewVertexIndices();
  }
  
  else if (key == 'h' || key == 'H')
  {
    guiManager.toggleViewHalfEdges();
  }
  
  else if (key == 'c' || key == 'C')
  {
    guiManager.toggleViewCorners();
  }
  
  else if (key == 'f' || key == 'F')
  {
    guiManager.toggleViewFaces();
  }
}


void draw()
{
  background(white);
  noStroke();
  smooth();
  displayOverlay();
  checkIfFilming();
  _setCursor();
  _drawInputIcon();
   
}

void _drawInputIcon()
{
  noFill();
  stroke(blue);
  strokeWeight(2);
  rect(width-15, height-15, 3, 3);   
}


void _setCursor()
{   
    stroke(red);
    strokeWeight(2);
    noFill();
    
    if (guiManager.getMode() == DRAW)
      guiManager.renderInteractiveEdge();
    guiManager.renderMesh();
    
    //Render Cursor
    stroke(blue_true);
    strokeWeight(2);
    noFill();
    if (guiManager.getMode() == DRAW)
      ellipse(mouseX, mouseY, 8, 8);
    else if (guiManager.getMode() == MOV)
      rect(mouseX-5, mouseY-5, 10, 10);
    else if (guiManager.getMode() == DEL)
    {
      stroke(red);
      strokeWeight(1);
      rect(mouseX-4, mouseY-4, 8, 8);
      line(mouseX-6, mouseY-6, mouseX+6, mouseY+6);
      line(mouseX-6, mouseY+6, mouseX+6, mouseY-6);
    }
    
}
