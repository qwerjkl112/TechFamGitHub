<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>My Profile</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>

<%
	
	//----------------------------------------------------------------------------
	// This jsp file changes delivery status of a transaction
	//----------------------------------------------------------------------------
	// input: transaction_id and new shippping status
	// output: goes back to shipping information page
	//----------------------------------------------------------------------------
	// databases and fields used: 
	//     ups
	//----------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement insert_ups;
	System.out.println("transaction_id is " + Long.parseLong(request.getParameter("transaction_id")));
	insert_ups = con.prepareStatement("update ups set shipping_method = ? where transaction_id = ?");
	insert_ups.setString(1, request.getParameter("shipping_method"));
	insert_ups.setLong(2, Long.parseLong(request.getParameter("transaction_id")));
	insert_ups.executeUpdate();
	
	
	String redirectURL = String.format("CompanyUser.jsp");
	response.sendRedirect(redirectURL);
	
%>
</body>
</html>