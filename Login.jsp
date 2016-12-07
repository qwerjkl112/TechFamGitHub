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
	String redirectURL = null;
	
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
		redirectURL = "http://localhost:8080/hellow/Login.html";
		response.sendRedirect(redirectURL);
	}
	int admin_id = -9999;
	if(session.getAttribute("SupplierId") != null){
	Supplierid = (String) session.getAttribute("SupplierId");
	
	admin_id = Integer.parseInt((String) session.getAttribute("SupplierId"));
	}
	
	if(admin_id == -1){
		System.out.println("shdf");
		redirectURL = "http://localhost:8080/hellow/CompanyUser.jsp";
		response.sendRedirect(redirectURL);
	}
	%>
	<%Items = con.prepareStatement("SELECT * FROM Sales_Item");
	ResultSet Itemlist = Items.executeQuery();
	%>
<ul class="w3-navbar w3-black"> 
    <li><a href="Login.jsp">Home</a></li>
    <li><a href="EnterData.jsp">Seller List</a></li>
    <li><a href="Auction.jsp">Auction</a></li>
    <li><a href="Custom_Shoes.jsp">Custom Shoes</a></li>
    <li><a href="AddSales_ItemPage.jsp">Add an Item</a></li>
    <li><a href="MyBid.jsp">My Bid</a></li>
    
    <li class="w3-dropdown-hover w3-hover-blue">
      <a class="w3-hover-blue" href="http://localhost:8080/hellow/Searching.jsp?category_id=100">Women <i class="fa fa-caret-down"></i></a>
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
      <a class="w3-hover-blue" href="http://localhost:8080/hellow/Searching.jsp?category_id=200">Men <i class="fa fa-caret-down"></i></a>
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
      <a class="w3-hover-blue" href="http://localhost:8080/hellow/Searching.jsp?category_id=300">Kids <i class="fa fa-caret-down"></i></a>
      <div class="w3-dropdown-content w3-white w3-card-4">
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=310">Girls</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=320">Boys</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=330">Babies</a>
      </div>
    </li>
      
         <li class="w3-dropdown-hover w3-hover-blue">
      <a class="w3-hover-blue" href="http://localhost:8080/hellow/Searching.jsp?category_id=400">Accessories <i class="fa fa-caret-down"></i></a>
      <div class="w3-dropdown-content w3-white w3-card-4">
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=410">Socks and Legwear</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=420">Shoe care products</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=430">Bags</a>
        <a href="http://localhost:8080/hellow/Searching.jsp?category_id=440">sunglasses</a>
      </div>
    </li> 


<input type="button" class="w3-btn" style="float:right; padding: 10px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=Supplierid%>'"/>
</ul>


<div class="w3-panel w3-card w3-deep-orange"><p>Search for An Item</p></div>
<form onsubmit="return validateForm()" class="w3-form" name="myForm" action="Searching.jsp">
  <p><input class="w3-input w3-border w3-animate-input" type="text" name="keyword" style="width:25%" placeholder="Search"></p>
  <select class="w3-select" style="width:10%" name="state">
    <option value="" selected>State</option>
    <option value="new">New</option>
    <option value="old">Old</option>
  </select>
  <p><input style="width:10%" class="w3-input" type="number" name="bottom_price" placeholder="Bottom Price"><input style="width:10%" class="w3-input" type="number" name="top_price" placeholder="Top Price"></p>
  <p><button class="w3-btn">Search</button></p>
</form>	
<script>
function validateForm() {
    var x = document.forms["myForm"]["keyword"].value;
    var y = document.forms["myForm"]["bottom_price"].value;
    var z = document.forms["myForm"]["top_price"].value;
    var state = document.forms["myForm"]["state"].value;
    state = "new";
    if (x == "") {
        alert("keyword cannot be left empty");
        return false;
    }
    if (y == ""){
    	return true;
    }
    if(isNaN(y) || y < 0 || y > 100000){
    	alerat("number fields must be numbers between 1 - 99999");
    	return false;
    }
}
</script>

<div class="w3-panel w3-card w3-deep-orange"><p>Item Listing</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
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

