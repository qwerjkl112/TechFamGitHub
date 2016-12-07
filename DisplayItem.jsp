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
<body onLoad="DisplayImage()">
<script>
function DisplayImage() {
    var x = document.createElement("IMG");
    x.setAttribute("src", "/hellow/images/<%=request.getParameter("item_id")%>.png");
    x.setAttribute("width", "304");
    x.setAttribute("width", "228");
    x.setAttribute("alt", "image");
    document.body.appendChild(x);
}
</script>
<div class="w3-topnav w3-black">
	<a href="Login.jsp">Home</a>
  	<a href="Login.jsp">Suppliers</a>
 	<a href="Auction.jsp">Auction</a>
 	<a href="Custom_Shoes.jsp">Custom Shoes</a>
  	<a href="AddSales_ItemPage.jsp">Add an Item</a>
  	<a href="MyBid.jsp">My Bids</a>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=session.getAttribute("SupplierId")%>'"/>
</div>

	<%
	
	//----------------------------------------------------------------------------------------------------------
	// This jsp file displays the desired item information.
	//----------------------------------------------------------------------------------------------------------
	// input: item_id
	// output: the fields below (except the id's) - stored in ResultSet data listed below
	//----------------------------------------------------------------------------------------------------------
	// databases and fields used: 
	//     Sales_Item - item_id, count, brand, list_price, state, description, 
	//                  name, category_id, supplier_id (stored in ResultSet result_item)
	//     category - category_id, description (stored in ResultSet result_category)
	//     suppliers - supplier_id, name (stored in ResultSet result_supplier;)
	//----------------------------------------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_item, select_category, select_supplier, select_comments;
	ResultSet result_item, result_category, result_supplier, result_comments;
	
	// find sales item information
	select_item = con.prepareStatement("SELECT count, brand, list_price, state, description, name, category_id, supplier_id " + 
			   							"FROM sales_item " + 
			   							"WHERE item_id = ?");
	select_item.setInt(1, Integer.parseInt(request.getParameter("item_id")));
	result_item = select_item.executeQuery();
	result_item.next();	// select the item result - this is needed for finding the category and supplier
	
	//set session
	session.setAttribute("ItemId", request.getParameter("item_id"));
	// find category where the item is categorized
	select_category = con.prepareStatement("SELECT description FROM category WHERE category_id = ?");
	select_category.setInt(1, result_item.getInt("category_id"));
	result_category = select_category.executeQuery();
	result_category.next(); // select the category result
	
	
	// find supplier information
	select_supplier = con.prepareStatement("SELECT name FROM suppliers WHERE supplier_id = ?");
	select_supplier.setInt(1, result_item.getInt("supplier_id"));
	result_supplier = select_supplier.executeQuery();
	result_supplier.next(); // select the supplier result
	
	
	
	
// this is just a test display 					
%>
<div class="w3-container"><div id='image'></div></div>
<div class="w3-container w3-red">
  <h1>Item Description</h1>
</div>

<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
<tr>
    <th>Item Name</th>
    <th>Supplier Name</th> 
    <th>Category</th>
    <th>Brand</th>
    <th>List Price</th>
    <th>State</th>
    <th>Item Description</th>
    <th>Count</th>
  </tr>
  <tr>
  	<td><%= result_item.getString("name") %></td>
  	<td><a href="Profile.jsp?supplier_id=<%=result_item.getInt("supplier_id")%>"><%= result_supplier.getString("name") %></a></td>
  	<td><%= result_category.getString("description") %></td>
    <td><%= result_item.getString("brand") %></td> 
    <td><%= result_item.getString("list_price") %></td>
    <td><%= result_item.getString("state") %></td>
    <td><%= result_item.getString("description") %></td>
    <td><%= result_item.getString("count") %></td>
  </tr>
</table>
<div class="w3-container w3-red">
  <h1>Reviews from verified buyers</h1>
</div>
<%// find comments information
select_comments = con.prepareStatement("SELECT username, value, explanation " + 
		      "FROM Item_Review " + 
		      "WHERE item_id = ?");
select_comments.setInt(1, Integer.parseInt(request.getParameter("item_id")));
result_comments = select_comments.executeQuery();
// select the supplier result %>

<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
<thead>
<tr>
	<th>username</th>
	<th>value</th>
	<th>explanation</th>
</tr>
</thead>
    <%float average, total = 0, count=0; %>
    <%while(result_comments.next()){
    total+= (result_comments.getFloat("value"));
    System.out.println(total);
    count++;%>
  <tr>
	 <td><%= result_comments.getString("username") %></td>
	 <td><%= result_comments.getString("value") %></td>
	 <td><%= result_comments.getString("explanation") %></td>
  </tr>
  <%} %>
  </table>
  
 <form class="w3-form" action="AddItemReview.jsp">
  <h2>Input Form</h2>
  <p><input class="w3-input" type="hidden" name="username" value="<%=session.getAttribute("UserName")%>"></p>
  <p><input class="w3-input" type="hidden" name="item_id" value="<%=session.getAttribute("ItemId")%>"></p>
  <select class="w3-select" name="value">
    <option value="" disabled selected>Rating:</option>
    <option value="1">&#x2605&#x2606&#x2606&#x2606&#x2606</option>
    <option value="2">&#x2605&#x2605&#x2606&#x2606&#x2606</option>
    <option value="3">&#x2605&#x2605&#x2605&#x2606&#x2606</option>
    <option value="4">&#x2605&#x2605&#x2605&#x2605&#x2606</option>
    <option value="5">&#x2605&#x2605&#x2605&#x2605&#x2605</option>
  </select>
  <p><textarea class="w3-input" name="explanation" placeholder="Subject"></textarea></p>
  <p><button class="w3-btn">Submit</button></p>
</form>
  <div class="w3-panel w3-card w3-pale-green"><p>This user's average rating is <%=total/count%></p></div>
<a class="w3-btn w3-ripple w3-teal" href="DirectBuy.jsp" >Buy this item</a> 
</body>