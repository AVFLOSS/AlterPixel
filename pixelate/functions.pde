// Function to get the time and pass it to the Time variable
void setTimestamp() {
  String Year, Month, Day, Hour, Minute, Second, Millisecond;
  Year = nf( year(), 4 );
  Month = nf( month(), 2 );
  Day = nf( day(), 2 );
  Hour = nf( hour(), 2 );
  Minute = nf( minute(), 2 );
  Second = nf( second(), 2 );
  Millisecond = nf( millis(), 4);
  Time = Year + Month + Day + "_T" + Hour + Minute + Second + Millisecond ;
}


// Function to list all the files in a directory
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}
void setTextField() {
  PFont font = createFont("arial", 20);
  cp5 = new ControlP5(this);
  Textfield t = cp5.addTextfield("")
    .setPosition(width/2-100, 200)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    .keepFocus(true)
    ;
    //Dummy text field to use its label
  Textfield m = cp5.addTextfield("m")
    .setPosition(0-width/2, 250)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    .keepFocus(false)
 //   .hide()
    ;
    
  Label labelEmail = t.getCaptionLabel();
  labelEmail.setColor(color(255,250,0));
  labelEmail.setFont(createFont("Georgia",35));
  labelEmail.toUpperCase(false);
  labelEmail.setText(" E-mail:  ");
  labelEmail.align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);
  labelEmail.setColorBackground(color(0,55,255,200));
  labelEmail.getStyle().setPaddingRight(47);
  
  //msgLabel = cp5.addTextlabel("msg")
  //   .setText("Mail no válido")
  //   .setPosition((width/2)-100,240)
  //   .setColorValue(0xffff0000)
  //   .setFont(createFont("Georgia Bold",35))
  //   .setColorBackground(0xff000000)
  //   ; 

  //Label labelMsg = m.getCaptionLabel();
  labelMsg = m.getCaptionLabel();
  labelMsg.setColor(color(255,250,0));
  labelMsg.setFont(createFont("Georgia",35));
  labelMsg.toUpperCase(false);
  labelMsg.setText(" Mail no válido ");
  labelMsg.align(ControlP5.RIGHT+width,240);
  labelMsg.setColorBackground(color(255,55,0,200));
  labelMsg.getStyle().setPaddingRight(-5);
  labelMsg.getStyle().setMarginLeft(width-100);
  labelMsg.hide();

 
  cp5.hide();
 // msgLabel.hide();
  textFont(font);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {

    println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );
    //ENTER has been pressed


    String email = theEvent.getStringValue();
    email= email.replaceAll("[\u0000-\u001f]", ""); //remove control characters
    if (isValidEmailAddress(email)) {
      cp5.hide(); 
      cp5.get(Textfield.class, "").clear(); 
    
      lastImageName = saveImage();
      lastEmail = email;
      sendingMail = true;
      thread("sendMail");
    } else {
//   println("no es válido: "+email);
   labelMsg.show();
   //msgLabel.setText("Mail no válido");
   //msgLabel.show();
   //  cp5.addTextfield("No vale el email");
    }
  }
}

//email validator
public static boolean isValidEmailAddress(String email) {
  boolean result = true;
  try {
    InternetAddress emailAddr = new InternetAddress(email);
    emailAddr.validate();
  } 
  catch (AddressException ex) {
    result = false;
  }
  return result;
}