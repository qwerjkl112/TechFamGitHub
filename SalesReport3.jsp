<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="java.util.Calendar" %>
<%@page import="java.text.SimpleDateFormat" %>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>Welcome Company User</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
<div class="w3-topnav w3-black">
	<a href="Login.html">Sign Out</a>
	<a href="SalesReport2.jsp">Sales Report</a>
	</div>
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
//Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfamforever?autoReconnect=true&useSSL=false","root", "TechFam");
	PreparedStatement select_sale;
	ResultSet result_sale;
	
	//select sale's info
	select_sale = con.prepareStatement("SELECT C.username, P.date, S.item_id, S.name, P.price, A.street_address as s_street_address, A.app_num as s_app_num, A.city as s_city, A.state as s_state, A.zip as s_zip, B.app_num as b_app_num, B.street_address as b_street_address, B.city as b_city, B.state as b_state, B.zip as b_zip FROM Sale P, Sales_Item S, Credit_Card C, Address A, Address B WHERE P.transaction_id = ? AND P.item_id = S.item_id AND P.credit_card_number = C.number AND C.billing_address_id = B.address_id AND P.shipping_address_id = A.address_id;");
	int transaction_id = Integer.parseInt(request.getParameter("transaction_id"));
	select_sale.setInt(1,  transaction_id);
	result_sale = select_sale.executeQuery();
	
	// this is just a test display - remove before final product				
	%>

<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
<thead>
	<tr>
	    <th>Item Id</th>
	    <th>Name of Buyer</th> 
	    <th>Price</th>
	    <th>Date</th>
	    <th>Shipping Address</th>
	    <th>Billing Address</th>
	    <th>Username</th>
	  </tr>
	  </thead>
	  <%while(result_sale.next()){
		long start_long = result_sale.getLong("date");
		SimpleDateFormat sdf_start = new SimpleDateFormat("yyyy MMM dd HH:mm:ss");
		Calendar cal_start = Calendar.getInstance();
		cal_start.setTimeInMillis(1000*start_long);
		String start = sdf_start.format(cal_start.getTime());
		
		String billing = result_sale.getString("b_street_address") +" ";
		if(result_sale.getString("b_app_num") != null){
			billing += result_sale.getString("b_app_num");	
		}
		billing+="\n";
		billing+=result_sale.getString("b_city") +" ";
		billing += result_sale.getString("b_state") +" ";
		billing += result_sale.getString("b_zip");
		
		String ship = result_sale.getString("s_street_address") +" ";
		if(result_sale.getString("s_app_num") != null){
			ship += result_sale.getString("s_app_num");	
		}
		ship+="\n";
		ship+=result_sale.getString("s_city") +" ";
		ship += result_sale.getString("s_state") +" ";
		ship += result_sale.getString("s_zip");
		
	  %>
	  <tr>
	    <td><%= result_sale.getInt("item_id") %></td>
	    <td><%= result_sale.getString("name") %></td>
	    <td><%= result_sale.getFloat("price") %></td>
	    <td><%= start %></td>
	    <td><%= ship %></td>
	    <td><%= billing %></td>
	    <td><%= result_sale.getString("username") %></td>
	  </tr>
	  <% } %>

	  </table>
	</body>