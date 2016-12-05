<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="java.util.Date.*"%>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<body>
	<%
	
	//-------------------------------------------------------------------------------------------------------
	// This jsp file handles the signing up of new users. User are to input valid info for signing up to be
	// successful. We should partition this code into functions later. 
	//-------------------------------------------------------------------------------------------------------
	// input - username, password, name, phone_number, app_num, street_address, city, state, zip, 
	//         credit_card_name, credit_card_number, type, expiration
	// output - if there is an error, show the reason for error, else show sign up is successful
	//-------------------------------------------------------------------------------------------------------
	// databases and fields used: 
	//	suppliers - supplier_id, name, email
	// 	register_users - username, password, age, gender, income, supplier_id
	//	address - address_id, app_num, street_address, city, state, zip, supplier_id
	//	phone - phone_number
	//	credit_card - number, name, type, expiration
	//-------------------------------------------------------------------------------------------------------
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement check_username, check_phone, check_credit_card, incrementID, insert_supplier, insert_register_user, insert_address, insert_phone, insert_card;
	ResultSet result;
	int new_supplier_ID, new_address_ID;
	long temp, age = 0, income=0;
	Date temp_date;
	
	// check if username is valid
	check_username = con.prepareStatement("SELECT username FROM register_users WHERE username = ?");
	check_username.setString(1, request.getParameter("username"));
	result = check_username.executeQuery();
	if (result.next()) {
		// username is already taken
	}
	
	
	// check if phone number is valid
	check_phone = con.prepareStatement("SELECT phone_number FROM phone WHERE phone_number = ?");
	check_phone.setString(1, request.getParameter("phone_number"));
	result = check_phone.executeQuery();
	if (result.next()) {
		// phone number is already taken
	}
	
	
	// check is credit card is valid
	check_credit_card = con.prepareStatement("SELECT number FROM credit_card WHERE number = ?");
	check_credit_card.setString(1, request.getParameter("credit_card_number"));
	result = check_credit_card.executeQuery();
	if (result.next()) {
		// credit card is already taken
	}

	
	// check if number inputs are valid
	try {
		temp = Long.parseLong(request.getParameter("age"));
	}
	catch (NumberFormatException e) {
		
	}
	try {
		temp = Long.parseLong(request.getParameter("zip"));
	}
	catch (NumberFormatException e) {
		
	}
	try {
		temp = Long.parseLong(request.getParameter("phone_number"));
	}
	catch (NumberFormatException e) {
		
	}
	try {
		temp = Long.parseLong(request.getParameter("credit_card_number"));
	}
	catch (NumberFormatException e) {
		
	}
	try {
		temp_date = java.sql.Date.valueOf(request.getParameter("expiration"));
	}
	catch (IllegalArgumentException e) {
		
	}
	
	
	// everything is ready to be inserted into the database
	
	
	//find largest supplier_id and increment it by one - this is the new users ID
	incrementID = con.prepareStatement("SELECT MAX(supplier_id) FROM suppliers");
	result = incrementID.executeQuery();
	
	//insert new user info in suppliers table
	result.next();
	new_supplier_ID = result.getInt(1) + 1;
	
	insert_supplier = con.prepareStatement("INSERT INTO suppliers " + "VALUES (?,?,?)");
	insert_supplier.setLong(1, new_supplier_ID);
	insert_supplier.setString(2, request.getParameter("email"));
	insert_supplier.setString(3, request.getParameter("name"));
	insert_supplier.executeUpdate();
	
	//insert new user info in register user
	insert_register_user = con.prepareStatement("INSERT INTO register_users " + "VALUES (?,SHA1(?),?,?,?,?)");
	insert_register_user.setString(1, request.getParameter("username"));
	insert_register_user.setString(2, request.getParameter("password"));
	age = Long.parseLong(request.getParameter("age"));
	insert_register_user.setLong(3, age);
	insert_register_user.setString(4, request.getParameter("gender"));
	income = Long.parseLong(request.getParameter("income"));
	insert_register_user.setLong(5, income);
	insert_register_user.setLong(6, new_supplier_ID);
	insert_register_user.executeUpdate();
	
	
	// find the largest address_id
	incrementID = con.prepareStatement("SELECT MAX(address_id) FROM address");
	result = incrementID.executeQuery();
	
	//insert new user info into address
	result.next();
	new_address_ID = result.getInt(1) + 1;

	insert_address = con.prepareStatement("INSERT INTO address " + "VALUES (?,?,?,?,?,?,?)");
	insert_address.setLong(1, new_address_ID);
	insert_address.setString(2, request.getParameter("app_num"));
	insert_address.setString(3, request.getParameter("street_address"));
	insert_address.setString(4, request.getParameter("city"));
	insert_address.setString(5, request.getParameter("state"));
	insert_address.setLong(6, Long.parseLong(request.getParameter("zip")));
	insert_address.setLong(7, new_supplier_ID);
	insert_address.executeUpdate();
	
	
	// insert new phone number
	insert_phone = con.prepareStatement("INSERT INTO phone " + "VALUES (?)");
	insert_phone.setLong(1, Long.parseLong(request.getParameter("phone_number")));
	insert_phone.executeUpdate();
	
	
	// insert credit card
	insert_card = con.prepareStatement("INSERT INTO credit_card " + "VALUES (?,?,?,?)");
	insert_card.setLong(1, Long.parseLong(request.getParameter("credit_card_number")));
	insert_card.setString(2, request.getParameter("credit_card_name"));
	insert_card.setString(3, request.getParameter("type"));
	insert_card.setDate(4, java.sql.Date.valueOf(request.getParameter("expiration")));
	insert_card.executeUpdate();
	
	String redirectURL = String.format("Profile.jsp?supplier_id=%s", new_supplier_ID);
	response.sendRedirect(redirectURL);

%>

