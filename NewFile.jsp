<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<body>
	
<%
	
	//----------------------------------------------------------------------------------------------------------
	// This jsp file displays the items that the suer has already purchased
	//----------------------------------------------------------------------------------------------------------
	// input: username
	// output: the fields below 
	//----------------------------------------------------------------------------------------------------------
	// databases and fields used: 
	//  Sales_Item - all fields
	//	Sale - all fields
	//	Address - all fields except id (this is where the item is going)
	//	Register_User - username
	//----------------------------------------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_sale, select_item, select_credit_card, select_address;
	ResultSet result_sale, result_item =  null, result_credit_card, result_address = null;
	
	// select all of the user's credit card number
	select_credit_card = con.prepareStatement("SELECT number FROM credit_card WHERE username = ?");
	select_credit_card.setString(1, request.getParameter("username"));
	result_credit_card = select_credit_card.executeQuery();
	
	while(result_credit_card.next()) {
	  	select_sale = con.prepareStatement("SELECT * FROM sale WHERE credit_card_number = ?");
	  	select_sale.setLong(1, result_credit_card.getLong(1));
		result_sale = select_sale.executeQuery(); // contain sales involving user's credit card
		
		while(result_sale.next()) {
	    	select_item = con.prepareStatement("SELECT * FROM sales_item WHERE item_id = ?");
	    	select_item.setInt(1, result_sale.getInt(5));
	    	result_item = select_item.executeQuery(); // contains items bought
	    	
	    	select_address = con.prepareStatement("SELECT * FROM address WHERE address_id = ?");
	    	select_address.setInt(1, result_sale.getInt(7));
	    	result_address = select_address.executeQuery(); // contains items bought
	    	
			while (result_item.next()) {
				System.out.printf("%s", result_item.getString("name"));
			}
	    		while (result_address.next()) {
				System.out.printf("%s", result_address.getString("street_address"));
			}
	   	}
	}
	%>
	