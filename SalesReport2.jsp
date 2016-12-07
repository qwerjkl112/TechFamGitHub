<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="java.util.Calendar" %>
<%@page import="java.text.SimpleDateFormat" %>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>Total Sales Report</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
<div class="w3-topnav w3-black">
	<a href="Login.html">Sign Out</a>
	<a href="CompanyUser.jsp">Delivery</a>
	</div>
<%
	
	//----------------------------------------------------------------------------
	// This jsp file displays sale information for company user
	//----------------------------------------------------------------------------
	// input: no input - only need to sign in with correct username and password
	// output: if adding was succesful
	//----------------------------------------------------------------------------
	// databases and fields used: 
	//     sale
	//	sales_item
	//	category
	//----------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_sale, select_item, select_address, select_category;
	ResultSet result_sale, result_item, result_address, result_category;
	String auction_or_sale;
	
  	String query_sale = "select P.auction_or_sale, P.transaction_id, P.item_id, S.name, C.description, P.price, P.date, A.city, A.state " + 
  	"from sale P, sales_item S, address A, category C " +
	"where P.item_id = S.item_id AND P.shipping_address_id = A.address_id AND S.category_id = C.category_id";
	
	select_sale = con.prepareStatement(query_sale);
	result_sale = select_sale.executeQuery();
	
%>

<div class="w3-panel w3-card w3-light-grey"><p>Sales Report</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
		<thead>
	<tr>
	<th>transaction_id</th>
	<th>item_id</th>
	<th>Item Name</th>
	<th>Category</th>
	<th>Price</th>
	<th>Purchase Date</th>
	<th>Purchase Method</th>
	<th>City</th>
	<th>State</th>
	</tr>
	</thead>
	<% 	while(result_sale.next()) { %>
	<% 		if (result_sale.getInt("auction_or_sale") == 1) {auction_or_sale = "auctioned";} else {auction_or_sale = "direct buy";} 
			long start_long = result_sale.getLong("date");
			SimpleDateFormat sdf_start = new SimpleDateFormat("yyyy MMM dd HH:mm:ss");
			Calendar cal_start = Calendar.getInstance();
			cal_start.setTimeInMillis(1000*start_long);
			String start = sdf_start.format(cal_start.getTime());		
	%>
  <tr>
	<td><a href="SalesReport3.jsp?transaction_id=<%=result_sale.getString("transaction_id") %>"><%= result_sale.getString("transaction_id") %></a></td>
  	<td><%= result_sale.getString("item_id") %></td>
  	<td><%= result_sale.getString("name") %></td>
  	<td><%= result_sale.getString("description") %></td>
  	<td><%= result_sale.getString("price") %></td>
    <td><%= start %></td>
    <td><%= auction_or_sale %></td>
    <td><%= result_sale.getString("city") %></td>
    <td><%= result_sale.getString("state") %></td>
  </tr>
  <%} %>
  </table>