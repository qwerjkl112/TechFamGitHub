 <%@ page language="java" contentType="text/html; charset=UTF-8"

    pageEncoding="UTF-8"%>

<%@page import="java.sql.*"%>

<%@page import="javax.sql.*"%>

<%Class.forName("com.mysql.jdbc.Driver"); %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>

<body>

<%

//--------------------------------------------------------------------

// This jsp file adds a new credit card to the database
//--------------------------------------------------------------------

// required inputs: number (Long) - 			number of the credit card
//					name (String) -				name on the credit card
//					type (String) - 			debit or credit card
//					experation (String) - 		experation date on credit card yyyy/mm/01
//					username (String) -			user who owns the card
//					billing_address_id (int) -	id of the billing address 

// output: if adding the item was a success

//--------------------------------------------------------------------

// Table use: Credit_Card

//--------------------------------------------------------------------
String DATABASE_NAME = "techfam";
String DATABASE_USERNAME = "root";
String DATABASE_PASSWORD = "noclown1";
String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
String DRIVER_LOC = "com.mysql.jdbc.Driver";
String SUCCESS_LABEL = "AddSales_Item";

Connection con = null;
PreparedStatement insert_statement;

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);

	// insert Credit Card for the user
	long number = Long.parseLong(request.getParameter("number"));
	String name = request.getParameter("name");
	String type = request.getParameter("type");
	String date = request.getParameter("date");
	String username = (String)session.getAttribute("UserName");
	int billing_address_id = Integer.parseInt(request.getParameter("billing_address_id"));

	insert_statement = con.prepareStatement("INSERT INTO credit_card VALUES (?,?,?,?,?,?)");
	insert_statement.setLong(1, number);
	insert_statement.setString(2, name);
	insert_statement.setString(3, type);
	insert_statement.setString(4, date);
	insert_statement.setString(5, username);
	insert_statement.setInt(6, billing_address_id);
	insert_statement.executeUpdate();

	session.setAttribute(SUCCESS_LABEL, "Success");
}catch(Exception e){
	e.printStackTrace();
	try{
		if(con != null){
			con.rollback();
		}
	}catch(Exception e2){}
	session.setAttribute(SUCCESS_LABEL, "Fail");
}finally{
	if(con != null){
		con.close();
	}
}
		
// redirect to previous page
// String redirectURL = String.format("Profile.jsp?supplier_id=%s", request.getParameter("supplier_id"));

String redirectURL = "DirectBuy.jsp";
		
response.sendRedirect(redirectURL);

%>
</body>
</html>