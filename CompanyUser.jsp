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
	
	//----------------------------------------------------------------------------
	// This jsp file displays ups information for company user
	//----------------------------------------------------------------------------
	// input: no input - only need to sign in with correct username and password
	// output: a page with shipping information
	//----------------------------------------------------------------------------
	// databases and fields used: 
	//     address
	//	sale
	//     ups
	//----------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_ups;
	ResultSet result_ups;
	String auction_or_sale;
	String query = "select S.transaction_id, S.item_id, S.date, A.app_num, A.street_address, A.city, A.state, A.zip, U.shipping_date, U.shipping_method  " +
					"from sale S, ups U, address A " + 
					"where S.transaction_id = U.transaction_id and S.shipping_address_id = A.address_id";
	
	select_ups = con.prepareStatement(query);
	result_ups = select_ups.executeQuery();
	
%>


<div class="w3-panel w3-card w3-light-grey"><p>Current Shipping Information</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
		<thead>
	<tr>
	<th>transaction_id</th>
	<th>item_id</th>
	<th>Purchase Date</th>
	<th>Apartment Number</th>
	<th>Street Address</th>
	<th>City</th>
	<th>State</th>
	<th>Zip</th>
	<th>Shipping Date</th>
	<th>Delivery Status</th>
	<th>Change Status</th>
	</tr>
	</thead>
	<%while(result_ups.next()){%>
  <tr>
  	<td><%= result_ups.getString("transaction_id") %></td>
  	<td><%= result_ups.getString("item_id") %></td>
    <td><%= result_ups.getString("date") %></td>
    <td><%= result_ups.getString("app_num") %></td>
    <td><%= result_ups.getString("street_address") %></td>
    <td><%= result_ups.getString("city") %></td>
    <td><%= result_ups.getString("state") %></td>
    <td><%= result_ups.getString("zip") %></td>
    <td><% long start_long = result_ups.getLong("shipping_date");
	SimpleDateFormat sdf_start = new SimpleDateFormat("yyyy MMM dd HH:mm:ss");
	Calendar cal_start = Calendar.getInstance();
	cal_start.setTimeInMillis(1000*start_long);
	String start = sdf_start.format(cal_start.getTime()); %><%=	
			start%></td>
    <td><%= result_ups.getString("shipping_method") %></td>
    <td>
        		<form class="w3-form" action="ChangeDelivery.jsp" style="float:left" method="post">
	 				 <p><input class="w3-radio" type="radio" name="shipping_method" value="Not Yet Shipped" checked>
  					 <label class="w3-validate">Not Yet Shipped</label></p>
  					 <p><input class="w3-radio" type="radio" name="shipping_method" value="Shipped">
  					 <label class="w3-validate">Shipped</label></p>
  					 <p><input class="w3-radio" type="radio" name="shipping_method" value="Delivered">
  					 <label class="w3-validate">Delivered</label></p>
  					 <input type="hidden" name="transaction_id" value="<%= result_ups.getString("transaction_id") %>"/>
	 				 <p><button class="w3-btn" type="submit" >Confirm Shipping</button></p>
				</form>
	</td>
  </tr>
  <%} %>
  </table>
  <script>
	function Change() {
	    var x = document.getElementById("delivery");
	    if (x.className.indexOf("w3-show") == -1) {
	        x.className += " w3-show";
	        x.className += " w3-half"
	    } else {
	        x.className = x.className.replace(" w3-show", "");
	    }
	}
</script>
</body>
</html>