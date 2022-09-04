//Mass
float mass = 1;

//Grid Specifications
int gridSize = 5;
int springNaturalLength = 100;
float ellipseRadius = 10 * mass;
PVector structSpringColor = new PVector(255,10,0);
PVector shearSpringColor = new PVector(10,255,58);

//Simulation Variables
PVector[][] pos = new PVector[gridSize][gridSize];
PVector[][] vel = new PVector[gridSize][gridSize];
PVector[][] force = new PVector[gridSize][gridSize];
float delTime = 0.05;

//Spring Properties
float structSpringConst = 3;
float shearSpringConst = 0.5;

//Damp
float damp = 2;

//Const force in x direction on one element
final PVector constForce = new PVector(0, -100,0);

void setup(){
    size(1200, 1200);
    //Initially setting up the grid and giving velocites
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            pos[i][j] = new PVector((i-gridSize/2) * springNaturalLength, (j-gridSize/2) * springNaturalLength);
            vel[i][j] = new PVector(0, 0, 0);
        }
    }

    //Small perturbation in one of the masses
    //pos[0][0] = new PVector((-gridSize/2) * springNaturalLength + 50, (-gridSize/2) * springNaturalLength );
}

void draw(){
    background(0);
    translate(width/2, height/2);
    // calculating and storing forces
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            if (i == gridSize - 1){
                force[i][j] = new PVector(0,0);
                continue;
            }
            force[i][j] = calcForce(i, j); 
        }
    }
    force[0][0] = force[0][0].add(constForce);
    drawGrid(pos, ellipseRadius); //Drawing the grid
    arrowLine(pos[0][0].x, pos[0][0].y, pos[0][0].x + constForce.x, pos[0][0].y + constForce.y, radians(0), radians(60));
    //Updating Positions
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
            vel[i][j].add(force[i][j].x * delTime / mass, force[i][j].y * delTime / mass);
            pos[i][j].add(vel[i][j].x * delTime, vel[i][j].y * delTime);
        }
    }
}

void drawGrid(PVector[][] pos, float rad){
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
                    line(pos[i+k][j+l].x, pos[i+k][j+l].y, pos[i][j].x, pos[i][j].y);
                    stroke(255);
                }
            }         
        }
    }

    //Drawing the Masses
    for(int i = 0; i < gridSize; i++){
        for(int j = 0; j < gridSize; j++){
                ellipse(pos[i][j].x, pos[i][j].y, rad, rad);
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
            
            PVector currDisp = new PVector(pos[i + k][j + l].x, pos[i+k][j+l].y);
            currDisp.sub(pos[i][j]);
            
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
    force.sub(vel[i][j].z * damp, vel[i][j].y * damp);

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
void arrowLine(float x0, float y0, float x1, float y1,
  float startAngle, float endAngle)
{
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
