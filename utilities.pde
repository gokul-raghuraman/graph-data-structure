float getTriangleArea(Vertex v1, Vertex v2, Vertex v3)
{
  //Area = 1/2*(-v2y*v3x + v1y*(-v2x + v3x) + v1x*(v2y - v3y) + v2x*v3y);
  float area = (float) 0.5 * (float)( -v2.y * v3.x + v1.y * (-v2.x + v3.x) + v1.x * (v2.y - v3.y) + v2.x * v3.y);
  return area;
}

boolean isPointInTriangle(Vertex v, Vertex v1, Vertex v2, Vertex v3)
{
  //Query if vertex v is in triangle v1-v2-v3
  float s = ((v2.y - v3.y) * (v.x - v3.x) + (v3.x - v2.x) * (v.y - v3.y)) / ((v2.y - v3.y) * (v1.x - v3.x) + (v3.x - v2.x) * (v1.y - v3.y));
  float t = ((v3.y - v1.y) * (v.x - v3.x) + (v1.x - v3.x) * (v.y - v3.y)) / ((v2.y - v3.y) * (v1.x - v3.x) + (v3.x - v2.x) * (v1.y - v3.y));
  boolean pointInTriangle = ((s > 0) && (t > 0) && (1.0 - s - t > 0));
  return pointInTriangle;
}
