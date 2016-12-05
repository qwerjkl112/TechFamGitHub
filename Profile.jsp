<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="hellow.Get_Drop_Downs"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Calendar" %>
<%@page import="java.text.SimpleDateFormat" %>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>My Profile</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
	<%
	
	//----------------------------------------------------------------------------
	// This jsp file displays the desired user information, including basic user 
	// info (name, email, etc.) and all the user's ratings.
	//----------------------------------------------------------------------------
	// input: supplier_id
	// output: the fields below (except id's) - stored in ResultSet data below
	//----------------------------------------------------------------------------
	// databases and fields used: 
	//     suppliers - supplier_id, name (stored in result_user)
	//     register_user - username, age, gender, income (stored in result_user)
	//     rating - username, explanation, value (stored in result_ratings)
	//----------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_user, select_ratings, select_items, select_auction, select_sale, select_purchases, select_credit_card, select_address, select_auction2;
	ResultSet result_user, result_ratings, result_items, result_auction, result_sale, result_purchases, result_credit_card, result_address, result_auction2;
	String sql_query = "SELECT * FROM sale WHERE credit_card_number = ";
	String sql_query_purchases = "SELECT * FROM "+
			"(SELECT * "+
			"FROM sales_item S "+
			"WHERE S.item_id = ";
	String sql_query_purchases2 = ")AS T1 "+
			"LEFT JOIN "+ 
			"(SELECT H.item_id as item_id2, I.image, H.color "+
			"FROM has_visual H, image I "+
			"WHERE I.img_id = H.img_id) AS T2 "+
			"ON T1.item_id = T2.item_id2";
	String sql_query_address = "SELECT * FROM address WHERE address_id = ";
	String SQL_AUCTION = 
			"SELECT TA.item_id, TA.name, TA.description, TA.category_name, "+
			"TA.timestamp_start, TA.timestamp_end, TA.amount, TA.reserved_price, TP.image FROM " +
			"(SELECT T1.item_id, T1.name, T1.description, T1.category_name, " +
			"T1.timestamp_start, T1.timestamp_end, T1.reserved_price, T2.amount FROM "+
			"(SELECT I.item_id, I.name, I.description, C.category_name, "+
			"A.timestamp_start, A.timestamp_end, I.reserved_price "+
			"FROM sales_item I, auction A, Category C "+
			"WHERE A.item_id = I.item_id AND "+
			"I.category_id = C.category_id AND "+
			"I.supplier_id = ?) AS T1 "+
			"LEFT JOIN "+
			"(SELECT item_id, auction_timestamp_start, MAX(amount) as amount "+ 
			"FROM Bid "+
			"group by item_id, auction_timestamp_start) AS T2 "+
			"ON T1.item_id = T2.item_id AND T1.timestamp_start = T2.auction_timestamp_start) TA "+
			"LEFT JOIN "+
			"(SELECT H.item_id, Min(P.image) as image "+
			"FROM has_visual H, image P " +
			"WHERE H.img_id = P.img_id "+
			"group by H.item_id ) AS TP "+
			"ON TA.item_id = TP.item_id";
	String name = null;
	String username = null;
	String age = null;
	String gender = null;
	String income = null;
	String lastuser = null;
	String supplier = null;
	String item_name = null;
	String brand = null;
	String list_price = null;
	String state = null;
	long current_time = System.currentTimeMillis()/1000;
	
	// find basic user info
	select_user = con.prepareStatement("SELECT s.name, ru.username, ru.age, ru.gender, ru.income " + 
					   "FROM suppliers s, register_users ru " + 
					   "WHERE s.supplier_id = ? and ru.supplier_id = ?");
	
	String SQL_ITEMS = 	"SELECT * FROM "+
			"(SELECT * "+
			"FROM sales_item S "+
			"WHERE S.supplier_id = ?) AS T1 "+
			"LEFT JOIN "+ 
			"(SELECT H.item_id as item_id2, I.image, H.color "+
			"FROM has_visual H, image I "+
			"WHERE I.img_id = H.img_id) AS T2 "+
			"ON T1.item_id = T2.item_id2";
	
	int supplier_id = Integer.parseInt(request.getParameter("supplier_id"));
	select_items = con.prepareStatement(SQL_ITEMS);
	select_items.setInt(1, supplier_id);
	result_items = select_items.executeQuery();
	
	select_user.setInt(1, Integer.parseInt(request.getParameter("supplier_id")));
	select_user.setInt(2, Integer.parseInt(request.getParameter("supplier_id")));
	supplier = request.getParameter("supplier_id");

	select_auction2 = con.prepareStatement(SQL_AUCTION);
	select_auction2.setInt(1, supplier_id);
	result_auction2 = select_auction2.executeQuery();
	
	// result_user contains desired user information
	result_user = select_user.executeQuery();
	
	
	// find all the ratings for that user
	select_ratings = con.prepareStatement("SELECT username, value, explanation " + 
			   		      "FROM rating " + 
			   		      "WHERE supplier_id = ?");
	select_ratings.setInt(1, Integer.parseInt(request.getParameter("supplier_id")));
			
	// result_ratings contains all ratings for user
	result_ratings = select_ratings.executeQuery();
			
	// find all the items the seller has
	select_items = con.prepareStatement("SELECT * " + 
			   		      "FROM sales_item " + 
			   		      "WHERE supplier_id = ?");
	select_items.setInt(1, Integer.parseInt(request.getParameter("supplier_id")));
			

	
	
	
	// select all of the user's credit card number
	select_credit_card = con.prepareStatement("SELECT number FROM credit_card WHERE username = ?");
	
	while(result_user.next()){
		name = result_user.getString("name");
		username = result_user.getString("username");
		age = result_user.getString("age");
		gender = result_user.getString("gender");
		income = result_user.getString("income");
		
		select_credit_card.setString(1, result_user.getString("username"));
	}
	
	result_credit_card = select_credit_card.executeQuery();
	
	if (result_credit_card.next()) {
		sql_query += result_credit_card.getLong(1) + " ";
	}
	else {
		sql_query += "-900";
	}
	while(result_credit_card.next()) {
		sql_query += "AND " + result_credit_card.getLong(1) + " ";
	}
	select_sale = con.prepareStatement(sql_query);
	result_sale = select_sale.executeQuery();
		
	
	if (result_sale.next()) {
		sql_query_purchases += result_sale.getInt(5) + " ";
		sql_query_address += result_sale.getInt(7) + " ";
	}
	else {
		sql_query_purchases += "-900";
		sql_query_address += "-900";
	}
	while(result_sale.next()) {
		sql_query_purchases += "AND " + result_sale.getInt(5) + " ";
		sql_query_address += "AND " + result_sale.getInt(7) + " ";
	}
	
	sql_query_purchases += sql_query_purchases2;
	select_purchases = con.prepareStatement(sql_query_purchases);
	result_purchases = select_purchases.executeQuery(); // contain item information of user purchases
	select_address = con.prepareStatement(sql_query_address);
	result_address = select_address.executeQuery();	// contain shipped to address
	result_sale = select_sale.executeQuery(); // contain sales involving user's credit card
	
