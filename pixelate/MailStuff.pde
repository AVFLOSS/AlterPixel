// Example functions that send mail (smtp) //<>//
// You can also do imap, but that's not included here

import java.util.*;
import java.io.*;
import javax.activation.*;

String sendersEmail = "YOURNAME@EXAMPLE.COM"; // Your email
String sendersName = "YOURNAME"; //your name
String sendersSmpt = "YOUR_SMTP_HOST"; //your email smpt host EJ: mail.dominio.net

// A function to send mail
void sendMail() {
  // Create a session
  String host=sendersSmpt;
  Properties props=new Properties();

  // SMTP Session
  props.put("mail.transport.protocol", "smtp");
  props.put("mail.smtp.host", host);
  props.put("mail.smtp.port", "25");
  props.put("mail.smtp.auth", "true");
  // We need TTLS, which gmail requires
  // props.put("mail.smtp.starttls.enable","true");

  // Create a session
  Session session = Session.getDefaultInstance(props, new Auth());

  try
  {
    MimeMessage msg=new MimeMessage(session);
    msg.setFrom(new InternetAddress(sendersEmail, sendersName));
    msg.addRecipient(Message.RecipientType.TO, new InternetAddress(lastEmail));
    msg.setSubject("Tu pixelate.");
    BodyPart messageBodyPart = new MimeBodyPart();
    // Fill the message
    messageBodyPart.setText("Tu pixelate imagen.\n\n - - - \n\n Email sent with Processing");
    Multipart multipart = new MimeMultipart();
    multipart.addBodyPart(messageBodyPart);
    // Part two is attachment
    messageBodyPart = new MimeBodyPart();
    DataSource source = new FileDataSource(sketchPath()+"/imagenes/"+ lastImageName);
    messageBodyPart.setDataHandler(new DataHandler(source));
    messageBodyPart.setFileName(lastImageName);
    multipart.addBodyPart(messageBodyPart);
    msg.setContent(multipart);
    msg.setSentDate(new Date());
    synchronized(this) {
      mailStatus = "Autenticando y enviando...";
    }
    Transport.send(msg);
    println("Mail sent!");
    synchronized(this) {
      mailStatus = "      E-mail enviado.";
    }
    delay(2500); //para que de tiempo a leer
  }
  catch(Exception e)
  {
    e.printStackTrace();
  }
  synchronized(this) {
    sendingMail = false;
  }
}
