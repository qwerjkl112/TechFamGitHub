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
		session.setAttribute("SupplierId", Supplierid);
		session.setAttribute("UserName", username);
	}
	else{
		 String redirectURL = "http://localhost:8080/hellow/Login.html";
		 response.sendRedirect(redirectURL);
	}
	%>
	<%Items = con.prepareStatement("SELECT * FROM Sales_Item");
	ResultSet Itemlist = Items.executeQuery();
	%>
<ul class="w3-navbar w3-black">
    <li><a href="Login.html">Home</a></li>
    <li><a href="EnterData.jsp">Seller List</a></li>
    <li><a href="Auction.jsp">Auction</a></li>
    
    <li class="w3-dropdown-hover w3-hover-blue">
      <a class="w3-hover-blue" href="#">Women <i class="fa fa-caret-down"></i></a>
      <div class="w3-dropdown-content w3-white w3-card-4">
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=110">Boots</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=120">Flats</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=130">Pumps</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=140">Slippers</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=160">Wedges</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=150">Athletic</a>
        
      </div>
    </li>
    <li class="w3-dropdown-hover w3-hover-blue">
      <a class="w3-hover-blue" href="#">Men <i class="fa fa-caret-down"></i></a>
      <div class="w3-dropdown-content w3-white w3-card-4">
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=210">Athletic</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=220">Boots</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=230">Casual</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=240">Dress shoes</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=250">Sandals</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=260">Slippers</a>
      </div>
    </li>
    <li class="w3-dropdown-hover w3-hover-blue">
      <a class="w3-hover-blue" href="#">Kids <i class="fa fa-caret-down"></i></a>
      <div class="w3-dropdown-content w3-white w3-card-4">
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=310">Girls</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=320">Boys</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=330">Babies</a>
      </div>
    </li>
      
         <li class="w3-dropdown-hover w3-hover-blue">
      <a class="w3-hover-blue" href="#">Accessories <i class="fa fa-caret-down"></i></a>
      <div class="w3-dropdown-content w3-white w3-card-4">
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=410">Socks and Legwear</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=420">Shoe care products</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=430">Bags</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=440">sunglasses</a>
      </div>
    </li> 
  	<input type="button" class="w3-btn" style="float:right; padding: 10px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=Supplierid%>'"/>

</ul>
	
	

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

