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
	//Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfamforever?autoReconnect=true&useSSL=false","root", "TechFam");
	
	PreparedStatement select_user, select_ratings, select_items, select_auction, select_purchases, select_address, select_auction2;
	ResultSet result_user, result_ratings, result_items, result_auction, result_purchases, result_auction2;
	
	String sql_query_purchases = 
			"SELECT TM.item_id, TM.brand, TM.price, TM.name, TM.state, TM.street_address, TM.image, TM.color, TM.transaction_id, TU.shipping_method FROM "+
			"(SELECT T1.item_id, T1.brand, T1.price, T1.name, T1.state, T1.street_address, T2.image, T2.color, T1.transaction_id FROM "+
			"(SELECT S.item_id, S.brand, S.name, S.state, P.price, A.street_address, P.transaction_id "+
			"FROM sales_item S, sale P, credit_card C, address A "+
			"WHERE S.item_id = P.item_id AND " +
			"P.credit_card_number = C.number AND " + 
			"A.address_id = P.shipping_address_id AND "+
			"C.username = ? )AS T1 "+
			"LEFT JOIN "+ 
			"(SELECT H.item_id as item_id2, I.image, H.color "+
			"FROM has_visual H, image I "+
			"WHERE I.img_id = H.img_id) AS T2 "+
			"ON T1.item_id = T2.item_id2) AS TM " +
			"LEFT JOIN " +
			"(SELECT * " + 
			"FROM ups) AS TU " +
			"ON TM.transaction_id = TU.transaction_id";
	
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
	
	String sql_user = 	"SELECT s.name, ru.username, ru.age, ru.gender, ru.income " + 
   			"FROM suppliers s, register_users ru " + 
   			"WHERE s.supplier_id = ? and ru.supplier_id = ?";

	String SQL_ITEMS = 	"SELECT * FROM "+
						"(SELECT * "+
						"FROM sales_item S "+
						"WHERE S.supplier_id = ?) AS T1 "+
						"LEFT JOIN "+ 
						"(SELECT H.item_id as item_id2, I.image, H.color "+
						"FROM has_visual H, image I "+
						"WHERE I.img_id = H.img_id) AS T2 "+
						"ON T1.item_id = T2.item_id2";
	
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
	
	// find all the items the seller has
	int supplier_id = Integer.parseInt(request.getParameter("supplier_id"));
	select_items = con.prepareStatement(SQL_ITEMS);
	select_items.setInt(1, supplier_id);
	result_items = select_items.executeQuery();
	
	// result_user contains desired user information
	select_user = con.prepareStatement(sql_user);
	select_user.setInt(1, Integer.parseInt(request.getParameter("supplier_id")));
	select_user.setInt(2, Integer.parseInt(request.getParameter("supplier_id")));
	supplier = request.getParameter("supplier_id");
	result_user = select_user.executeQuery();
	while(result_user.next()){
		name = result_user.getString("name");
		username = result_user.getString("username");
		age = result_user.getString("age");
		gender = result_user.getString("gender");
		income = result_user.getString("income");
	}
	
	// Get all auctions
	select_auction2 = con.prepareStatement(SQL_AUCTION);
	select_auction2.setInt(1, supplier_id);
	result_auction2 = select_auction2.executeQuery();
	
	// find all the ratings for that user
	select_ratings = con.prepareStatement("SELECT username, value, explanation " + 
			   		      "FROM rating " + 
			   		      "WHERE supplier_id = ?");
	select_ratings.setInt(1, Integer.parseInt(request.getParameter("supplier_id")));
	// result_ratings contains all ratings for user
	result_ratings = select_ratings.executeQuery();
	
	
	// Get all purchases
	select_purchases = con.prepareStatement(sql_query_purchases);
	select_purchases.setString(1, username);
	result_purchases = select_purchases.executeQuery(); // contain item information of user purchases
	
// this is just a test display 					
	%>