// this is just a test display 					
	%>
<div class="w3-topnav w3-black">
	<a href="Login.jsp">Home</a>
  	<a href="Login.jsp">Suppliers</a>
 	<a href="Auction.jsp">Auction</a>
  	<a href="AddSales_ItemPage.jsp">Add an Item</a>
  	<a href="Auction.jsp">Auction</a>
</div>

<div class="w3-panel w3-card w3-light-grey"><p>Profile Details</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
<thead>
	<tr>
    <th>Name</th>
    <th>Username</th> 
    <th>Age</th> 
    <th>Gender</th> 
    <th>Income</th> 
  </tr>
  </thead>

  <tr>
    <td><%= name %></td>
    <td><%= username %></td> 
    <td><%= age %></td>
    <td><%= gender %></td>
    <td><%= income %></td>
  </tr>
</table>

<div class="w3-panel w3-card w3-light-grey"><p>My Orders</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
		<thead>
	<tr>
	<th>Image</th>
	<th>Item Name</th>
	<th>Brand</th>
	<th>State</th>
	<th>Price</th>
	<th>Shipped To</th>
	</tr>
	</thead>
    <%while(result_purchases.next()){%>
  <tr>
  	<td><%= result_purchases.getString("image") %></td>
  	<td><%= result_purchases.getString("name") %></td>
    <td><%= result_purchases.getString("brand") %></td>
    <td><%= result_purchases.getString("state") %></td>
    <%result_sale.next(); %>
    <td><%= result_sale.getString("price") %></td>
    <%result_address.next(); %>
    <td><%= result_address.getString("street_address") %></td>
  </tr>
  <%} %>
  </table>
  
