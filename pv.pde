//*****************************************************************************
// TITLE:         GEOMETRY UTILITIES IN 2D  
// DESCRIVertexION:   Classes and functions for manipulating points, vectors, edges, triangles, quads, frames, and circular arcs  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  SeVertexember 2009
// EDITS:         Revised July 2011
//*****************************************************************************
//************************************************************************
//**** POINT CLASS
//************************************************************************
class Vertex { float x=0,y=0; 
  // CREATE
  Vertex () {}
  Vertex (float px, float py) {x = px; y = py;};

  // MODIFY
  Vertex setTo(float px, float py) {x = px; y = py; return this;};  
  Vertex setTo(Vertex P) {x = P.x; y = P.y; return this;}; 
  Vertex setToMouse() { x = mouseX; y = mouseY;  return this;}; 
  Vertex add(float u, float v) {x += u; y += v; return this;}                       // P.add(u,v): P+=<u,v>
  Vertex add(Vertex P) {x += P.x; y += P.y; return this;};                              // incorrect notation, but useful for computing weighted averages
  Vertex add(float s, Vertex P)   {x += s*P.x; y += s*P.y; return this;};               // adds s*P
  Vertex add(Vector2d V) {x += V.x; y += V.y; return this;}                              // P.add(V): P+=V
  Vertex add(float s, Vector2d V) {x += s*V.x; y += s*V.y; return this;}                 // P.add(s,V): P+=sV
  Vertex translateTowards(float s, Vertex P) {x+=s*(P.x-x);  y+=s*(P.y-y);  return this;};  // transalte by ratio s towards P
  Vertex scale(float u, float v) {x*=u; y*=v; return this;};
  Vertex scale(float s) {x*=s; y*=s; return this;}                                  // P.scale(s): P*=s
  Vertex scale(float s, Vertex C) {x*=C.x+s*(x-C.x); y*=C.y+s*(y-C.y); return this;}    // P.scale(s,C): scales wrt C: P=L(C,P,s);
  Vertex rotate(float a) {float dx=x, dy=y, c=cos(a), s=sin(a); x=c*dx+s*dy; y=-s*dx+c*dy; return this;};     // P.rotate(a): rotate P around origin by angle a in radians
  Vertex rotate(float a, Vertex G) {float dx=x-G.x, dy=y-G.y, c=cos(a), s=sin(a); x=G.x+c*dx+s*dy; y=G.y-s*dx+c*dy; return this;};   // P.rotate(a,G): rotate P around G by angle a in radians
  Vertex rotate(float s, float t, Vertex G) {float dx=x-G.x, dy=y-G.y; dx-=dy*t; dy+=dx*s; dx-=dy*t; x=G.x+dx; y=G.y+dy;  return this;};   // fast rotate s=sin(a); t=tan(a/2); 
  Vertex moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY;  return this;}; 
     
  // DRAW , WRITE
  Vertex write() {print("("+x+","+y+")"); return this;};  // writes point coordinates in text window
  Vertex v() {vertex(x,y); return this;};  // used for drawing polygons between beginShape(); and endShape();
  Vertex show(float r) {ellipse(x, y, 2*r, 2*r); return this;}; // shows point as disk of radius r
  Vertex show() {show(3); return this;}; // shows point as small dot
  Vertex label(String s, float u, float v) {fill(black); text(s, x+u, y+v); noFill(); return this; };
  Vertex label(String s, Vector2d V) {fill(black); text(s, x+V.x, y+V.y); noFill(); return this; };
  Vertex label(String s) {label(s,5,4); return this; };
  } // end of Vertex class

//************************************************************************
//**** VECTORS
//************************************************************************
class Vector2d { float x=0,y=0; 
 // CREATE
  Vector2d () {};
  Vector2d (float px, float py) {x = px; y = py;};
 
