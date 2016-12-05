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
	// This jsp file displays the sales report for all your current transactions. Filters include keywords, 
	// price range, state, and size.
	//----------------------------------------------------------------------------------------------------------
	// input: transaction_id
	// output: the fields below 
	//----------------------------------------------------------------------------------------------------------
	// databases and fields used: 
	//  Sales_Item - brand, state, name
	//	Sale - all fields
	//	Address - all fields except id (this is where the item is going)
	//	Register_User - username
	//----------------------------------------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_sale, select_saleitem, select_address, select_transaction_id, select_username, select_billing;
	ResultSet result_sale, result_item, result_address, result_transaction_id, result_username, result_billing;

	//select sale's info
	select_sale = con.prepareStatement("SELECT * " + 
			"FROM Sale S " + 
			"WHERE S.transaction_id = ?");
	select_sale.setString(1,  request.getParameter("transaction_id"));
	result_sale = select_sale.executeQuery();	
	result_sale.next();
	
	//sales_item
	select_saleitem = con.prepareStatement( "SELECT S.name, S.brand, S.item_id " + 
			"FROM Sales_Item S " +
			"WHERE S.item_id = ?");
	select_saleitem.setInt(1, result_sale.getInt(5));
	result_item = select_saleitem.executeQuery();	// containts item info
	
	//shipping address
	select_address = con.prepareStatement( "SELECT * " + 
			"FROM Address A " +
			"WHERE A.address_id = ?");
	select_address.setInt(1, result_sale.getInt(7));
	result_address = select_address.executeQuery();
	result_address.next();	// contains shipping address
	
	// select username
	select_username = con.prepareStatement( "SELECT C.username, C.billing_address_id " + 
			"FROM Credit_Card C " +
			"WHERE C.number = ?");
	select_username.setLong(1, result_sale.getLong(6));
	result_username = select_username.executeQuery();
	result_username.next();	// contains username of buyer
	
	//select billing address
	select_billing = con.prepareStatement( "SELECT * " + 
			"FROM Address A " +
			"WHERE A.address_id = ?");
	select_billing.setInt(1, result_username.getInt(2));
	result_billing = select_billing.executeQuery();
	result_billing.next();	// contains billing address
	
	// this is just a test display - remove before final product				
	%>

	<p style='color:red'> This is the user</p>
	<table style='width:100%'>
	<tr>
	    <th>Name</th>
	    <th>ID</th> 
	  </tr>
	  <%while(result_item.next()){%>
	  <tr>
	    <td><%= result_item.getInt("item_id") %></td>
	    <td><%= result_item.getString("name") %></td>
	    <td><%= result_sale.getFloat("price") %></td>
	    <td><%= result_sale.getInt("date") %></td>
	    <td><%= result_address.getString("street_address") %></td>
	    <td><%= result_billing.getString("street_address") %></td>
	    <td><%= result_username.getString("username") %></td>
	  </tr>
	  <% } %>

	  </table>
	</body>