<div class="w3-panel w3-card w3-light-grey"><p>My Auction</p></div>
<%while(result_auction2 != null && result_auction2.next()){ 
	String image = result_auction2.getString("image");
	if(image == null){
		image = "null";
	}
	int item_id = result_auction2.getInt("item_id");
	String name2 = result_auction2.getString("name");
	
	long start_long = result_auction2.getLong("timestamp_start");
	long end_long = result_auction2.getLong("timestamp_end");
	SimpleDateFormat sdf_start = new SimpleDateFormat("yyyy MMM dd HH:mm:ss");
	SimpleDateFormat sdf_end = new SimpleDateFormat("yyyy MMM dd HH:mm:ss");
	Calendar cal_start = Calendar.getInstance();
	Calendar cal_end = Calendar.getInstance();
	cal_start.setTimeInMillis(1000*start_long);
	cal_end.setTimeInMillis(1000*end_long);
	String start = sdf_start.format(cal_start.getTime());
	String end = sdf_end.format(cal_end.getTime());
	
	Float amount = result_auction2.getFloat("amount");
	if(amount == null){

  		amount = 0.0f;
  	}
	
	Float reserved_price = result_auction2.getFloat("reserved_price");
	
%>
<div style = "clear:both;">
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
<tr>
    <th>Image</th>
    <th>Item Name</th>
    <th>Start Time</th>
    <th>End Time</th>
    <th>Highest Bid</th>
    <th>Reserved Price</th>
  </tr>
  <tr>
    <td><%= image%></td>
  	<td><%=  name2%></td>
    <td><%= start%></td>
    <td><%= end%></td>
    <td><%= amount%></td>
    <td><%= reserved_price%></td>
  </tr>
</table>

<%if(current_time > end_long && (Integer.parseInt((String) session.getAttribute("SupplierId")) == Integer.parseInt(request.getParameter("supplier_id")))){ %>
<form action="EndAuction.jsp">
	<input type="hidden" name="item_id" value=<%=item_id %> />
	<input type="hidden" name="supplier_id" value=<%=Integer.parseInt(request.getParameter("supplier_id"))%> />
	<input type="hidden" name="auction_timestamp_start" value=<%= start_long%> />
	<input value="Complete Auction" type="submit"/>
</form>
<%} %>

</div>
 <%} %>
<div class="w3-panel w3-card w3-light-grey"><p>My Items</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
	<thead>
	<tr>
	<th>Image</th>
	<th>Item Name</th>
	<th>Count</th>
	<th>Brand</th>
	<th>State</th>
	<th>Description</th>
	<th>List Price</th>
	<th>Reserved Price</th>
	<% if(Integer.parseInt((String) session.getAttribute("SupplierId")) == Integer.parseInt(request.getParameter("supplier_id"))){%>
	<th>Start an Auction</th>
	<%} %>
	</tr>
	</thead>
    <%while(result_items.next()){%>
  <tr>
	<td><%= result_items.getString("image") %></td>
  	<td><%= result_items.getString("name") %></td>
  	<td><%= result_items.getString("count") %></td>
    <td><%= result_items.getString("brand") %></td>
    <td><%= result_items.getString("state") %></td>
    <td><%= result_items.getString("description") %></td>
    <td><%= result_items.getString("list_price") %></td>
    <td><%= result_items.getString("reserved_price") %></td>
    <% if(Integer.parseInt((String) session.getAttribute("SupplierId")) == Integer.parseInt(request.getParameter("supplier_id"))){ %>
    <td><button onclick="StartAuction()" class="w3-btn w3-light-grey">Auction</button><div id="auction" class="w3-dropdown-content w3-light-grey w3-left" style="left:50%;">
    		<div class="w3-container w3-right-align">
        		<form class="w3-form" action="Start_Auction.jsp" style="width:100%" style="float:left" method="post">
	  				<h3>Auction End Time</h3>
	 				<input class="w3-input" type="text" name="timestamp_end" required>
	 				<label class="w3-label w3-validate">Time to end</label>
	 				<input type="hidden" name="item_id" value="<%= result_items.getInt("item_id") %>"/>
	 				<input type="hidden" name="supplier_id" value="<%= Integer.parseInt(request.getParameter("supplier_id")) %>"/>
	 				<p><button class="w3-btn" type="submit" >Start this Auction</button></p>
				</form>
     		</div>
      </div></td>
      <%} %>
  </tr>
  <%} %>
  </table>
 <script>
	function StartAuction() {
	    var x = document.getElementById("auction");
	    if (x.className.indexOf("w3-show") == -1) {
	        x.className += " w3-show";
	        x.className += " w3-half"
	    } else {
	        x.className = x.className.replace(" w3-show", "");
	    }
	}
</script>
<div class="w3-panel w3-card w3-light-grey "><p>Comments and Rating</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
<thead>
<tr>
	<th>username</th>
	<th>value</th>
	<th>explanation</th>
</tr>
</thead>
    <%while(result_ratings.next()){%>
  <tr>
	 <td><%= result_ratings.getString("username") %></td>
	 <td><%= result_ratings.getString("value") %></td>
	 <td><%= result_ratings.getString("explanation") %></td>
  </tr>
  <%} %>
  </table>
<%if(Integer.parseInt((String) session.getAttribute("SupplierId")) != Integer.parseInt(request.getParameter("supplier_id"))){ %>
<div class="w3-panel w3-card w3-light-grey"><p>Input Form</p></div>
<form class="w3-form" action="AddComment.jsp">
  <p><input class="w3-input" type="hidden" name="username" value="<%=session.getAttribute("UserName")%>"></p>
  <p><input class="w3-input" type="hidden" name="supplier_id" value="<%=request.getParameter("supplier_id")%>"></p>
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
<%} %>
</body>
</html>


