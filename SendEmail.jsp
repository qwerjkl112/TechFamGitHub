<%@ page language="java" contentType="text/html; charset=UTF-8"

    pageEncoding="UTF-8"%>

<%@page import="java.util.*"%>
<%@page import="javax.mail.*" %>
<%@page import="javax.mail.internet.*"%>
<%@page import="javax.activation.*"%>

<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<%
String to = "techfamshoes@gmail.com";
final String from = "techfamshoes@gmail.com";
final String password = "TechFam1234";

String HEADER = "Test";
String BODY = "Test";

Properties properties = System.getProperties();
properties.setProperty("mail.smtp.host", "smtp.googlemail.com");
properties.setProperty("mail.smtp.port", "587");
properties.setProperty("mail.smtp.user", from);
properties.setProperty("mail.smtp.password", password);
properties.setProperty("mail.smtp.auth", "true"); 
properties.put("mail.smtp.starttls.enable", "true");

Session mail_session = Session.getDefaultInstance(properties, new javax.mail.Authenticator() {
    protected PasswordAuthentication getPasswordAuthentication() {
        return new PasswordAuthentication(from, password);
    }
});

try{
	MimeMessage message = new MimeMessage(mail_session);
	message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
	message.setFrom(new InternetAddress(from));
	
	//Write Message
	message.setSubject(HEADER);
	message.setText(BODY);
	
	//Send
	Transport.send(message, from, password);
	System.out.println("Mail Sent");
}catch(Exception e){
	e.printStackTrace();
	System.out.println("Failed to Send");
}

%>
</body>
</html>