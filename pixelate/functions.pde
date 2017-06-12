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
// sets the text field for the mail
void setTextField() {
  mailField = new GTextField(this, (width/2)-100, height/2 -10, 200, 35);
  mailField.setFont(new Font("Georgia", Font.PLAIN, 25));
  mailField.setVisible(false);

  lblMail = new GLabel(this, mailField.getX(), mailField.getY()-50, 200, 18);
  lblMail.setFont(new Font("Georgia", Font.PLAIN, 35));
  lblMail.setAlpha(190);
  lblMail.setTextAlign(GAlign.LEFT, null);
  lblMail.setOpaque(true);
  lblMail.setText("E-mail");
  lblMail.resizeToFit(false, true);
  lblMail.setVisible(false);

  lblError = new GLabel(this, mailField.getX()-25, mailField.getY()+50, 250, 18);
  lblError.setFont(new Font("Georgia", Font.PLAIN, 25));
  lblError.setAlpha(190);
  lblError.setTextAlign(GAlign.LEFT, null);
  lblError.setOpaque(true);
  lblError.setText("E-mail no es válido");
  lblError.resizeToFit(false, true);
  lblError.setLocalColorScheme(G4P.RED_SCHEME);
  lblError.setVisible(false);
}

void procesaMail(String _mail) {
  String email = _mail;
  if (isValidEmailAddress(email)) {
    mailField.setText("");
    mailField.dispose();
    lblMail.dispose();
    lastImageName = saveImage();
    lastEmail = email;
    sendingMail = true;
    thread("sendMail");
  } else {
     println("no es válido: "+email);
    lblError.setVisible(true);
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