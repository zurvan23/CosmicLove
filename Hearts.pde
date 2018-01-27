class Heart {

  // taken from the PVector Mover example:
  PVector location; // location of hearts
  PVector velocity; // speed of hearts
  PVector acceleration; // acceleration of hearts
  PVector mouse; // one of the possible targets
  float topspeed; // topspeed of hearts


  // added by me: 
  PVector drag; // decelleration when hearts approach target;
  PVector wander; // wandering targets for heart
  PVector target; // targets of hearts, can be from 'mouse' or 'wander'
  PVector distance; // distance between hearts and target, used to initiate drag
  float mouseDistance; // to calculate max distance from mouse for attraction to apply, to make attraction a bit more playful and realistic

  // some booleans to turn on and off heart movements and targeting:
  boolean mouseMove, mouseLock, heartMove, heartBirth, hitCounterStart;


  // random rest time of hearts, at one point I wanted to implement a color shift to black (as if the hearts where hiding in the white), but I left that out for now:
  int restTime, restCounter, randomWanderTime, randomWanderCounter;


  int hitCounter, hitTime;

  PVector nearestHeart; 

  // sometimes the hearts get stuck in an orbit around their target, theirfore they have to change their target sometimes:
  int changeDirTime, changeDirCounter;
  boolean nearestMax;

  // after some time the flocking hearts find a balance and stop moving around, therefore sometimes they also need to be scattered:
  int scatterTime, scatterCounter;

  // giving the hearts a short delay to realize they are with too many around:
  int nearTime, nearCounter;

  // giving the hearts a short delay to realize the mouse is moving:
  int mouseTime, mouseCounter;

  float heartRotate;

  // Creating hearts to shoot
  PShape heart0;
  float heartSize;

  // The class:
  Heart() {

    // setting some initial values for vectors and variables:
    topspeed = 3.0;
    location = new PVector(random(-width, width*2), random(-height, height * 2));
    velocity = new PVector(random(topspeed), random(topspeed));
    mouse = new PVector(random(width), random(height));
    wander = new PVector(random(width), random(height));
    target = wander;
    restTime = (int) random(100, 500);
    restCounter = 0;
    changeDirTime = (int) random(150, 350);
    changeDirCounter = 0;
    distance = PVector.sub(target, location);
    nearestHeart = new PVector(random(width), random(height));
    nearestMax = false;
    scatterTime = (int) random(500, 1000);  
    scatterCounter = 0;
    nearTime = 180;
    nearCounter = 0;
    mouseTime = 300;
    mouseCounter = 0;
    mouseDistance = PVector.dist(mouse, location);
    mouseMove = false;
    mouseLock = false;
    heartMove = false;
    heartBirth = true;
    hitTime = 100;
    heartSize = 70;

    // Loading heart vector images:
    heart0 = loadShape("Heart.svg");
  }

  void update() {


    topspeed = 180/frameRate; // figured as the framerate drops at a certain point, its wise to have the topspeed be depended on this, otherwise hitting hearts becomes very easy too soon

    // when initialized, hearts get a random target where they move to directly, preventing being an easy target for the mouse at the beginning:
    if (heartBirth == true) {
      location = new PVector(mouseX, mouseY);    

      wander.x =  random(width);
      wander.y =  random(height);

      target = wander;

      // random topspeed to anywhere:
      velocity = new PVector(random(-topspeed, topspeed), random(-topspeed, topspeed));

      hitCounterStart = true;

      heartBirth = false;
    }



    // after all the primary birth behaviour, we get into the following states:

    mouse.x = mouseX;
    mouse.y = mouseY;

    mouseDistance = PVector.dist(mouse, location);

    // boolean for mouse movement:
    if (mouseX == pmouseX && mouseY == pmouseY)
      mouseMove = false;
    if (mouseX != pmouseX || mouseY != pmouseY)
      mouseMove = true;

    // boolean indicating a heart is in the vicinity of the mouse to be shot:
    if (mouseDistance <= (heartSize/2.5))
      mouseLock = true;

    else if (mouseDistance > (heartSize/2.5))
      mouseLock = false;

    //   println(mouseLock);



    // when the mouse is not moving, the hearts sometimes move towards it:
    if (mouseMove == false && !hitCounterStart) {
      // just an arbirtrary minimum distance for attraction, based on screensize: 
      if (mouseDistance < width/7 && restCounter <= 0) 
        target = mouse;
    }

    // when the mouse starts moving, the hearts also move away:
    if (mouseMove == true) {
      wander.x =  random(width);
      wander.y =  random(height);
      target = wander;
    }

    // when a heart is shot, it moves away:
    if (heartMove == true) {
      wander.x =  random(width);
      wander.y =  random(height);
      target = wander;
      hitCounterStart = true;

      velocity = new PVector(random(-topspeed, topspeed), random(-topspeed, topspeed));
      heartMove = false;
    }

    // if heart is hit, it should move away from the mouse and not come back for a while, again to prevent being an easy target (though still it doesn't always prevent mass hit chains)
    if (hitCounterStart == true && hitCounter < hitTime) {
      hitCounter++;

      wander.x =  random(width);
      wander.y =  random(height);
      target = wander;
    }

    if (hitCounter > hitTime) {
      hitCounterStart = false;
    }


    // when the hearts have come to a still, the hearts stay there for a while, until they get a random new target:

    if (velocity.mag() < 0.2) {

      restCounter++;

      if (restCounter > restTime) {

        wander.x =  random(width);
        wander.y =  random(height);

        target = wander;

        restCounter = 0;    
        restTime = (int) random(50, 150);
      }
    }

    // Heart movement vectors: 

    // acceleration is taken from the direction by normalizing and decimizing it:
    PVector direction = PVector.sub(target, location);
    direction.normalize();
    direction.mult(0.05);
    acceleration = direction;

    // implementing topspeed into velocity of the hearts:
    velocity.limit(topspeed);

    // updating location of hearts with velocity:
    location.add(velocity);

    // calculating distance between heart targets and their location:
    distance = PVector.sub(target, location);

    // when the hearts are nearing their location they reduce speed:
    if (distance.mag() < 20) {
      velocity.limit(velocity.mag() * 0.90);



      // the hearts also move towards eachother now and then
      // if the hearts are with too many clustered around eachother, they will start to wander around again:
      if (nearestMax == true) 
        nearCounter++;
      if (nearCounter > nearTime) {

        wander.x =  random(width);
        wander.y =  random(height);

        target = wander;
        nearCounter = 0;
      }

      // otherwise they just cluster happily:
      else if (nearestMax == false)
        target = nearestHeart;


      // to prevent the hearts from falling into a 'balance' of sticking around in small groups, they will loose interest in eachother and start of wondering again at random moments:

      scatterCounter++;
      if (scatterCounter > scatterTime) {

        target = wander;

        scatterCounter = 0;
        scatterTime = (int)random(100, 300);
      }


      // When the hearts have reached a random wander target, they get a new random target after a while of rest:

      if (velocity.mag() < 0.2 && target == wander) {
        randomWanderCounter++;

        if (randomWanderCounter > randomWanderTime) {

          wander.x =  random(width);
          wander.y =  random(height);

          randomWanderCounter = 0;    
          randomWanderTime = (int) random(150, 300);
        }
      }
    }

    // otherwise the hearts accelerate till location is neared (or topspeed is reached):
    else {

      velocity.add(acceleration);
    }


    // to prevent the hearts from getting stuck in endless orbits around their target, near maximum speed the targets are changed now and then: 

    if (velocity.mag() > (topspeed - (topspeed*0.1))) {

      changeDirCounter++;

      if (changeDirCounter > changeDirTime) {

        wander.x =  random(width);
        wander.y =  random(height);

        target = nearestHeart;


        changeDirCounter = 0;
        changeDirTime = (int) random(100, 250);
      }
    }

    // for rotation of hearts
    heartRotate += velocity.mag() + 1; 
    heartSize = 70 * ((sin(radians(heartRotate*0.5))*0.15)+1); // some wild size changes for a bit more dynamic feel
  }

  // the final visual results: 

  void display() {

    noStroke();


    pushMatrix();
    translate(location.x, location.y);
    //   rotate(sin(radians(heartRotate*0.04))*10);    // left this out as I didn't really like it, but it can be added again

    shape(heart0, 0, 0, heartSize, heartSize); 

    popMatrix();
  }
}