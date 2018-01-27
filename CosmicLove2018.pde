/*
This is a silly little conceptual game I originally created for the 'Introduction to Programming' course at Media Technology at Leiden University in 2011-2012

I created the physics of the hearts with a particle system based on the Processing vector tutorial found at https://www.processing.org/tutorials/pvector/

To run the code, install Processing 3, copy files into your Processing sketch folder, and press run.  

Made with Processing (www.processing.org). 

© 2018 Bardo Frings

*/


// Fonts for text: 
PFont titleText;
PFont menuText;
PFont scoringText;

// Fading variables and associated counters for text:
float titleFade;
int titleCounter;
float subtitleFade;
int subtitleCounter;
float menuFade;
int menuCounter;
float interfaceFade; 
int interfaceCounter; 
int globalCount;
int errorCounter;
// Counter, giving the amount of generated hearts after each shot:
int shotCounter;

// exit boolean for end of game:
boolean exitNow;

// Boolean switch for menu on/off:
boolean menu; 
boolean gameInterface;

// Calling heart array:
Heart[] hearts = new Heart[1000]; // just an arbitrary maximum of possible hearts. If you have a really fast processor you might want to set the max higher

// Vectors and arrays to calculate distances between hearts and sort them:
PVector[] heartLocations = new PVector[hearts.length];
float[][] heartDistances = new float[hearts.length][hearts.length];
float[][] heartsSorted = new float[hearts.length][hearts.length];


void setup() {

  size(1280, 720);
  pixelDensity(2); // uncomment for retina displays
  cursor(CROSS); // target cursor
  noCursor(); // For title without cursor
  smooth();
  shapeMode(CENTER);

  background(0);

  // Loading fonts for title, menu and interface:
  titleText = loadFont("Futura-Medium-96.vlw");
  menuText = loadFont("Futura-Medium-96.vlw"); // I know this is the same exact same font as the title, but just in case I want to change only this one later.
  scoringText = loadFont("Monaco-28.vlw");

  // setting variables to initial values:
  titleCounter = 0;
  titleFade = 0;
  subtitleCounter = 0;
  subtitleFade = 0;
  menuCounter = 0;
  menuFade = 0;
  menu = true;
  gameInterface = false;
  exitNow = false;
  globalCount = 0;
  shotCounter = 5;
  errorCounter = 0;


  // creating actual hearts:
  for (int i = 0; i < hearts.length; i++) {
    hearts[i] = new Heart(); 
    heartLocations[i] = hearts[i].location; // getting primary locations of hearts

    for (int j = 0; j < hearts.length; j ++) { 

      // filling up the arrays beforehand with zero's to prevent possible confusion:
      heartDistances[i][j] = 0;
      heartsSorted[i][j] = 0;
    }
  }
}


void draw() {

  background(0);
  globalCount++;

  // Create hearts only after title and menu have disappeared, after which the game interface also appears, so I used the same boolean for this:
  if (gameInterface) {

    for (int i = 0; i < shotCounter; i++) {

      if (i < 5) 
        hearts[i].heartBirth = false;

      hearts[i].update(); // updating variables 
      hearts[i].display(); // visualization of the hearts

      heartDistances();
    }
  }

  // Title and menu:
  titleMenu();

  // to end the game 
  exitRoute();
}

void titleMenu() {

  // Title fade in and out: 
  if (globalCount > 90 && globalCount < 450) {
    titleCounter++;
    titleFade = sin(radians(titleCounter/2.0));
    fill(255, titleFade*255);
    textFont(titleText, 42); 
    textAlign(CENTER);
    text("Cosmic Love", width/2, height/2);
  }


  if (globalCount > 540 && globalCount < 900) {
    subtitleCounter++;
    subtitleFade = sin(radians(subtitleCounter/2.0));
    fill(255, subtitleFade*255);
    textFont(titleText, 23); 
    textAlign(CENTER);
    text("by Bardo Frings", width/2, height/2);
  }


  // Menu fade in: 
  if (globalCount > 990  && menu == true) {

    // Menu should only fade in at start, so counter should stay below a certain value:
    if (menuCounter < 90)    
      menuCounter++;


    menuFade = sin(radians(menuCounter/1.0));
    fill(0, 255, 0, menuFade*255);
    textFont(menuText, 24); 
    textAlign(CENTER);
    text("Shoot the Hearts", width/2, height/2);

    fill(0, 255, 0, menuFade*255);
    textFont(menuText, 18); 
    textAlign(CENTER);
    text("and spread the Love!", width/2, height/1.8);

    textFont(menuText, 18); 
    fill(100, 0, 255, menuFade*255);
    text("Click to start", width/2, height/1.3);
  }

  if (menuCounter >= 90)
    cursor();



  // If the user clicks on the menu screen, it will fade out for the game to start:
  if (globalCount > 1080  && menu == false) {

    if (menuCounter < 180) {
      menuCounter++;

      menuFade = sin(radians(menuCounter/1.0));
      fill(0, 255, 0, menuFade*255);
      textFont(menuText, 24); 
      textAlign(CENTER);
      text("Shoot the Hearts", width/2, height/2);

      fill(0, 255, 0, menuFade*255);
      textFont(menuText, 18); 
      textAlign(CENTER);
      text("and spread the Love!", width/2, height/1.8);

      textFont(menuText, 18); 
      fill(100, 0, 255, menuFade*255);
      text("Click to start", width/2, height/1.3);

      if (menuCounter >= 179) 
        gameInterface = true;
    }
  }


  // Interface fade in: 
  if (globalCount > 1260  && menu == false && gameInterface == true) {

    // Interface should only fade in when game starts, so counter should stay below a certain value:
    if (interfaceCounter < 90)    
      interfaceCounter++;

    interfaceFade = sin(radians(interfaceCounter/1.0));
    fill(0, 255, 50, interfaceFade*255);
    textFont(scoringText, 14); 
    textAlign(CORNER);
    text("Hearts: " + shotCounter, width * 0.03, height * 0.05);
  }
}