<div class="w3-topnav w3-black">
	<a href="Login.jsp">Home</a>
  	<a href="Login.jsp">Suppliers</a>
 	<a href="Auction.jsp">Auction</a>
 	<a href="Custom_Shoes.jsp">Custom Shoes</a>
  	<a href="AddSales_ItemPage.jsp">Add an Item</a>
  	<a href="MyBid.jsp">My Bids</a>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=session.getAttribute("SupplierId")%>'"/>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="Sign Out" onclick="window.document.location.href='Logout.jsp'"/>
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
	<th>Shipping Status</th>
	</tr>
	</thead>
    <%while(result_purchases.next()){%>
  <tr>
  	<td><img src="/hellow/images/<%= result_purchases.getString("image")%>" width="200px" height="100px"></td>
  	<td><a href="DisplayItem.jsp?item_id=<%=result_purchases.getString("item_id")%>"><%= result_purchases.getString("name") %></a></td>
    <td><%= result_purchases.getString("brand") %></td>
    <td><%= result_purchases.getString("state") %></td>
    <td><%= result_purchases.getString("price") %></td>
    <td><%= result_purchases.getString("street_address") %></td> 
    <%if(result_purchases.getString("shipping_method") != null) { %>
    <td><%= result_purchases.getString("shipping_method") %>
    <%}else{ %>
    <td>Pending<td>
    <%} %>
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
    <td><img src="/hellow/images/<%=image %>" width="200px" height="100px"></td>
  	<td><a href="DisplayItem.jsp?item_id=<%=item_id%>"><%= name2 %></a></td>
    <td><%= start%></td>
    <td><%= end%></td>
    <td><%= amount%></td>
    <td><%= reserved_price%></td>
  </tr>
</table>

<%if(current_time > end_long && (Integer.parseInt((String) session.getAttribute("SupplierId")) == Integer.parseInt(request.getParameter("supplier_id")))){ %>
<form action="EndAuction.jsp">
	<input type="hidden" name="item_id" value=<%=item_id%> />
	<input type="hidden" name="supplier_id" value=<%=Integer.parseInt(request.getParameter("supplier_id"))%> />
	<input type="hidden" name="auction_timestamp_start" value=<%=start_long%> />
	<input value="Complete Auction" type="submit"/>
</form>
<%} %>

</div>
 <%} %>
<div class="w3-panel w3-card w3-light-grey"><p>My Items</p></div>

<div id="image" class="w3-dropdown-content w3-light-grey" style="float:right;">
      <div class="w3-container w3-right-align">
        
<form action="Upload_Image.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="item_id" value=""/>
<input type="file" name="pic"/>
<input type="submit" value="Upload"/>
</form>
      </div>
    </div>
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
	<td><img src="/hellow/images/<%= result_items.getString("image") %>" width="200px" height="100px"> 
	<%if(result_items.getString("image") == null){ %>
	<form action="Upload_Image.jsp" method="post" enctype="multipart/form-data">
		<input type="hidden" name="item_id" value="<%=result_items.getString("item_id")%>"/>
		<input type="hidden" name="color" value="white"/>
		<input type="file" name="pic"/>
		<input type="submit" value="Upload"/>
	</form>
	<%}%>
	<% String id_temp =  result_items.getString("item_id"); %>
  	<td><a href="DisplayItem.jsp?item_id=<%=result_items.getString("item_id")%>"><%= result_items.getString("name") %></a></td>
  	<td><%= result_items.getString("count") %></td>
    <td><%= result_items.getString("brand") %></td>
    <td><%= result_items.getString("state") %></td>
    <td><%= result_items.getString("description") %></td>
    <td><%= result_items.getString("list_price") %></td>
    <td><%= result_items.getString("reserved_price") %></td>
    <td><% if(Integer.parseInt((String) session.getAttribute("SupplierId")) == Integer.parseInt(request.getParameter("supplier_id"))){ %>
        <form class="w3-form" action="Start_Auction.jsp" style="width:100%" style="float:left" method="post">
	 				<input class="w3-input w3-sand" type="text" name="timestamp_end" required>
	 				<input type="hidden" name="item_id" value="<%= id_temp %>"/>
	 				<input type="hidden" name="supplier_id" value="<%= Integer.parseInt(request.getParameter("supplier_id")) %>"/>
	 				<p><button class="w3-btn" type="submit" >Start this Auction</button></p>
		</form>
     </td>
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
	<%float average, total = 0, count=0; %>
    <%while(result_ratings.next()){
    total+= (result_ratings.getFloat("value"));
    System.out.println(total);
    count++;%>
  <tr>
	 <td><%= result_ratings.getString("username") %></td>
	 <td><%= result_ratings.getString("value") %></td>
	 <td><%= result_ratings.getString("explanation") %></td>
  </tr>
  <%} %>
  </table>
  <div class="w3-panel w3-card w3-pale-green"><p>This user's average rating is <%=total/count%></p></div>
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

