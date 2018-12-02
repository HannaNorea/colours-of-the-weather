 /* WEATHER COLOR and LIGHT PROJECT 2016
    Copyright main code Hanna Thenor Årström Stockholm, Sweden
    with respect to Micah Scott for Fadecandy OPC.
    
    This program is the client side of a server-client setup. The server is found in 
    "photocell.py". Server sends values from three sensors that are plugged in to the 
    Rasp Pi, which this program uses to manipulate four Adafruit Neomatrices.*/

// Setting up client and OPC
import processing.net.*; 

Client myClient; 
OPC opc;

// Declare class for raindrops
ArrayList<Drop> drops;
int dropSize = 0;

// Variables
String stringIn; 
float temp, light, rain;
 
void setup() { 
  
  size(800, 400); 
  
    // Set  colormode to Hue, Sat and 
  colorMode(HSB, 100, 100, 100);
  
    // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width*1/4, height*1/4, height / 16.0, -PI, false);
  opc.ledGrid8x8(1*64, width*2/4, height*1/4, height / 16.0, -PI/2, false);
  opc.ledGrid8x8(3*64, width*1/4, height*3/4, height / 16.0, PI/2, false);
  opc.ledGrid8x8(2*64, width*2/4, height*3/4, height / 16.0, 0, false);
  
  // Connect to Python on port 10000
  myClient = new Client(this, "127.0.0.1", 10000); 
  
  // Initiate raindrop class and create empty arraylist for storing drops
  drops = new ArrayList<Drop>();
  // Start by adding one element
  drops.add(new Drop(width/2, 0, dropSize));
} 
 
void draw() { 
  // If the server is sending something, we translate it to variables temp and light.
  if (myClient.available() > 0) { 
    stringIn = myClient.readString(); 
    float data = float(stringIn);
    //println(data);
    if (data > 10000) { 
    temp = data/1000;
    println("temperature", temp);
    } 
    else if(data>103 && data <10000) { 
    light = data;
    println("light", light);
    } 
    else {
    rain = data;  
    println("rain", rain);
    }
  } 
   
  // Remap the values temp and light to control Hue and Saturation
  float valueTemp = map(temp, 0, 40, 20, 100);
  float mapLight = map(light, 0, 3000, 0, 100);
  float valueLight = 100- mapLight;
  //println(valueTemp, valueLight);
  background(valueTemp, 100, valueLight);
 
   if (rain < 80) {
     if(drops.size()<80-rain){
        drops.add(new Drop(random(100,400), random(100,400), dropSize));
       // println(drops.size());  
     }
   }
   
  for (int i = drops.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so we have to cast the object coming out
    Drop drop = drops.get(i);
    drop.grow();
    drop.display();

    if (drop.finished()) {
      // Items are deleted with remove
      drops.remove(i);
    }
   } 
} 