void heartDistances() {

  // doing all the necessary calculations for getting the nearest hearts and giving a maximum amount of clustered hearts to enable scattering:  

  for (int i = 0; i < shotCounter; i++) {

    heartLocations[i] = hearts[i].location; // getting locations of hearts

    for (int j = 0; j < shotCounter; j++) {
      heartLocations[j] = hearts[j].location; // again for distance calculation

      heartDistances[i][j] = PVector.dist(heartLocations[i], heartLocations[j]); // distance calculation between hearts
    }

    heartsSorted[i] = sort(heartDistances[i]); // sorting the distances


    for (int j = 0; j < shotCounter; j++) {

      // picking out the shortest distance between two hearts. Array element 0 of the sorted array is 0.0, as the heart distances are also measured against themselves, so we take the next one:
      if (heartsSorted[i][1] == heartDistances[i][j]) {

        // sending the locations of the shortest distanced heart back to the heart class:
        hearts[i].nearestHeart.x = heartLocations[j].x;
        hearts[i].nearestHeart.y = heartLocations[j].y;
      }

      // because we don't want the hearts to cluster on one big heap, we set a maximum of hearts close to one another, and send a boolean to the class whether or not there are too many hearts around one:
      if (heartsSorted[i][(int)shotCounter/20] < 100) 
        hearts[i].nearestMax = true;

      else  if (heartsSorted[i][(int)shotCounter/20] > 100) 
        hearts[i].nearestMax = false;
    }
  }
}



// The game stops when the framerate drops below a certain value (and secretly you have won then):
void exitRoute() {




  if (frameRate < 1.5)

    for (int i = 1; i < (int) (10.0/frameRate); i++) 
      copy((int) random(width), (int) random(height), 100*i, 2 * i, (int) random(width), (int) random(height), 100*i, 2 * i);

  if (frameRate < 1.0) {

    for (int i = 1; i < (int) (10.0/frameRate); i++) 
      copy((int) random(width), (int) random(height), 2*i, 10 * i, (int) random(width), (int) random(height), 2*i, 10 * i);

    fill(0, 255, 0);
    textFont(scoringText, 14); 
    textAlign(CENTER);



    text("Error 42: O dear, too much love for processor! Program will exit now.", width/2, height/2);
    errorCounter++;

    if (errorCounter > 7)
      exitNow = true;
  }

  if (exitNow) {
    //    exit();

    titleCounter = 0;
    titleFade = 0;
    subtitleCounter = 0;
    subtitleFade = 0;
    menuCounter = 0;
    menuFade = 0;
    menu = true;
    gameInterface = false;
    exitNow = false;
    globalCount = 0;
    shotCounter = 5;
    frameRate(60);
    errorCounter = 0;
    noCursor();



    // creating actual hearts:
    for (int i = 0; i < hearts.length; i++) {
      hearts[i] = new Heart(); 
      heartLocations[i] = hearts[i].location; // getting primary locations of hearts

      for (int j = 0; j < hearts.length; j ++) { 

        // filling up the arrays beforehand with zero's to prevent possible confusion:
        heartDistances[i][j] = 0;
        heartsSorted[i][j] = 0;
      }
    }

    exitNow = false;
  }
}


void mouseClicked() {

  //   // If the user clicks on the menu screen after it has appeared, it will fade out to for the game to start:
  if (menu == true && globalCount > 630) 
    menu = false;

  for (int i = 0; i < shotCounter; i++) {

    if (hearts[i].mouseLock == true) {

      hearts[i].heartMove = true;  

      if (shotCounter < hearts.length && gameInterface == true) {
        i = shotCounter;  // at fist I wanted to do another promity calculation to limit the amount of hitted hearts in one shot to only one heart, the closest one, 
        // but then I realized I could also get the same effect by setting the forloop iteration to the maximum if a heart is hit

        shotCounter += (int) random(1, 3); // when a heart is hit, it creates new hearts!
      }
    }
  }
}