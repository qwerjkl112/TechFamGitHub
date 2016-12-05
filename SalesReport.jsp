<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<html>
<body>
	<div class="w3-topnav w3-black">
	<a href="Login.jsp">Home</a>
  	<a href="Login.jsp">Suppliers</a>
 	<a href="Auction.jsp">Auction</a>
  	<a href="AddSales_ItemPage.jsp">Add an Item</a>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=session.getAttribute("SupplierId")%>'"/>
	</div>
	<center><div class="w3-container" height="700">
		<img src="/hellow/images/Check.png" alt="Check" width="600" height="460">
	</div></center>

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
	//----------------------------------------------------------------------------------------------------------
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_sale, select_saleitem, select_address, select_transaction_id, select_username, select_billing;
	ResultSet results, result_item, result_address, result_transaction_id, result_username, result_billing;

	
	// select max transaction_id - stored in result_transaction_id
	select_transaction_id = con.prepareStatement("SELECT MAX(transaction_id) FROM Sale");
	result_transaction_id = select_transaction_id.executeQuery();
	result_transaction_id.next();

	//select sale's info
	select_sale = con.prepareStatement("SELECT * " + 
			"FROM Sale S " + 
			"WHERE S.transaction_id = ?");
	select_sale.setInt(1, result_transaction_id.getInt(1));
	results = select_sale.executeQuery();	// reset 
	results.next();
	
	//sales_item
	select_saleitem = con.prepareStatement( "SELECT S.name, S.brand, S.item_id " + 
			"FROM Sales_Item S " +
			"WHERE S.item_id = ?");
	select_saleitem.setInt(1, results.getInt(5));
	result_item = select_saleitem.executeQuery();
	
	//shipping address
	select_address = con.prepareStatement( "SELECT * " + 
			"FROM Address A " +
			"WHERE A.address_id = ?");
	select_address.setInt(1, results.getInt(7));
	result_address = select_address.executeQuery();
	result_address.next();
	
	// select username
	select_username = con.prepareStatement( "SELECT C.username, C.billing_address_id " + 
			"FROM Credit_Card C " +
			"WHERE C.number = ?");
	select_username.setLong(1, results.getLong(6));
	result_username = select_username.executeQuery();
	result_username.next();
	
	//select billing address
	select_billing = con.prepareStatement( "SELECT * " + 
			"FROM Address A " +
			"WHERE A.address_id = ?");
	select_billing.setInt(1, result_username.getInt(2));
	result_billing = select_billing.executeQuery();
	result_billing.next();
	
	// this is just a test display - remove before final product				
	%>
	
	  <%while(result_item.next()){%>
	  

	  </table>
	  <div class="w3-container">
  	<center><p class="w3-xxxlarge">Thank You, <%= result_username.getString("username") %> for purchasing <%= result_item.getString("name") %>.</p></center>
	</div>
		<% } %>
	</body>
</div>
	
	
	
	
	
	