 // MODIFY
  Vector2d setTo(float px, float py) {x = px; y = py; return this;}; 
  Vector2d setTo(Vector2d V) {x = V.x; y = V.y; return this;}; 
  Vector2d zero() {x=0; y=0; return this;}
  Vector2d scaleBy(float u, float v) {x*=u; y*=v; return this;};
  Vector2d scaleBy(float f) {x*=f; y*=f; return this;};
  Vector2d reverse() {x=-x; y=-y; return this;};
  Vector2d divideBy(float f) {x/=f; y/=f; return this;};
  Vector2d normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;}; return this;};
  Vector2d add(float u, float v) {x += u; y += v; return this;};
  Vector2d add(Vector2d V) {x += V.x; y += V.y; return this;};   
  Vector2d add(float s, Vector2d V) {x += s*V.x; y += s*V.y; return this;};
  Vector2d sub(Vector2d V) {x -= V.x; y -= V.y; return this;};  
  Vector2d rotateBy(float a) {float xx=x, yy=y; x=xx*cos(a)-yy*sin(a); y=xx*sin(a)+yy*cos(a); return this;};
  Vector2d left() {float m=x; x=-y; y=m; return this;}; // turns vector left
  //Vector2d shiftRight(float dist) { x += dist * cos(atan2(-x, y)); y += dist * sin(atan2(-x, y)); return this;};
  
  
  // OUTPUT VEC
  Vector2d clone() {return(new Vector2d(x,y));}; 

  // OUTPUT TEST MEASURE
  float norm() {return(sqrt(sq(x)+sq(y)));}
  boolean isNull() {return((abs(x)+abs(y)<0.000001));}
  float angle() {return(atan2(y,x)); }

  // DRAW, PRINT
  void write() {println("<"+x+","+y+">");};
  void showAt (Vertex P) {line(P.x,P.y,P.x+x,P.y+y); }; 
  void showArrowAt (Vertex P) {line(P.x,P.y,P.x+x,P.y+y); 
      float n=min(this.norm()/10.,height/50.); 
      Vertex Q=P(P,this); 
      Vector2d U = S(-n,U(this));
      Vector2d W = S(.3,R(U)); 
      beginShape(); Q.add(U).add(W).v(); Q.v(); Q.add(U).add(M(W)).v(); endShape(CLOSE); }; 
  void label(String s, Vertex P) {P(P).add(0.5,this).add(3,R(U(this))).label(s); };
  } // end vec class

//************************************************************************
//**** POINTS
//************************************************************************
// create 
Vertex P() {return P(0,0); };                                                                            // make point (0,0)
Vertex P(float x, float y) {return new Vertex(x,y); };                                                       // make point (x,y)
Vertex P(Vertex P) {return P(P.x,P.y); };                                                                    // make copy of point A
Vertex Mouse() {return P(mouseX,mouseY);};                                                                 // returns point at current mouse location
Vertex Pmouse() {return P(pmouseX,pmouseY);};                                                              // returns point at previous mouse location
Vertex ScreenCenter() {return P(width/2,height/2);}                                                        //  point in center of  canvas

