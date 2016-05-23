/*
works with arduinoCapWall4 to plot data 
 */

import processing.serial.*;
int MODE_TOUCH = 0;
int MODE_CREDIT = 1 ; 
int MODE_FEE = 2; 

//// plotting 
float xPos  = 0 ; 
float plotWindowY = 300 ;
float plotWidth ; 

//cards 
// final static int TOTOAL_CARDS = 15;  
int TOTOAL_CARDS; 
Card[] cards; 
float offsetX = 0;
float offsetY = 0; 
float yScale = 1; 

boolean ISDEBUGGING = false ;
float[] wallValues;
Serial myPort;

//these are the ones to be plotted and printed 
//int[] channels = {0,1,2};

int[] allChannels; 

//data
XML xml; 
XML[] xmlCards ; 
JSONArray json;  
int jsonInd; 

Bar[] bars; 

void setup() {
  //fullScreen();
  size (1000, 1000);
  background(255); 
  imageMode(CENTER);
  plotWidth = width; 
  textSize(26);


  yScale= 100; 
  offsetX  = 970 ; //width/2; 
  offsetY  = height / 2 ; 
  // List all the available serial ports
  // if using Processing 2.1 or later, use Serial.printArray()
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  Arduino, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[3], 9600);

  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');

  // card meta data is stored in this file 
  xml = loadXML("cards.xml");
  xmlCards = xml.getChildren("card");
  //decide how many cards there are in total 
  TOTOAL_CARDS = xmlCards.length; 
  println("TOTOAL_CARDS: "+ TOTOAL_CARDS);
  // this is to one line of data from processing 
  allChannels = new int[TOTOAL_CARDS];
  wallValues = new float[TOTOAL_CARDS]; //potentially hold more values 
  
  //initializing card objects 
  cards = new Card[TOTOAL_CARDS];
  //create some bars 
  //bar = new Bar (100.0,200.0); 
  bars = new Bar [TOTOAL_CARDS]; 
  
  for (int i = 0; i < TOTOAL_CARDS; i++ ) {
    allChannels[i] = i;
    cards[i] = new Card (i);
    cards[i].caliOffset = xmlCards[i].getFloat("offset");
    cards[i].caliScale = xmlCards[i].getFloat("scale");
    cards[i].x = xmlCards[i].getFloat("x");
    cards[i].y = xmlCards[i].getFloat("y");
    cards[i].desc = xmlCards[i].getString("desc");
    cards[i].rewards = xmlCards[i].getString("rewards");
    cards[i].credit = xmlCards[i].getFloat("credit");
    cards[i].annual = xmlCards[i].getFloat("annual");
    
    bars[i] = new Bar(cards[i].x, cards[i].y, cards[i].credit);
    
    bars[i] = new Bar(cards[i].x, cards[i].y, cards[i].annual); 
  }
  
  // taking care of saving json file 
  prepareExitHandler(); //so that exit function is called 
  json = new JSONArray();
  jsonInd = 0 ; 

}

void draw() {
  if(ISDEBUGGING){
    // check on all the cards 
    for (int i = 0; i < TOTOAL_CARDS; i++ ) {
      //TODO  shall this be called only at new Serial event to be faster ? 
      cards[i].update();
      
     
      
      if (cards[i].touchEvent == 10){
        //start touch event 
        JSONObject temp = new JSONObject();
        int m = millis(); 
        temp.setInt("card", i );
        temp.setString("stamp", "start" );
        temp.setInt("time", m);
        json.setJSONObject(jsonInd, temp);
        jsonInd++; 
        println("i: "+i + " start: " + m);
      }else if(cards[i].touchEvent == 12){
        //end touch event 
        JSONObject temp = new JSONObject();
        int m = millis(); 
        temp.setInt("card", i );
        temp.setString("stamp", "end" );
        temp.setInt("time", m);
        json.setJSONObject(jsonInd, temp);
        jsonInd++; 
        
        println("i: "+i + " end: " + m);
      }
    }
    
  
    
  
    //plotSerialData();
    // plotSerialData(channels); 
    plotSerialData(allChannels);
    
  }
  
  ///CX 
  else {
       //draw the cards here! 
    background(0); 
    for (int i = 0; i < TOTOAL_CARDS; i++ ) {
      //TODO  shall this be called only at new Serial event to be faster ? 
      cards[i].update();
      cards[i].render(); 
       
       //draw bars
      bars[i].update();
      bars[i].render();
    }
    
    
   
  }
}




void serialEvent(Serial myPort) {

  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);

    // split the string on the commas and convert the
    // resulting substrings into an integer array:
    float[] values = float(split(inString, "\t"));

    if (values.length == TOTOAL_CARDS) { //just gonna ignore the errors s
      //source -> dest 
      arrayCopy(values, wallValues);

     for (int i = 0; i < TOTOAL_CARDS; i++ ) {
    
        cards[i].addNewData(wallValues[i]) ;
        
      }
    
    }else{
      // String s = "Mismatch:  TOTOAL_CARDS" + TOTOAL_CARDS 
      //   + "array size " + values.length ; 
        
      // println(s); 
    }
  }
}


void plotSerialData() {
  noStroke(); 
  for (int i = 0; i < TOTOAL_CARDS; i++ ) {
    fill(cards[i].fillColor);
    ellipse ( xPos, -cards[i].hoverScale*yScale + plotWindowY - 20, 1, 1);

    // strokeWeight(2);
    // line( 0, plotWindowY - 10 - cards[i].caliOffset, width , plotWindowY - 10 - cards[i].caliOffset) ;
  }


  if (xPos >= plotWidth) {
    xPos = 0 ;
     repaint(); 
  } else {
    xPos ++ ;
  }


}

void repaint(){
   fill(255); 
    // rect(0, 0, plotWidth, plotWindowY   );  //repaint the graph area

    rect(0, 0, plotWidth, height   );  //repaint the graph area
   
}


void saveToJson() {
// } void keyPressed() {
  String s = "data/"; 
  s += String.valueOf(year());
  s += String.valueOf(month()); 
  s += String.valueOf(day());
  s += String.valueOf(hour());  
  s += String.valueOf(minute()); 
  s += ".json"; 
  saveJSONArray(json, s);
  println("save to "+s); 
}


private void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      // System.out.println("SHUTDOWN HOOK");
      // application exit code here
      saveToJson(); 
    }
  }));
}



void plotSerialData(int[] array) {
  noStroke(); 
  for (int i = 0; i < array.length; i++ ) {
    int k = array[i];  
    // plotReadings 
    fill(cards[k].fillColor) ; 
    ellipse ( xPos, -cards[k].hoverScale * yScale  + plotWindowY - 10, 2, 2);  
  //  print(k +" " + -cards[k].hoverScale +"\t " );
    
  }
  //println(); 
  if (xPos >= plotWidth) {
    xPos = 0 ;
   repaint(); 
  } else {
    xPos ++ ;
  }
}
