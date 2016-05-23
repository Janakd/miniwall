void keyPressed() {
  if (key == 'b' || key == 'B') {
    println("Start calibraing offset. This will automatically stop.");
    for (int i = 0; i < TOTOAL_CARDS; i++ ) {
        cards[i].startOffsetCalibration();
      }
  } 
  else if (key == 'p' || key == 'P') {
    if (cards.length >0 ){
        //start 
        if (!cards[0].isCalibratingPeak){
            for (int i = 0; i < TOTOAL_CARDS; i++ ) {
                cards[i].startPeakCalibration(); 
            }
            println("Start calibraing Peak. Touch each card for 1S. Press P when done. ");
        } else {  //if ending 
             for (int i = 0; i < TOTOAL_CARDS; i++ ) {
                cards[i].stopPeakCalibration(); 
            }
        }

    }
  }
  else if (key == '0'){
  mode = MODE_TOUCH;
  println("mode = touch");
  }
  else if (key == '1'){
  mode = MODE_CREDIT;
  println("mode = credit score");  
  }
  else if (key == '2'){
  mode = MODE_FEE;
  println("mode = annual fee");  
  }
  
  
  else if (key == 'c' || key == 'C'){
    ISDEBUGGING = !ISDEBUGGING ; 
  }
  


}