// display 
void show(Vertex P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                             // draws circle of center r around P
void show(Vertex P) {ellipse(P.x, P.y, 6,6);};                                                           // draws small circle around point
void edge(Vertex P, Vertex Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
void arrow(Vertex P, Vertex Q) {arrow(P,V(P,Q)); }                                                            // draws arrow from P to Q
void label(Vertex P, String S) {text(S, P.x-4,P.y+6.5); }                                                 // writes string S next to P on the screen ( for example label(P[i],str(i));)
void label(Vertex P, Vector2d V, String S) {text(S, P.x-3.5+V.x,P.y+7+V.y); }                                  // writes string S at P+V
void v(Vertex P) {vertex(P.x,P.y);};                                                                      // vertex for drawing polygons between beginShape() and endShape()
void show(Vertex P, Vertex Q, Vertex R) {beginShape(); v(P); v(Q); v(R); endShape(CLOSE); };                      // draws triangle 

// transform 
Vertex R(Vertex Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return new Vertex(c*dx+s*dy,-s*dx+c*dy); };  // Q rotated by angle a around the origin
Vertex R(Vertex Q, float a, Vertex C) {float dx=Q.x-C.x, dy=Q.y-C.y, c=cos(a), s=sin(a); return P(C.x+c*dx-s*dy, C.y+s*dx+c*dy); };  // Q rotated by angle a around point P
Vertex P(Vertex P, Vector2d V) {return P(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vector V)
Vertex P(Vertex P, float s, Vector2d V) {return P(P,W(s,V)); }                                                    //  P+sV (P transalted by sV)
Vertex MoveByDistanceTowards(Vertex P, float d, Vertex Q) { return P(P,d,U(V(P,Q))); };                          //  P+dU(PQ) (transLAted P by *distance* s towards Q)!!!

// average 
Vertex P(Vertex A, Vertex B) {return P((A.x+B.x)/2.0,(A.y+B.y)/2.0); };                                          // (A+B)/2 (average)
Vertex P(Vertex A, Vertex B, Vertex C) {return P((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0); };                            // (A+B+C)/3 (average)
Vertex P(Vertex A, Vertex B, Vertex C, Vertex D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4 (average)

// weighted average 
Vertex P(float a, Vertex A) {return P(a*A.x,a*A.y);}                                                      // aA  
Vertex P(float a, Vertex A, float b, Vertex B) {return P(a*A.x+b*B.x,a*A.y+b*B.y);}                              // aA+bB, (a+b=1) 
Vertex P(float a, Vertex A, float b, Vertex B, float c, Vertex C) {return P(a*A.x+b*B.x+c*C.x,a*A.y+b*B.y+c*C.y);}   // aA+bB+cC 
Vertex P(float a, Vertex A, float b, Vertex B, float c, Vertex C, float d, Vertex D){return P(a*A.x+b*B.x+c*C.x+d*D.x,a*A.y+b*B.y+c*C.y+d*D.y);} // aA+bB+cC+dD 
     
// barycentric coordinates and transformations
float m(Vertex A, Vertex B, Vertex C) {return (B.x-A.x)*(C.y-A.y) - (B.y-A.y)*(C.x-A.x); }
float a(Vertex P, Vertex A, Vertex B, Vertex C) {return m(P,B,C)/m(A,B,C); }
float b(Vertex P, Vertex A, Vertex B, Vertex C) {return m(A,P,C)/m(A,B,C); }
float c(Vertex P, Vertex A, Vertex B, Vertex C) {return m(A,B,P)/m(A,B,C); }

// measure 
boolean isSame(Vertex A, Vertex B) {return (A.x==B.x)&&(A.y==B.y) ;}                                         // A==B
boolean isSame(Vertex A, Vertex B, float e) {return ((abs(A.x-B.x)<e)&&(abs(A.y-B.y)<e));}                   // ||A-B||<e
float d(Vertex P, Vertex Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| (Distance)
float d2(Vertex P, Vertex Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

//************************************************************************
//**** VECTORS
//************************************************************************
// create 
Vector2d V(Vector2d V) {return new Vector2d(V.x,V.y); };                                                             // make copy of vector V
Vector2d V(Vertex P) {return new Vector2d(P.x,P.y); };                                                              // make vector from origin to P
Vector2d V(float x, float y) {return new Vector2d(x,y); };                                                      // make vector (x,y)
Vector2d V(Vertex P, Vertex Q) {return new Vector2d(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vector Q-P from P to Q
Vector2d U(Vector2d V) {float n = n(V); if (n==0) return new Vector2d(0,0); else return new Vector2d(V.x/n,V.y/n);};      // V/||V|| (Unit vector : normalized version of V)
Vector2d U(Vertex P, Vertex Q) {return U(V(P,Q));};                                                                // PQ/||PQ| (Unit vector : from P towards Q)
Vector2d MouseDrag() {return new Vector2d(mouseX-pmouseX,mouseY-pmouseY);};                                      // vector representing recent mouse displacement

// display 
void show(Vertex P, Vector2d V) {line(P.x,P.y,P.x+V.x,P.y+V.y); }                                              // show V as line-segment from P 
void show(Vertex P, float s, Vector2d V) {show(P,S(s,V));}                                                     // show sV as line-segment from P 
void arrow(Vertex P, float s, Vector2d V) {arrow(P,S(s,V));}                                                   // show sV as arrow from P 
void arrow(Vertex P, Vector2d V, String S) {arrow(P,V); P(P(P,0.70,V),15,R(U(V))).label(S,V(-5,4));}       // show V as arrow from P and print string S on its side
void arrow(Vertex P, Vector2d V) {show(P,V);  float n=n(V); if(n<0.01) return; float s=max(min(0.05,20/n),6/n);       // show V as arrow from P 
     Vertex Q=P(P,V); Vector2d U = S(-s,V); Vector2d W = R(S(.3,U)); fill(red); beginShape(); v(P(P(Q,U),W)); v(Q); v(P(P(Q,U),-1,W)); endShape(CLOSE);}; 

// weighted sum 
Vector2d W(float s,Vector2d V) {return V(s*V.x,s*V.y);}                                                      // sV
Vector2d W(Vector2d U, Vector2d V) {return V(U.x+V.x,U.y+V.y);}                                                   // U+V 
Vector2d W(Vector2d U,float s,Vector2d V) {return W(U,S(s,V));}                                                   // U+sV
Vector2d W(float u, Vector2d U, float v, Vector2d V) {return W(S(u,U),S(v,V));}                                   // uU+vV ( Linear combination)

// transformed 
Vector2d R(Vector2d V) {return new Vector2d(-V.y,V.x);};                                                             // V turned right 90 degrees (as seen on screen)
Vector2d R(Vector2d V, float a) {float c=cos(a), s=sin(a); return(new Vector2d(V.x*c-V.y*s,V.x*s+V.y*c)); };                                     // V rotated by a radians
Vector2d S(float s, Vector2d V) {return new Vector2d(s*V.x,s*V.y);};                                                  // sV
Vector2d Reflection(Vector2d V, Vector2d N) { return W(V,-2.*dot(V,N),N);};                                          // reflection
Vector2d M(Vector2d V) { return V(-V.x,-V.y); }                                                                  // -V


// measure 
float dot(Vector2d U, Vector2d V) {return U.x*V.x+U.y*V.y; }                                                     // dot(U,V): U*V (dot product U*V)
float det(Vector2d U, Vector2d V) {return U.x*V.y-U.y*V.x; }                                                         // det | U V | = scalar cross UxV 
float n(Vector2d V) {return sqrt(dot(V,V));};                                                               // n(V): ||V|| (norm: length of V)
float n2(Vector2d V) {return dot(V,V);};                                                             // n2(V): V*V (norm squared)
boolean parallel (Vector2d U, Vector2d V) {return dot(U,R(V))==0; }; 

float angle (Vector2d U, Vector2d V) {return atan2(det(U,V),dot(U,V)); };                                   // angle <U,V> (between -PI and PI)
float angle(Vector2d V) {return(atan2(V.y,V.x)); };                                                       // angle between <1,0> and V (between -PI and PI)
float angle(Vertex A, Vertex B, Vertex C) {return  angle(V(B,A),V(B,C)); }                                       // angle <BA,BC>
float turnAngle(Vertex A, Vertex B, Vertex C) {return  angle(V(A,B),V(B,C)); }                                   // angle <AB,BC> (positive when right turn as seen on screen)
int toDeg(float a) {return int(a*180/PI);}                                                           // convert radians to degrees
float toRad(float a) {return(a*PI/180);}                                                             // convert degrees to radians 
float positive(float a) { if(a<0) return a+TWO_PI; else return a;}                                   // adds 2PI to make angle positive


//************************************************************************
//**** INTERPOLATION
//************************************************************************
// LERP
Vertex L(Vertex A, Vertex B, float t) {return P(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y));}

