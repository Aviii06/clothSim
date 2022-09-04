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
float structSpringConst = 0.5;
float shearSpringConst = 10;

//Damp
float damp = 2;


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
    pos[0][0] = new PVector((-gridSize/2) * springNaturalLength + 50, (-gridSize/2) * springNaturalLength );
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
    
    drawGrid(pos, ellipseRadius); //Drawing the grid
    
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
