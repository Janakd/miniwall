class Bar{
  //all the variables
  float currentHeight; 
  float finalHeight; 
  float step ; 
  
  float x, y , a , b ; 
  
  //initialize the class 
  Bar (float bx, float by, float b) {
       x = bx-47; 
       y = by-50 ;
       finalHeight = -b;
       
       step = -3; 
       a = 100 ;
       
  }
  
  
  //all the methods/functions 
  void update(){
   //calculate the height
   if (currentHeight > finalHeight) {  
       currentHeight = currentHeight + step ;
   } 
   
  }
  
  void render (){
    //draw the box 
    rect (x,y,a, currentHeight) ;
    
  }
}
