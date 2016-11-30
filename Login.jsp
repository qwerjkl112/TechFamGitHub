<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>TechFam</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
	<%
	
	//-----------------------------------------------------
	// databases and fields used: register_user - username, password
	// return: if login was successful or failed
	//-----------------------------------------------------
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement verify;
	PreparedStatement Items;
	
	session.setAttribute("UserName", request.getParameter("username"));
	
	verify = con.prepareStatement("SELECT * FROM register_users WHERE username = ? AND password = SHA1(?)");
	verify.setString(1, request.getParameter("username"));
	verify.setString(2, request.getParameter("password"));
	ResultSet result = verify.executeQuery();
	String username = null;
	String Supplierid = null;
	if(result.next()){
		username = result.getString("username");
		Supplierid = result.getString("supplier_id");	
	}
	else{
		 String redirectURL = "http://localhost:8080/hellow/Login.html";
		 response.sendRedirect(redirectURL);
	}
	%>
	<%Items = con.prepareStatement("SELECT * FROM Sales_Item");
	ResultSet Itemlist = Items.executeQuery();
	%>
<div class="w3-topnav w3-black">
	<a href="Login.html">Home</a>
  	<a href="#">Link 1</a>
 	<a href="EnterData.jsp">Seller List</a>
  	<a href="#">Link 3</a>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=Supplierid%>'"/>
</div>
	
	

<p style='color:red'> Suppliers List</p>
<div class="w3-container">
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:50%;">
 <thead>
  <tr>
    <th>name</th>
    <th>suppliers</th>
  </tr>
 </thead>
<%Items = con.prepareStatement("SELECT * FROM register_users");
  Itemlist = Items.executeQuery();
  while(Itemlist.next()){%>
  <tr>
	  <td><a href="Profile.jsp?supplier_id=<%=Itemlist.getString("supplier_id")%>"><%= Itemlist.getString("username") %></a></td>
	  <td><%= Itemlist.getString("supplier_id") %></td>
  </tr>
  <%} %>
  
</table>
</div>
<div class="w3-panel w3-card w3-deep-orange"><p>Item Listing</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:50%;">
<thead>
<tr>
    <th>brand</th>
    <th>list_price</th> 
    <th>description</th> 
    <th>reserved_price</th> 
    <th>name</th> 
    <th>item_id</th> 
  </tr>
</thead>
  <%Items = con.prepareStatement("SELECT * FROM Sales_Item");
	Itemlist = Items.executeQuery();
	%>
	<%while(Itemlist.next()){%>
  <tr>
    <td><a href="DisplayItem.jsp?item_id=<%=Itemlist.getString("item_id")%>"><%= Itemlist.getString("brand") %></a></td>
    <td><a href="DisplayItem.jsp?item_id=<%=Itemlist.getString("item_id")%>"><%= Itemlist.getString("list_price") %></a></td> 
    <td><a href="DisplayItem.jsp?item_id=<%=Itemlist.getString("item_id")%>"><%= Itemlist.getString("description") %></a></td>
    <td><a href="DisplayItem.jsp?item_id=<%=Itemlist.getString("item_id")%>"><%= Itemlist.getString("reserved_price") %></a></td>
    <td><a href="DisplayItem.jsp?item_id=<%=Itemlist.getString("item_id")%>"><%= Itemlist.getString("name") %></a></td>
    <td><a href="DisplayItem.jsp?item_id=<%=Itemlist.getString("item_id")%>"><%= Itemlist.getString("item_id") %></a></td>
  </tr>
  <% } %>

</table>

