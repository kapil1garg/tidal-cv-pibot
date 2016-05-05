/*
Learning Computer Vision
EECS 395: TIDAL | S2016
Kapil Arun Garg (kag213)

This sketch is my creative computer vision assignment. 
The sketch creates a connection via ethernet to a Raspberry Pi and controls the robot to go backwards/forwards depending on tracked tag value.  
*/

// import the TUIO library and processing networking library
import TUIO.*;
import processing.net.*; 

// declare a TuioProcessing client
TuioProcessing tuioClient;

// declare connection variables
Client myClient; 
String dataIn; 
String raspberryPi = "169.254.0.2";  // IP assigned to rPi
int portNo  = 51717;        // port used by rPi server 
boolean firstTime = true;    // used to make sure setup initializes the connection only once.

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

void setup()
{
  // GUI setup
  noCursor();
  size(1280, 720);
  noStroke();
  fill(0);
  
  // connection setup
  if ( firstTime ) {
    // setup communication with server
    myClient = new Client(this, raspberryPi, portNo ); 
    
    // send the server an integer
    myClient.write( String.format("%d", 3) );
    firstTime = false;
  }
  
  // periodic updates
  if (!callback) {
    frameRate(60);
    loop();
  } else noLoop(); // or callback updates 
  
  font = createFont("Arial", 18);
  scale_factor = height / table_size;
  
  // finally we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods in this class (see below)
  tuioClient  = new TuioProcessing(this);
}

// within the draw method we retrieve an ArrayList of type <TuioObject>, <TuioCursor> or <TuioBlob>
// from the TuioProcessing client and then loops over all lists to draw the graphical feedback.
void draw()
{
  background(255);
  textFont(font, 18 * scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  
  // pick first object and track
  ArrayList<TuioObject>tuioObjectList = tuioClient.getTuioObjectList();
  if (tuioObjectList.size() >= 1) {
    TuioObject tobj = tuioObjectList.get(0);
    
    
    // check if is even
    Boolean isEven = tobj.getSymbolID() % 2 == 0;
    
    // send information to rPi
    if ( myClient.available() > 0 ) {
      if (isEven) {
        myClient.write( String.format("%d", 1) );
      } else {
        myClient.write( String.format("%d", 2) );
      }
    } 
    
    // draw on screen
    // change color if object value is even or odd
    stroke(0);
    if (isEven) {
      fill(255, 0, 0); 
    } else {
      fill(0, 255, 0); 
    }
    pushMatrix();
    translate(tobj.getScreenX(width),tobj.getScreenY(height));
    rotate(tobj.getAngle());
    rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
    popMatrix();
    fill(255);
    text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
    
  } else {
    // send information to rPi
    if ( myClient.available() > 0 ) {
      myClient.write( String.format("%d", 3) );
    } 
  }
}

// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
          +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

// --------------------------------------------------------------
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (verbose) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (verbose) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
          +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (verbose) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) {
  if (verbose) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
          +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}