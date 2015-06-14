class Mesh
{
  HashMap<Integer, Vertex> G;
  HashMap<Integer, Integer> V, N, F, Hv, Hf, O;  //V vertex of halfedge,  N returns next corner, F int id of halfedge on face f, O opposite half edge, Hv halfedge of vertex
  HashMap<Integer, Boolean> deletedVertices, deletedHalfEdges;
  int maxVertexIndex, maxHalfEdgeIndex, maxFaceIndex;
  
  //Display parameters
  float halfEdgeOffset = 10;
  float cornerOffset = 15;
  
  Mesh()
  {
    /*
    Main Mesh data structure
    */
    G = new HashMap<Integer, Vertex>(); 
    V = new HashMap<Integer, Integer>(); 
    N = new HashMap<Integer, Integer>();
    F = new HashMap<Integer, Integer>();
    Hv = new HashMap<Integer, Integer>();
    Hf = new HashMap<Integer, Integer>();
    O = new HashMap<Integer, Integer>();
    
    deletedVertices = new HashMap<Integer, Boolean>();
    deletedHalfEdges = new HashMap<Integer, Boolean>();
    
    maxVertexIndex = -1;
    maxHalfEdgeIndex = -1;
    maxFaceIndex = -1;
    
  }
  
  
  int addVertex(int x, int y)
  {
    //Put vertex into G table
     maxVertexIndex += 1;
     G.put(maxVertexIndex, new Vertex(x, y));
     return maxVertexIndex;
  }
  
  void moveVertex(int vIndex, int x, int y)
  {
    G.put(vIndex, new Vertex(x, y));
  }
  
  boolean deleteVertex(int vIndex)
  {
    int[] halfEdges = getAllHalfEdgesFromVertex(vIndex);
    if (halfEdges.length > 2)
    {
      print("Multi-valent vertex! Cannot delete!");
      return false;
    }
    
    else if (halfEdges.length == 1)
    {
      print("Univalent vertex!");

      int nextHalfEdge = N.get(Hv.get(vIndex));
      int prevHalfEdge = getPrevHalfEdgeIndex(O.get(Hv.get(vIndex)));
      N.put(prevHalfEdge, nextHalfEdge);
      deletedVertices.put(vIndex, true);
      deletedHalfEdges.put(Hv.get(vIndex), true);
      deletedHalfEdges.put(O.get(Hv.get(vIndex)), true);
      return true;
    }
    
    else if (halfEdges.length == 2)
    {
      //Caveat: Does not check if a face is being deleted
      
      int delHalfEdge1 = Hv.get(vIndex);
      int delHalfEdge2 = O.get(delHalfEdge1);
      int nextHalfEdge1 = N.get(delHalfEdge1);
      int prevHalfEdge1 = getPrevHalfEdgeIndex(delHalfEdge2);
      int nextHalfEdge2 = N.get(delHalfEdge2);
      int prevHalfEdge2 = getPrevHalfEdgeIndex(delHalfEdge1);
      
      int vIndex2 = V.get(nextHalfEdge1);
      if (N.get(delHalfEdge1) == delHalfEdge2)
      {
        N.put(prevHalfEdge2, nextHalfEdge2);
        Hv.put(vIndex2, nextHalfEdge2);
        V.put(nextHalfEdge2, vIndex2);
      }
      else
      {
        N.put(prevHalfEdge1, nextHalfEdge2);
        N.put(prevHalfEdge2, nextHalfEdge1);
        Hv.put(vIndex2, nextHalfEdge2);
        V.put(nextHalfEdge2, vIndex2);
      }
      deletedVertices.put(vIndex, true);
      deletedHalfEdges.put(delHalfEdge1, true);
      deletedHalfEdges.put(delHalfEdge2, true);
      return true;
    }
    return false;
  }
  
  int getPrevHalfEdgeIndex(int halfEdgeIndex)
  {
    int nextHalfEdgeIndex = N.get(halfEdgeIndex);
    int markerIndex = nextHalfEdgeIndex;
    while(nextHalfEdgeIndex != halfEdgeIndex)
    {
      markerIndex = nextHalfEdgeIndex;
      nextHalfEdgeIndex = N.get(nextHalfEdgeIndex);
    }
    return markerIndex;
  }
  
  
  int getSwing(int halfEdgeIndex)
  {
    int prevHalfEdge = getPrevHalfEdgeIndex(halfEdgeIndex);
    return O.get(prevHalfEdge);
  }
  
  
  Vector2d getVectorFromHalfEdge(int halfEdgeIndex)
  {
    Vertex pointA = G.get(V.get(halfEdgeIndex));
    Vertex pointB = G.get(V.get(N.get(halfEdgeIndex)));
    Vector2d OA = new Vector2d(pointA.x, pointA.y);
    Vector2d OB = new Vector2d(pointB.x, pointB.y);
    return OB.sub(OA);
  }
  
  
  int[] getAllVerticesFromVertex(int vIndex)
  { 
    int[] halfEdges = getAllHalfEdgesFromVertex(vIndex);
    int[] vertices = new int[halfEdges.length];
    for (int i = 0; i < halfEdges.length; i++)
    {
      int nextHalfEdge = N.get(halfEdges[i]);
      vertices[i] = V.get(nextHalfEdge);
    }
    return vertices;
  }
  
  
  int[] getAllHalfEdgesInFace(int faceIndex)
  {
    //print("\nTrying to get all half edges for face : ", faceIndex);
    ArrayList<Integer> halfEdges = new ArrayList<Integer>();
    int startHalfEdgeIndex = Hf.get(faceIndex);
    //print("\nStart half edge of face ", faceIndex, " is ", startHalfEdgeIndex);
    halfEdges.add(startHalfEdgeIndex);
    int markerIndex = N.get(startHalfEdgeIndex);
    
    while (markerIndex != startHalfEdgeIndex)
    {
      halfEdges.add(markerIndex);
      markerIndex = N.get(markerIndex);
    }
    
    int[] halfEdgeArray = new int[halfEdges.size()];
    for (int i = 0; i < halfEdges.size(); i++)
      halfEdgeArray[i] = halfEdges.get(i);
    return halfEdgeArray;
  }
  
  
  int[] getAllHalfEdgesFromVertex(int vIndex)
  { 
    if (Hv.get(vIndex) == null)
      return new int[0];
    ArrayList<Integer> halfEdges = new ArrayList<Integer>();
    int startHalfEdgeIndex = Hv.get(vIndex);
    halfEdges.add(startHalfEdgeIndex);
    int halfEdgeIndex = getSwing(startHalfEdgeIndex);
    while (halfEdgeIndex != startHalfEdgeIndex)
    {
      halfEdges.add(halfEdgeIndex);
      halfEdgeIndex = getSwing(halfEdgeIndex);
    } 
    int[] halfEdgeArray = new int[halfEdges.size()];
    for (int i = 0; i < halfEdges.size(); i++)
      halfEdgeArray[i] = halfEdges.get(i);
    return halfEdgeArray;
  }
  
  
  int[] getCandidateHalfEdgesFromVertex(int vRefIndex, int vQueryIndex)
  {
    /*Takes a multi-valent vertex (vSourceIndex) and a query vertex (vQueryIndex) 
    and returns 2 candidate half-edges based on the query vertex's position
    in space. The utility of this function is to shortlist a pair of half-edges
    to break and insert new half edges.
    */
    
    int[] halfEdgesFromVertex = getAllHalfEdgesFromVertex(vRefIndex);
    if (halfEdgesFromVertex.length == 2)
      return halfEdgesFromVertex;

    boolean vertexInternal = true;    
    ArrayList<Integer[]> candidatePairs = new ArrayList<Integer[]>(); 
    for (int i = 0; i < halfEdgesFromVertex.length; i++)
    {
      int candidate = halfEdgesFromVertex[i];
      int swingNeighbor = getSwing(candidate); 
      
      int vIndex1 = V.get(N.get(candidate));
      int vIndex2 = V.get(N.get(swingNeighbor));
      
      Vector2d sourceVec = new Vector2d(G.get(vRefIndex).x, G.get(vRefIndex).y);
      Vector2d destVec = new Vector2d(G.get(vQueryIndex).x, G.get(vQueryIndex).y);
      Vector2d vertexCut = destVec.sub(sourceVec);
      Vertex testPoint = P(G.get(vRefIndex), 1e-5, vertexCut);
      if (isPointInTriangle(testPoint, G.get(vIndex1), G.get(vRefIndex), G.get(vIndex2)))
      {
        candidatePairs.add(new Integer[]{candidate, swingNeighbor});
      }
    }

    //If there were no candidate pairs, at this point we're probably dealing with a vertex on the
    //side of the edges forming obtuse angles. In that case, we will search again by
    //pushing the testPoint in the other direction 
    if (candidatePairs.size() == 0)
    {
      vertexInternal = false;
      for (int i = 0; i < halfEdgesFromVertex.length; i++)
      {
        int candidate = halfEdgesFromVertex[i];
        int swingNeighbor = getSwing(candidate); 
        
        int vIndex1 = V.get(N.get(candidate));
        int vIndex2 = V.get(N.get(swingNeighbor));
        Vector2d sourceVec = new Vector2d(G.get(vRefIndex).x, G.get(vRefIndex).y);
        Vector2d destVec = new Vector2d(G.get(vQueryIndex).x, G.get(vQueryIndex).y);
        Vector2d vertexCut = destVec.sub(sourceVec);
        Vertex testPoint = P(G.get(vRefIndex), -1e-5, vertexCut);
        if (isPointInTriangle(testPoint, G.get(vIndex1), G.get(vRefIndex), G.get(vIndex2)))
          candidatePairs.add(new Integer[]{candidate, swingNeighbor});
      }
    }

    //If it's still zero, take the pair that makes the greatest angle
    if (candidatePairs.size() == 0)
    {
      float maxAngle = 0.0;
      candidatePairs.add(new Integer[]{halfEdgesFromVertex[0], halfEdgesFromVertex[1]});
      for (int i = 0; i < halfEdgesFromVertex.length; i++)
      {
        int halfEdge1 = halfEdgesFromVertex[i];
        for (int j = 0; j < halfEdgesFromVertex.length; j++)
        {
          if (i == j)
            continue;
            
          int halfEdge2 = halfEdgesFromVertex[j];
          float edgeAngle = abs(angle(getVectorFromHalfEdge(halfEdge1), getVectorFromHalfEdge(halfEdge2)));
          if (edgeAngle > maxAngle)
          {
            maxAngle = edgeAngle;
            candidatePairs.set(0, new Integer[]{halfEdge1, halfEdge2});
          }
        }
      }
    }
    
    if (candidatePairs.size() == 1)
    {
      return new int[]{candidatePairs.get(0)[0], candidatePairs.get(0)[1]};
    }
    
    //If there are 2 pairs here (and there cannot be more), select the pair with 
    //the least angle in case of internal vertex and greatest angle incase of external vertex
    
    Vector2d hVec1 = getVectorFromHalfEdge(candidatePairs.get(0)[0]);
    Vector2d hVec2 = getVectorFromHalfEdge(candidatePairs.get(0)[1]);
    
    float angle1 = angle(hVec1, hVec2);
    
    hVec1 = getVectorFromHalfEdge(candidatePairs.get(1)[0]);
    hVec2 = getVectorFromHalfEdge(candidatePairs.get(1)[1]);
      
    float angle2 = angle(hVec1, hVec2);
    
    if (vertexInternal)
    {
      if (abs(angle1) < abs(angle2))
      {
        return new int[]{candidatePairs.get(0)[0], candidatePairs.get(0)[1]};
      }
      else
      {
        return new int[]{candidatePairs.get(1)[0], candidatePairs.get(1)[1]};
      }
    }
    else
    {
      if (abs(angle1) > abs(angle2))
      {
        return new int[]{candidatePairs.get(0)[0], candidatePairs.get(0)[1]};
      }
    }
    return new int[]{candidatePairs.get(1)[0], candidatePairs.get(1)[1]};
  }
  

  int getCompatibleHalfEdge(int[] candidateHalfEdges, int vRefIndex, int vQueryIndex)
  {
    
    /*This is the core function that identifies the 'correct' sidewalk-style half edge for a 
    reference vertex. It takes a list of 2 candidate half edges, the reference vertex index, and 
    index of 2 more vertices that form a triangle with the reference vertex. It returns the index 
    of the half-edge that should logically be the one leading to the newly added half-edges 
    contained within the triangle.
    */
    
    int vIndex1 = V.get(N.get(candidateHalfEdges[0]));
    int vIndex2 = V.get(N.get(candidateHalfEdges[1]));

    Vector2d hVector1 = getVectorFromHalfEdge(candidateHalfEdges[0]);
    Vector2d hVector2 = getVectorFromHalfEdge(candidateHalfEdges[1]);
    
    Vector2d qVector1 = new Vector2d(G.get(vRefIndex).x, G.get(vRefIndex).y);
    Vector2d qVector2 = new Vector2d(G.get(vQueryIndex).x, G.get(vQueryIndex).y);
    Vector2d qVector = qVector2.sub(qVector1);
    
    float angleTot = angle(hVector1, hVector2);
    float angle1 = angle(hVector1, qVector);
    float angle2 = angle(qVector, hVector2);
    boolean vertexInternal = (abs(abs(angleTot) - abs(angle1) - abs(angle2)) < 1e-5);
    
    //Offset point a tiny bit along vector and perpendicular to vector away from edge 
    Vertex slidePoint1 = P(new Vertex(G.get(vRefIndex).x, G.get(vRefIndex).y), 0.6, hVector1);
    slidePoint1 = P(slidePoint1, 1e-5, R(hVector1));
    
    boolean pointInTriangle = isPointInTriangle(slidePoint1, G.get(vIndex1), G.get(vRefIndex), G.get(vIndex2));
    if (!pointInTriangle)
    {
      if (vertexInternal)
        return O.get(candidateHalfEdges[0]);
      else 
        return O.get(candidateHalfEdges[1]);
    }

    if (vertexInternal)
      return O.get(candidateHalfEdges[1]);

    return O.get(candidateHalfEdges[0]);
  }
  
  
  //Updates Hv table based on two vertex indices. Our GUI manager knows what these indices are.
  void addHalfEdges(int vIndex1, int vIndex2)
  {
    int[] halfEdgesFromVertex1 = getAllHalfEdgesFromVertex(vIndex1);
    int[] halfEdgesFromVertex2 = getAllHalfEdgesFromVertex(vIndex2);
    
    //Case 1: This was the first vertex drawn
    if (halfEdgesFromVertex1.length == 0)
    {
      maxHalfEdgeIndex += 1;
      
      //Update Hv
      Hv.put(vIndex1, maxHalfEdgeIndex);
      Hv.put(vIndex2, maxHalfEdgeIndex + 1);
      
      //Update V
      V.put(maxHalfEdgeIndex, vIndex1);
      V.put(maxHalfEdgeIndex + 1, vIndex2);
      
      //Update N
      N.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
      N.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);
      
      //Update O
      O.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
      O.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);
      
      
      //Update F table
      maxFaceIndex += 1;
      
      //print("Incrementing faces to : ", maxFaceIndex + 1);
      
      F.put(maxHalfEdgeIndex, maxFaceIndex);
      F.put(maxHalfEdgeIndex + 1, maxFaceIndex);
      
      //Update Hf table
      //print("\nPutting Hf[", maxFaceIndex, "] = ", maxHalfEdgeIndex);
      Hf.put(maxFaceIndex, maxHalfEdgeIndex);
      
      
      //Again update maxHalfEdgeIndex by 1
      maxHalfEdgeIndex += 1;
      
      
    }
    
    //Case 2: There is only 1 half edge going out from this vertex
    //This means we're simply extending/closing a chain
    else if (halfEdgesFromVertex1.length == 1)
    {
      //Now look at the valency of vIndex2. If it's zero, simply close the connection 
      //with the 2 new half edges
      if (halfEdgesFromVertex2.length == 0)
      {
        //Do not update Hv for vIndex1 (because there are half-edges from this vertex already!).
        //We'll look at vIndex2 later in the function.
        maxHalfEdgeIndex += 1;
      
        //Update V table
        V.put(maxHalfEdgeIndex, vIndex1);
      
        //Update O table
        O.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        O.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);

        int first = O.get(halfEdgesFromVertex1[0]);
        int last = halfEdgesFromVertex1[0];
        N.put(first, maxHalfEdgeIndex);
        N.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        N.put(maxHalfEdgeIndex + 1, last);
        
        //Update Hv table
        Hv.put(vIndex2, maxHalfEdgeIndex + 1);
        
        //Update V table
        V.put(maxHalfEdgeIndex + 1, vIndex2);
        
        //Update F table. In this case there's no new face added. So we'll check the face index
        //of the previous half edge and use that as the current face index for both new half edges.
        //No need to update Hf table 
        int associatedFaceIndex = F.get(getPrevHalfEdgeIndex(maxHalfEdgeIndex));
        F.put(maxHalfEdgeIndex, associatedFaceIndex);
        F.put(maxHalfEdgeIndex + 1, associatedFaceIndex);
        
        maxHalfEdgeIndex += 1;
        
      }
      
      //If it's 1, close it up
      else if (halfEdgesFromVertex2.length == 1)
      {
        //Do not update Hv for vIndex1 (because there are half-edges from this vertex already!).
        //We'll look at vIndex2 later in the function.
        maxHalfEdgeIndex += 1;
      
        //Update V table
        V.put(maxHalfEdgeIndex, vIndex1);
      
        //Update O table
        O.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        O.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);

        int first = O.get(halfEdgesFromVertex1[0]);
        N.put(first, maxHalfEdgeIndex);
        
        int last = halfEdgesFromVertex1[0];
        int nextHalfEdgeIndex = halfEdgesFromVertex2[0];
        
        //Update V
        V.put(maxHalfEdgeIndex + 1, vIndex2);
        
        //Update N
        N.put(maxHalfEdgeIndex, nextHalfEdgeIndex);
        N.put(O.get(nextHalfEdgeIndex), maxHalfEdgeIndex + 1);
        N.put(maxHalfEdgeIndex + 1, last);
        
        //In this case we've definitely added a new face. So we'll update the Hf table as well
        //We'll have to do some looping around for this. We'll increment the face counter and
        //put the inner face in it.
        
        //First put the opposite half-edge into the current face
        
        //print("Putting ", maxHalfEdgeIndex + 1, " into  face ", maxFaceIndex);
        
        print("UNIVALENT TO UNIVALENT");
        
        int faceIndex = F.get(getPrevHalfEdgeIndex(maxHalfEdgeIndex));
        F.put(maxHalfEdgeIndex, faceIndex);
        print("Putting Halfedge ", maxHalfEdgeIndex, " to face ", faceIndex);
        
        Hf.put(faceIndex, maxHalfEdgeIndex);
        
        maxFaceIndex += 1;
        
        print("\nAssigning half-edge ", maxHalfEdgeIndex + 1, " for face ", maxFaceIndex); 
        Hf.put(maxFaceIndex, maxHalfEdgeIndex + 1);
        //Walk from maxHalfEdgeIndex + 1
        F.put(maxHalfEdgeIndex + 1, maxFaceIndex);
        print("\nPutting ", maxHalfEdgeIndex + 1, " into face ", maxFaceIndex);
        int markerIndex = N.get(maxHalfEdgeIndex + 1);
        
        while(markerIndex != (maxHalfEdgeIndex + 1))
        {
          print("\nPutting ", markerIndex, " into face ", maxFaceIndex);
          F.put(markerIndex, maxFaceIndex);
          markerIndex = N.get(markerIndex);
        }
        maxHalfEdgeIndex += 1;
      }
      
      //If it's more than 1, determine correct half-edge associations
      else
      {
        print("Univalent to multivalent");
        maxHalfEdgeIndex += 1;
        int[] candidateHalfEdges = getCandidateHalfEdgesFromVertex(vIndex2, vIndex1);        
        int prevHalfEdge = getCompatibleHalfEdge(candidateHalfEdges, vIndex2, vIndex1);
        
        //Hold onto its soon-to-be-outdated 'next' half-edge to re-insert below
        int lastHalfEdge = N.get(prevHalfEdge);
        
        //Update V table
        V.put(maxHalfEdgeIndex, vIndex1);
        
        //Update O table
        O.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        O.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);

        int first = O.get(halfEdgesFromVertex1[0]);
        int last = halfEdgesFromVertex1[0];
        N.put(first, maxHalfEdgeIndex);
        
        //Update V
        V.put(maxHalfEdgeIndex + 1, vIndex2);
        
        //Final updates to N
        N.put(maxHalfEdgeIndex, lastHalfEdge);
        N.put(prevHalfEdge, maxHalfEdgeIndex + 1);
        N.put(maxHalfEdgeIndex + 1, last);
        
        
        //Joining to a multivalent vertex
        print("\nJoining to multivalent vertex!");
        
        //Similar face creation logic as before. We'll update the Hf table
        //Loop around to re-assign half-edges to new face
        
        //Get face index of prev half edge of opposite
        //Find faceIndex of prev half-edge
        int faceIndex = F.get(getPrevHalfEdgeIndex(maxHalfEdgeIndex));
        print("Putting Halfedge ", maxHalfEdgeIndex, " to face ", faceIndex);
        F.put(maxHalfEdgeIndex, faceIndex);
        
        Hf.put(faceIndex, maxHalfEdgeIndex);
        
        maxFaceIndex += 1;
        
        print("\nAssigning half-edge ", maxHalfEdgeIndex + 1, " for face ", maxFaceIndex); 
        Hf.put(maxFaceIndex, maxHalfEdgeIndex + 1);
        //Walk from maxHalfEdgeIndex + 1
        F.put(maxHalfEdgeIndex + 1, maxFaceIndex);
        print("\nPutting ", maxHalfEdgeIndex + 1, " into face ", maxFaceIndex);
        int markerIndex = N.get(maxHalfEdgeIndex + 1);
        
        while(markerIndex != (maxHalfEdgeIndex + 1))
        {
          print("\nPutting ", markerIndex, " into face ", maxFaceIndex);
          F.put(markerIndex, maxFaceIndex);
          markerIndex = N.get(markerIndex);
        }
        
        maxHalfEdgeIndex += 1;
      }
    }
    
    //Case 3: Multivalent source vertex. 
    else
    {
      if (halfEdgesFromVertex2.length == 0)
      {
        maxHalfEdgeIndex += 1;
        int[] candidateHalfEdges = getCandidateHalfEdgesFromVertex(vIndex1, vIndex2);
        int prevHalfEdge = getCompatibleHalfEdge(candidateHalfEdges, vIndex1, vIndex2);
        
        //Hold onto its soon-to-be-outdated 'next' half-edge to re-insert below
        int lastHalfEdge = N.get(prevHalfEdge);
        
        //Update V table for vIndex1
        V.put(maxHalfEdgeIndex, vIndex1);
        
        //Update O table
        O.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        O.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);
        
        //Update N table at this junction
        N.put(prevHalfEdge, maxHalfEdgeIndex);
        N.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        N.put(maxHalfEdgeIndex + 1, lastHalfEdge);
        V.put(maxHalfEdgeIndex + 1, vIndex2);
        
        //Update Hv table
        Hv.put(vIndex2, maxHalfEdgeIndex + 1);
        
        //Update F table. In this case there's no new face added. So we'll check the face index
        //of the previous half edge and use that as the current face index for both new half edges.
        //No need to update Hf table 
        int associatedFaceIndex = F.get(getPrevHalfEdgeIndex(getPrevHalfEdgeIndex(maxHalfEdgeIndex)));
        F.put(maxHalfEdgeIndex, associatedFaceIndex);
        F.put(maxHalfEdgeIndex + 1, associatedFaceIndex);
        
        maxHalfEdgeIndex += 1;
      }
      
      else if (halfEdgesFromVertex2.length == 1)
      {        
        maxHalfEdgeIndex += 1;
        int[] candidateHalfEdges = getCandidateHalfEdgesFromVertex(vIndex1, vIndex2);        
        int prevHalfEdge = getCompatibleHalfEdge(candidateHalfEdges, vIndex1, vIndex2);
        int lastHalfEdge = N.get(prevHalfEdge);
        
        //Update V
        V.put(maxHalfEdgeIndex, vIndex1);
        V.put(maxHalfEdgeIndex + 1, vIndex2);
        
        //Update O table
        O.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        O.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);
        
        //Update N table
        N.put(prevHalfEdge, maxHalfEdgeIndex);
        N.put(maxHalfEdgeIndex, Hv.get(vIndex2));
        N.put(O.get(Hv.get(vIndex2)), maxHalfEdgeIndex + 1);
        N.put(maxHalfEdgeIndex + 1, lastHalfEdge);
        
        
        //Again update faces
        print("Multivalent to univalent!");
        
        //Find faceIndex of prev half-edge
        int faceIndex = F.get(getPrevHalfEdgeIndex(getPrevHalfEdgeIndex(maxHalfEdgeIndex)));
        print("Putting Halfedge ", maxHalfEdgeIndex, " to face ", faceIndex);
        F.put(maxHalfEdgeIndex, faceIndex);
        
        Hf.put(faceIndex, maxHalfEdgeIndex);
        
        maxFaceIndex += 1;
        
        print("\nAssigning half-edge ", maxHalfEdgeIndex + 1, " for face ", maxFaceIndex); 
        Hf.put(maxFaceIndex, maxHalfEdgeIndex + 1);
        //Walk from maxHalfEdgeIndex + 1
        F.put(maxHalfEdgeIndex + 1, maxFaceIndex);
        print("\nPutting ", maxHalfEdgeIndex + 1, " into face ", maxFaceIndex);
        int markerIndex = N.get(maxHalfEdgeIndex + 1);
        
        while(markerIndex != (maxHalfEdgeIndex + 1))
        {
          print("\nPutting ", markerIndex, " into face ", maxFaceIndex);
          F.put(markerIndex, maxFaceIndex);
          markerIndex = N.get(markerIndex);
        }
        
        maxHalfEdgeIndex += 1;
        
      }
      
      else
      {
        
        print("Multivalent to multivalent!!!!!!");
        //Multivalent source and destination vertices. Do all the computations.
        maxHalfEdgeIndex += 1;
        int[] candidateSourceHalfEdges = getCandidateHalfEdgesFromVertex(vIndex1, vIndex2);
        int prevSourceHalfEdge = getCompatibleHalfEdge(candidateSourceHalfEdges, vIndex1, vIndex2);
        int lastSourceHalfEdge = N.get(prevSourceHalfEdge);
        
        int[] candidateDestHalfEdges = getCandidateHalfEdgesFromVertex(vIndex2, vIndex1);
        int prevDestHalfEdge = getCompatibleHalfEdge(candidateDestHalfEdges, vIndex2, vIndex1);
        int lastDestHalfEdge = N.get(prevDestHalfEdge);
        
        //Update V
        V.put(maxHalfEdgeIndex, vIndex1);
        V.put(maxHalfEdgeIndex + 1, vIndex2);
        
        //Update O
        O.put(maxHalfEdgeIndex, maxHalfEdgeIndex + 1);
        O.put(maxHalfEdgeIndex + 1, maxHalfEdgeIndex);
        
        //Update N
        N.put(prevSourceHalfEdge, maxHalfEdgeIndex);
        N.put(maxHalfEdgeIndex, lastDestHalfEdge);
        N.put(prevDestHalfEdge, maxHalfEdgeIndex + 1);
        N.put(maxHalfEdgeIndex + 1, lastSourceHalfEdge);
        
        //Update faces again
        
        //Find faceIndex of prev half-edge
        int faceIndex = F.get(getPrevHalfEdgeIndex(maxHalfEdgeIndex));
        print("Putting Halfedge ", maxHalfEdgeIndex, " to face ", faceIndex);
        F.put(maxHalfEdgeIndex, faceIndex);
        
        Hf.put(faceIndex, maxHalfEdgeIndex);
        
        maxFaceIndex += 1;
        
        print("\nAssigning half-edge ", maxHalfEdgeIndex + 1, " for face ", maxFaceIndex); 
        Hf.put(maxFaceIndex, maxHalfEdgeIndex + 1);
        //Walk from maxHalfEdgeIndex + 1
        F.put(maxHalfEdgeIndex + 1, maxFaceIndex);
        print("\nPutting ", maxHalfEdgeIndex + 1, " into face ", maxFaceIndex);
        int markerIndex = N.get(maxHalfEdgeIndex + 1);
        
        while(markerIndex != (maxHalfEdgeIndex + 1))
        {
          print("\nPutting ", markerIndex, " into face ", maxFaceIndex);
          F.put(markerIndex, maxFaceIndex);
          markerIndex = N.get(markerIndex);
        }
        
        maxHalfEdgeIndex += 1;
        
      }
    }
  }
  
  
  void printVertices()
  {
    print("\n============INTERNAL TABLES AND STATS============");
    for (int i = 0; i < G.size(); i++)
    {
      Vertex v = G.get(i);
      print("\nG[", i, "] = (", v.x, ", ", v.y, ")");
    }
    print("\n");
    
    for (int i = 0; i < G.size(); i++)
    {
      print("\nHv[", i, "] = ", Hv.get(i)); 
    }
    print("\n");
    
    for (int i = 0; i < V.size(); i++)
    {
      if (deletedHalfEdges.get(i) != null)
        continue;
      print("\nV[", i, "] = ", V.get(i));
    }
    print("\n");
    
    for (int i = 0; i < N.size(); i++)
    {
      print("\nN[", i, "] = ", N.get(i));
    }
    print("\n");
    
    for (int i = 0; i < O.size(); i++)
    {
      print("\nO[", i, "] = ", O.get(i));
    }
    print("\n");
    
    for (int i = 0; i < Hf.size(); i++)
    {
      print("\nHf[", i, "] = ", Hf.get(i));
    }
    print("\n");
    
    for (int i = 0; i < F.size(); i++)
    {
      print("\nF[", i, "] = ", F.get(i));
    }
    print("\n");
    
    for (int i = 0; i < V.size(); i++)
    {
      if (deletedHalfEdges.get(i) != null)
        continue;
      print("\nSwing(", i, ") = ", getSwing(i));
    }
    print("\n");
    
    for (int i = 0; i < Hv.size(); i++)
    {
      if (deletedVertices.get(i) != null)
        continue;
        
      print("\nAll Vertices connected to V", i, " : ");
      int[] allVertices = getAllVerticesFromVertex(i);
      for (int j = 0; j < allVertices.length; j++)
        print(allVertices[j], " | "); 
    }
  }
  
  int getNumVertices()
  {
    return G.size();
  }
  
  int[] getAllVerticesInFace(int faceIndex)
  {
    ArrayList<Integer> vertexIndices = new ArrayList<Integer>();
    int[] halfEdges = getAllHalfEdgesInFace(faceIndex);
    
    for (int i = 0; i < halfEdges.length; i++)
    {
      vertexIndices.add(V.get(halfEdges[i]));
    }
    
    int[] vertices = new int[vertexIndices.size()];
    for (int i = 0; i < vertexIndices.size(); i++)
    {
      vertices[i] = vertexIndices.get(i);
    }
    return vertices;
  }
  
  Vertex getCentroid(int[] vertices)
  {
    float xAvg = 0.0;
    float yAvg = 0.0;
    for (int i = 0; i < vertices.length; i++)
    {
      xAvg += G.get(vertices[i]).x;
      yAvg += G.get(vertices[i]).y;
    }
    xAvg /= vertices.length;
    yAvg /= vertices.length;
    
    return new Vertex(xAvg, yAvg);
  }
  
  float getFaceArea(int faceIndex)
  {
    int temp, i=0, j=0;
    float area = 0.0;
    int[] vertexList = getAllVerticesInFace(faceIndex);
    ArrayList<Vertex> vertices = new ArrayList(vertexList.length);
    
    for(int index = 0; index <vertexList.length; index++) 
    {  
      vertices.add(G.get(vertexList[index]));  
    }
    
    Vertex first = vertices.get(0);
    Vertex last = vertices.get(vertices.size() - 1);
    
    for (j = 0; j < vertices.size() - 1; j++)
    {
      Vertex cur = vertices.get(j);
      Vertex next = vertices.get(j+1);   
      area += cur.x * next.y - cur.y * next.x;
    }
    area += last.x * first.y -  last.y * first.x;
    area /= 2.0;  
    return abs(area);   
  }
  
  int getOuterFace()
  {
    float maxArea = 0.0;
    int outerFace = -1;
    for (int i = 0; i < Hf.size(); i++)
      {
        int[] vertices = getAllVerticesInFace(i);
        Vertex centroid = getCentroid(vertices);
        float faceArea = getFaceArea(i);
        if (faceArea > maxArea)
        {
          outerFace = i;
          maxArea = faceArea;
        }
      }
      return outerFace;
  }
  
  ArrayList<Vertex> _getCornerPos(int halfEdgeIndex1)
  {
    
    ArrayList<Vertex> cornerPos = new ArrayList<Vertex>();
    
    int halfEdgeIndex2 = getSwing(halfEdgeIndex1);
    
    int vIndex = V.get(halfEdgeIndex1);
    Vector2d hVec1 = getVectorFromHalfEdge(halfEdgeIndex1);
    Vector2d hVec2 = getVectorFromHalfEdge(halfEdgeIndex2);
    float s = cornerOffset / det(hVec1.normalize(), hVec2.normalize());
    
    if (det(hVec1.normalize(), hVec2.normalize()) != 0)
      cornerPos.add(P(G.get(vIndex), s, hVec1.normalize().add(hVec2.normalize())));
    
    //If we're dealing with dangling edges
    else
    {
      s = 8;
      cornerPos.add(P(G.get(vIndex), s, R(hVec1.normalize().add(hVec2.normalize()), PI/2.0)));
      cornerPos.add(P(G.get(vIndex), -s, R(hVec1.normalize().add(hVec2.normalize()), PI/2.0)));
    }
    
    return cornerPos;
  }
  
  
  void render(boolean renderHalfEdges, boolean renderCorners, boolean renderFaces, boolean showArea, boolean showVertexIndices)
  { 
    
    //Optionally render faces
    if (renderFaces)
    {
      stroke(green);
      strokeWeight(5);
      float zmin = 0;
      float zmax = Hf.size();
      for (int i = 0; i < Hf.size(); i++)
      {
        float colorTap = (i - zmin)/(zmax - zmin); 
        stroke(colorTap * 256 , (1.0 - colorTap) * 256, sq(sq(1.0 - abs(0.5 - colorTap))) * 200); 
        
        int[] halfEdges = getAllHalfEdgesInFace(i);
        for (int j = 0; j < halfEdges.length; j++)
        {
          
          int halfEdgeIndex = halfEdges[j];
          ArrayList<Vertex> cornerPos = _getCornerPos(halfEdgeIndex);

          Vertex corner = cornerPos.get(0);
          //If it's a dangling edge, draw a nice arc going from first corner to next
          if (cornerPos.size() == 2)
          {
            Vertex pivot = G.get(V.get(halfEdgeIndex));
            Vector2d cornerVec = new Vector2d(corner.x, corner.y);
            Vector2d pivotVec = new Vector2d(pivot.x, pivot.y);
            Vector2d sweepVec = cornerVec.sub(pivotVec);

            for (int k = 0; k < 6; k++)
            {
              Vertex segPoint1 = P(pivot, 1, R(sweepVec, k * PI / 6));
              Vertex segPoint2 = P(pivot, 1, R(sweepVec, (k + 1) * PI / 6));
              line(segPoint1.x, segPoint1.y, segPoint2.x, segPoint2.y);
            }
            corner = cornerPos.get(1);
            Vertex prevCorner = _getCornerPos(O.get(halfEdgeIndex)).get(0);
            line(prevCorner.x, prevCorner.y, corner.x, corner.y);
          }
          
          //Else join consecutive corners
          else
          {
            Vertex nextCorner = _getCornerPos(getPrevHalfEdgeIndex(halfEdgeIndex)).get(0);
            line(corner.x, corner.y, nextCorner.x, nextCorner.y);
          }
        }
      }
    }
    
    //Render Edges. We're going to query our V table for this.
    stroke(grey);
    strokeWeight(3);
    for (int i = 0; i < V.size(); i++)
    {
      if (deletedHalfEdges.get(i) != null)
        continue;
      int vIndex1 = V.get(i);
      int vIndex2 = V.get(N.get(i));
      line(G.get(vIndex1).x, G.get(vIndex1).y, G.get(vIndex2).x, G.get(vIndex2).y);
    }
    
    //Render Vertices
    stroke(blue);
    
    for (int i = 0; i < G.size(); i++)
    {
      if (deletedVertices.get(i) != null)
        continue;
      Vertex v = G.get(i);
      //v.label(Integer.toString(i));
      fill(white);
      strokeWeight(3);
      ellipse(v.x, v.y, 15, 15);
      
      if (showVertexIndices)
      {
        fill(black);
        text(Integer.toString(i), v.x - 5, v.y + 5);
      }
    }
    
    //Optionally render half-edges
    if (renderHalfEdges)
    {
      if (V.size() == 0)
        return;
      
      stroke(red);
      strokeWeight(1);
      
      for (int i = 0; i < V.size(); i++)
      {
        if (deletedHalfEdges.get(i) != null)
          continue;
        Vector2d A = new Vector2d(G.get(V.get(i)).x, G.get(V.get(i)).y);
        Vector2d B = new Vector2d(G.get(V.get(N.get(i))).x, G.get(V.get(N.get(i))).y);
        Vector2d edgeVec = B.sub(A);
        
        Vertex shiftedSource = new Vertex(G.get(V.get(i)).x, G.get(V.get(i)).y);
        shiftedSource.x -= halfEdgeOffset * cos(atan2(-edgeVec.x, edgeVec.y));
        shiftedSource.y -= halfEdgeOffset * sin(atan2(-edgeVec.x, edgeVec.y));
        shiftedSource.x += 0.15 * edgeVec.norm() * cos(atan2(edgeVec.y, edgeVec.x));
        shiftedSource.y += 0.15 * edgeVec.norm() * sin(atan2(edgeVec.y, edgeVec.x));
        
        edgeVec = edgeVec.scaleBy(0.7);
        arrow(shiftedSource, edgeVec, Integer.toString(i));
        Vertex v1 = G.get(V.get(i));
        Vertex v2 = G.get(V.get(N.get(V.get(i))));
      }
    }
    
    //Optionally render corners
    if (renderCorners)
    {
      stroke(blue_true);
      fill(blue);
      strokeWeight(1);
      
      //Iterate through all vertices and get all half-edges coming out of each
      for (int vIndex : G.keySet())
      {
        if (deletedVertices.get(vIndex) != null)
          continue;
        int[] halfEdges = getAllHalfEdgesFromVertex(vIndex);
        for (int i = 0; i < halfEdges.length; i++)
        {
          int halfEdge = halfEdges[i];
          
          ArrayList<Vertex> cornerPos = _getCornerPos(halfEdge);
          
          for (int j = 0; j < cornerPos.size(); j++)
            show(cornerPos.get(j), 3);
        }
      }
    }
    
    if (showArea)
    {
      strokeWeight(2);
      for (int i = 0; i < Hf.size(); i++)
      {
        if (i == getOuterFace())
          continue;
        int[] vertices = getAllVerticesInFace(i);
        Vertex centroid = getCentroid(vertices);
        float faceArea = getFaceArea(i);
        fill(black);
        stroke(black);
        text("Face (" + i + ") Area : " + Float.toString(faceArea), centroid.x - 50, centroid.y);
      }
    }
    
  }
}
