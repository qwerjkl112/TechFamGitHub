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
<title>TechFam</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
<script>
function DisplayImage() {
    var x = document.createElement("IMG");
    x.setAttribute("src", "2.png");
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
  	<a href="AddSales_ItemPage.jsp">Add an Item</a>
  	<a href="Auction.jsp">Auction</a>
</div>
	<%
	String DATABASE_NAME = "techfam";
	String DATABASE_USERNAME = "root";
	String DATABASE_PASSWORD = "noclown1";
	String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
	String DRIVER_LOC = "com.mysql.jdbc.Driver";
	
	String username = (String) session.getAttribute("UserName");
	int supplier_id = Integer.parseInt((String) session.getAttribute("SupplierId"));
	
	long current_time = System.currentTimeMillis()/1000;
	
	String SQL_AUCTION = 
			"SELECT TA.item_id, TA.name, TA.description, TA.category_name, "+
			"TA.timestamp_start, TA.timestamp_end, TA.amount, TA.your_amount, "+
			"TA.is_auto, TA.max_amount,TA.bid_id, TA.cancellation_timestamp, TP.image FROM " +
			"(SELECT T1.item_id, T1.name, T1.description, T1.category_name, " +
			"T1.timestamp_start, T1.timestamp_end, T1.your_amount, "+
			"T1.is_auto, T1.max_amount, T1.bid_id, T1.cancellation_timestamp, T2.amount FROM "+
			"(SELECT I.item_id, I.name, I.description, C.category_name, "+
			"A.timestamp_start, A.timestamp_end, B.amount as your_amount, B.is_auto, B.max_amount, B.bid_id, B.cancellation_timestamp "+
			"FROM sales_item I, auction A, Category C, Bid B, Credit_Card R "+
			"WHERE A.item_id = I.item_id AND "+
			"I.category_id = C.category_id AND " +
			"B.item_id = A.item_id AND " +
			"A.timestamp_start = B.auction_timestamp_start AND " +
			"B.credit_card_number = R.number AND "+
			"R.username = ?) AS T1 "+
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
	
	Connection con = null;
	PreparedStatement select_auction;
	ResultSet result_auction2 = null;
	
	try{
		con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
		select_auction = con.prepareStatement(SQL_AUCTION);
		select_auction.setString(1, username);
		result_auction2 = select_auction.executeQuery();
	
// this is just a test display 					
%>
<div class="w3-container" id='image'></div>
<div class="w3-container w3-red">
  <h1>My Auction Details</h1>
</div>
<%while(result_auction2 != null && result_auction2.next()){
	String image = result_auction2.getString("image");
	if(image == null){
		image = "null";
	}
	
	int item_id = result_auction2.getInt("item_id");
	int bid_id = result_auction2.getInt("bid_id");
	String name = result_auction2.getString("name");
	
	long start_long = result_auction2.getLong("timestamp_start");
	long end_long = result_auction2.getLong("timestamp_end");
	long cancel_long = result_auction2.getLong("cancellation_timestamp");
	SimpleDateFormat sdf_start = new SimpleDateFormat("yyyy MMM dd HH:mm:ss");
	SimpleDateFormat sdf_end = new SimpleDateFormat("yyyy MMM dd HH:mm:ss");
	Calendar cal_start = Calendar.getInstance();
	Calendar cal_end = Calendar.getInstance();
	cal_start.setTimeInMillis(1000*start_long);
	cal_end.setTimeInMillis(1000*end_long);
	String start = sdf_start.format(cal_start.getTime());
	String end = sdf_end.format(cal_end.getTime());
	
	Float amount = result_auction2.getFloat("amount");
	Float your_bid = result_auction2.getFloat("your_amount");
	boolean is_auto = result_auction2.getBoolean("is_auto");
	String auto = "Manual";
	
	if(is_auto){
		auto="Auto";
	}

%>
<div style = "clear:both;">
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
<tr>
    <th>Image</th>
    <th>Item Name</th>
    <th>Start Time</th>
    <th>End Time</th>
    <th>Highest Bid</th>
    <th>Your Bid</th>
    <th>Is Automatic</th>
    <%if(is_auto){ %>
    <th>Max Bid</th>
    <%} %>
    
  </tr>
  <tr>
    <td><%= image%></td>
  	<td><a href="DisplayItem.jsp?item_id=<%=item_id%>"><%= name%></a></td>
    <td><%= start%></td>
    <td><%= end%></td>
    <td><%= amount%></td>
    <td><%= your_bid%>
    <td><%= auto%></td>
    <%if(is_auto){ %>
    <th><%= result_auction2.getFloat("max_amount")%></th>
    <%} %>
  </tr>
</table>
<%if(!is_auto){ %>
<form action="UpdateBid.jsp" method="post">
<input type="hidden" name="item_id" value=<%= item_id%> />
<input type="hidden" name="auction_timestamp_start" value=<%= start_long%> />
<input type="hidden" name="bid_id" value=<%= bid_id%> />
Amount: <input type="number" name="amount" min=<%= amount + 2.0f %> />
<input value="Bid" type="submit"/>
</form>
<%} %>

<%if(current_time < cancel_long){ %>
<form action="CancelBid.jsp" method="post">
<input type="hidden" name="item_id" value=<%= item_id%> />
<input type="hidden" name="auction_timestamp_start" value=<%= start_long%> />
<input type="hidden" name="bid_id" value=<%= bid_id%> />
<input value="Cancel" type="submit"/>
</form>
<% }%>
</div>
 <%} %>
 <%	
 	}catch(Exception e){
		e.printStackTrace();
	}finally{
		if(con != null){
			con.close();
		}
	}
%>
</body>