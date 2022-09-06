class Point{
    PVector pos, vel, force;
    float mass;
 
    Point(PVector pos, PVector vel, PVector force, float mass){
        this.pos = pos;
        this.vel = vel;
        this.force = force;
        this.mass = mass;
    }

    void changeForce(PVector force){
        this.force = force;
    }

    void addForce(PVector force){
        this.force = this.force.add(force);
    }

    void sim(){
        this.vel = this.vel.add(force.mult(delTime));
        this.pos = this.pos.add(vel.mult(delTime));
    }

    PVector getPos(){
        return this.pos;
    }

    PVector getVel(){
        return this.vel;
    }

    PVector getForce(){
        return this.force;
    }
    
    float getMass(){
        return this.mass;
    }
};
