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
	// This jsp file adds addresses for suppliers
	//--------------------------------------------------------------------
	// input: supplier_id of the user and all address fields
	// output: if adding was succesful
	//--------------------------------------------------------------------
	// databases and fields used: 
	//     suppliers - supplier_id
	//     address - all fields
	//--------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_address_id, insert_address, incrementID;
	ResultSet result, result_max_id;
	int new_address_ID;
	int supplier_id = Integer.parseInt((String) session.getAttribute("SupplierId"));
	try {
		Long temp = Long.parseLong(request.getParameter("zip"));
	}
	catch (NumberFormatException e) {
		// must stop program and display error warning - zip is not in correct form
		System.out.printf("zip must be a number");
	}
	
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
	insert_address.setLong(7, supplier_id);
	if (insert_address.executeUpdate() == 1) {

		String redirectURL = "DirectBuy.jsp";
		
		response.sendRedirect(redirectURL);

	}
	else {
		System.out.printf("fail");
	}
%>