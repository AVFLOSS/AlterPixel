// Simple Authenticator      
// Careful, this is terribly unsecure!!
 
import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;
 
public class Auth extends Authenticator {
 
  public Auth() {
    super();
  }
 
  public PasswordAuthentication getPasswordAuthentication() {
    String username, password;
    username = "YOUR_USER_NAME";
    password = "YOUR_PASSWORD";
    System.out.println("authenticating... ");
    
    return new PasswordAuthentication(username, password);
  }
}
