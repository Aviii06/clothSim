//Grid Specifications
int gridSize = 10;
int springNaturalLength = 50;
float scaleFactor = 10;
PVector structSpringColor = new PVector(255,10,0);
PVector shearSpringColor = new PVector(10,255,58);


//Spring Properties
float structSpringConst = 50;
float shearSpringConst = 5;

//Damp
float damp = 2;

//Const force in x direction on one element
final PVector constForce1 = new PVector(0, -500,0);
final PVector constForce2 = new PVector(0, -250,0);
final PVector constForce3 = new PVector(0, -125,0);
final PVector constForce4 = new PVector(0, -75,0);
Point[][] point = new Point[gridSize][gridSize];
float currTime = 0;
float delTime = 0.05;
PVector gravity = new PVector(0, 200);

void setup(){
    size(1200, 1200);
    //Initially setting up the grid and giving velocites
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            PVector initialPos = new PVector((i-gridSize/2) * springNaturalLength, (j-gridSize/2) * springNaturalLength);
            PVector initialVel = new PVector(0, 0, 0);
            PVector initialForce = new PVector(0,0,0);
            float mass = 1;
    
            point[i][j] = new Point(initialPos, initialVel, initialForce, mass);
        }
    }

    //Small perturbation in one of the masses
    //pos[0][0] = new PVector((-gridSize/2) * springNaturalLength + 50, (-gridSize/2) * springNaturalLength );
}

void draw(){
    currTime += delTime;
    background(0);
    translate(width/2, height/3);
    // calculating and storing forces
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            if (i == gridSize - 1){
                point[i][j].changeForce(new PVector(0,0));
                continue;
            }
            point[i][j].changeForce(calcForce(i, j)); 
            point[i][j].addForce(gravity.mult(point[i][j].getMass()));
        }
    }
    if(currTime < 5){
        point[0][0].addForce(constForce1);
        point[1][0].addForce(constForce2);
        point[2][0].addForce(constForce3);
        point[3][0].addForce(constForce4);
        arrowLine(point[0][0], constForce1,radians(0), radians(60));
        arrowLine(point[1][0], constForce2,radians(0), radians(60));
        arrowLine(point[2][0], constForce3,radians(0), radians(60));
        arrowLine(point[3][0], constForce4,radians(0), radians(60));
    }
    
    drawGrid(point); //Drawing the grid
    //Updating Positions
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            point[i][j].sim();
        }
    }
}

void drawGrid(Point[][] point){
    //Drawing the Springs
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            for(int k = -1; k <= 1; k++){
                for(int l = -1; l <= 1; l++){
                    if(i + k < 0 || j + l < 0 || i + k == gridSize || j + l == gridSize) {
                        continue;
                    }
                    
                    //Shear Spring
                    if(k*k + l*l == 2){
                        stroke(shearSpringColor.x, shearSpringColor.y, shearSpringColor.z);
                    }
                    //Structure Spring
                    else{
                        stroke(structSpringColor.x, structSpringColor.y, structSpringColor.z);
                    }
                    line(point[i+k][j+l].getPos().x, point[i+k][j+l].getPos().y, point[i][j].getPos().x, point[i][j].getPos().y);
                    stroke(255);
                }
            }         
        }
    }

    //Drawing the Masses
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            float rad = point[i][j].getMass() * scaleFactor;
            ellipse(point[i][j].getPos().x, point[i][j].getPos().y, rad, rad);
        }
    }
}

PVector calcForce(int i, int j){
    PVector force = new PVector(0,0);
    PVector displacement = new PVector(0,0);
    
    // Iterating through neighbours
    for(int k = -1; k <= 1; k++){
        for(int l = -1; l <= 1; l++){
            if(i + k < 0 || j + l < 0 || i + k == gridSize || j + l == gridSize) {
                continue;
            }
            
            PVector currDisp = new PVector(point[i + k][j + l].getPos().x, point[i+k][j+l].getPos().y);
            currDisp.sub(point[i][j].getPos());
            
            float distance = currDisp.mag();
            PVector direction = currDisp.normalize();
            
            float dx = distance - springNaturalLength * sqrt(k*k + l*l);
            displacement = direction.mult(dx);
            
            //Shear Spring
            if(l*l + k*k == 2){
                force.add(displacement.x * shearSpringConst, displacement.y * shearSpringConst);    
            }
            //Structure Spring
            else{
                force.add(displacement.x * structSpringConst, displacement.y * structSpringConst); 
            } 
        }
    }
 
    //Damping force
    force.sub(point[i][j].getVel().z * damp, point[i][j].getVel().y * damp);

    return force;
}

// Used arrowhead lines from https://openprocessing.org/sketch/7029/#
/*
 * Draws a lines with arrows of the given angles at the ends.
 * x0 - starting x-coordinate of line
 * y0 - starting y-coordinate of line
 * x1 - ending x-coordinate of line
 * y1 - ending y-coordinate of line
 * startAngle - angle of arrow at start of line (in radians)
 * endAngle - angle of arrow at end of line (in radians)
 * solid - true for a solid arrow; false for an "open" arrow
 */
void arrowLine(Point point,PVector constForce,float startAngle, float endAngle)
{
    float x0 = point.getPos().x;
    float y0 = point.getPos().y;
    float x1 = x0 + constForce.x / scaleFactor;
    float y1 = y0 + constForce.y / scaleFactor;
    line(x0, y0, x1, y1);
    if (startAngle != 0)
    {
      arrowhead(x0, y0, atan2(y1 - y0, x1 - x0), startAngle);
    }
    if (endAngle != 0)
    {
      arrowhead(x1, y1, atan2(y0 - y1, x0 - x1), endAngle);
    }
}

/*
 * Draws an arrow head at given location
 * x0 - arrow vertex x-coordinate
 * y0 - arrow vertex y-coordinate
 * lineAngle - angle of line leading to vertex (radians)
 * arrowAngle - angle between arrow and line (radians)
 * solid - true for a solid arrow, false for an "open" arrow
 */
void arrowhead(float x0, float y0, float lineAngle,
  float arrowAngle)
{
    float x2;
    float y2;
    float x3;
    float y3;
    final float SIZE = 10;
    
    x2 = x0 + SIZE * cos(lineAngle + arrowAngle);
    y2 = y0 + SIZE * sin(lineAngle + arrowAngle);
    x3 = x0 + SIZE * cos(lineAngle - arrowAngle);
    y3 = y0 + SIZE * sin(lineAngle - arrowAngle);
    
    triangle(x0, y0, x2, y2, x3, y3);
}
