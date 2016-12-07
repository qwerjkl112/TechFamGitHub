<%@ page language="java" contentType="text/html; charset=UTF-8"

    pageEncoding="UTF-8"%>

<%@page import="java.sql.*"%>

<%@page import="javax.sql.*"%>
<%@page import="hellow.Get_Drop_Downs"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.*"%>

<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>TechFam</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
<div class="w3-topnav w3-black">
	<a href="Login.jsp">Home</a>
  	<a href="Login.jsp">Suppliers</a>
 	<a href="Auction.jsp">Auction</a>
 	<a href="Custom_Shoes.jsp">Custom Shoes</a>
  	<a href="AddSales_ItemPage.jsp">Add an Item</a>
  	<a href="MyBid.jsp">My Bids</a>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=session.getAttribute("SupplierId")%>'"/>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="Sign Out" onclick="window.document.location.href='Login.html'"/>
</div>

<%
//--------------------------------------------------------------------
// This jsp file allows a user to bid on an item in an auction
//--------------------------------------------------------------------
// required inputs: username (String)
//					supplier_id (integer)
//					tong_style (String)
//					sole_style (String)
//					shoe_style (String)
//					color (String)
//					size (String)
//
// output: if adding the item was a success
//--------------------------------------------------------------------
// databases and fields used: 
	
// Bid	-	all fields
//--------------------------------------------------------------------
String DATABASE_NAME = "techfam";
String DATABASE_USERNAME = "root";
String DATABASE_PASSWORD = "noclown1";
String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
String DRIVER_LOC = "com.mysql.jdbc.Driver";
String SUCCESS_LABEL = "AddSales_Item";

String SQL_GET_ALL_CUSTOM_SHOES = 	"SELECT * "+ 
									"FROM Custom_Shoe C, Footwear F " +
									"WHERE F.item_id = C.item_id";

String SQL_GET_CURRENT_SHOE = 	"SELECT C.item_id, S.list_price, I1.image as front, I2.image as back, I3.image as side "+
								"FROM Custom_Shoe C, Footwear F, Sales_Item S, Image I1, Image I2, Image I3 " +
								"WHERE F.item_id = C.item_id AND " +
								"S.item_id = C.item_id AND " +
								"C.front_img_id = I1.img_id AND "+
								"C.back_img_id = I2.img_id AND "+
								"C.side_img_id = I3.img_id AND "+
								"C.tong_style = ? AND " +
								"C.sole_style = ? AND " +
								"C.shoe_style = ? AND " +
								"C.color = ? AND " +
								"F.size = ?";

String DIRECTORY = "/hellow/images/";


Connection con = null;
PreparedStatement select_all, select_current = null;
ResultSet result_all, result_current = null;

Set<String> tong_style_arr = new HashSet<String>();
Set<String> sole_style_arr = new HashSet<String>();
Set<String> shoe_style_arr = new HashSet<String>();
Set<String> color_style_arr = new HashSet<String>();
Set<String> size_arr = new HashSet<String>();

String tong_style;
String sole_style;
String shoe_style;
String color;
String size;

String front_img = null;
String back_img = null;
String side_img = null;

Integer item_id = null;
Float price = null;

HashMap<Integer, String> addresses;
HashMap<Long, String> credit_cards;

String username = (String) session.getAttribute("UserName");
int supplier_id = Integer.parseInt((String) session.getAttribute("SupplierId"));

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
	
	tong_style = request.getParameter("tong_style");
	sole_style = request.getParameter("sole_style");
	shoe_style = request.getParameter("shoe_style");
	color = request.getParameter("color");
	size = request.getParameter("size");
	
	select_all = con.prepareStatement(SQL_GET_ALL_CUSTOM_SHOES);
	result_all = select_all.executeQuery();
	
	while(result_all.next()){
		tong_style_arr.add(result_all.getString("tong_style"));
		sole_style_arr.add(result_all.getString("sole_style"));
		shoe_style_arr.add(result_all.getString("shoe_style"));
		color_style_arr.add(result_all.getString("color"));
		size_arr.add(result_all.getString("size"));
	}
	
	if(tong_style != null && sole_style != null && shoe_style != null && color != null && size != null){
		select_current = con.prepareStatement(SQL_GET_CURRENT_SHOE);
		select_current.setString(1, tong_style);
		select_current.setString(2, sole_style);
		select_current.setString(3, shoe_style);
		select_current.setString(4, color);
		select_current.setString(5, size);
		result_current = select_current.executeQuery();
		
		result_current.next();
		item_id = result_current.getInt("item_id");
		price = result_current.getFloat("list_price");
		front_img = DIRECTORY + result_current.getString("front");
		back_img = DIRECTORY + result_current.getString("back");
		side_img = DIRECTORY + result_current.getString("side");
	}
	
	Get_Drop_Downs gdd = new Get_Drop_Downs();
	addresses = gdd.get_addresses(supplier_id);
	credit_cards = gdd.get_credit_cards(username);
		
// redirect to previous page
// String redirectURL = String.format("Profile.jsp?supplier_id=%s", request.getParameter("supplier_id"));
%>

<%if(front_img != null && back_img != null && side_img != null){ %>
<img src="<%=front_img %>">
<img src="<%=back_img %>">
<img src="<%=side_img %>">
<%} %>
<div class="w3-container w3-quarter w3-center">
<form class="w3-form" action="Custom_Shoes.jsp">

Tongue Style: <select class="w3-select" name="tong_style">
<%for(String current : tong_style_arr){ %>
<% if(tong_style != null && current.equals(tong_style)){ %>
<option selected="selected">
<%}else{%>
<option>
<%} %>
<%=current %></option>
<%} %>
</select>

Sole Style: <select class="w3-select" name = "sole_style">
<%for(String current : sole_style_arr){ %>
<% if(sole_style != null && current.equals(sole_style)){ %>
<option selected="selected">
<%}else{%>
<option>
<%} %>
<%=current %></option>
<%} %>
</select>

Shoe Style: <select class="w3-select" name = "shoe_style">
<%for(String current : shoe_style_arr){ %>
<% if(shoe_style != null && current.equals(shoe_style)){ %>
<option selected="selected">
<%}else{%>
<option>
<%} %>
<%=current %></option>
<%} %>
</select>

Color: <select class="w3-select" name = "color">
<%for(String current : color_style_arr){ %>
<% if(color != null && current.equals(color)){ %>
<option selected="selected">
<%}else{%>
<option>
<%} %>
<%=current %></option>
<%} %>
</select>

Size: <select class="w3-select" name = "size">
<%for(String current : size_arr){ %>
<% if(size != null && current.equals(size)){ %>
<option selected="selected">
<%}else{%>
<option>
<%} %>
<%=current %></option>
<%} %>
</select>

<input type="submit"/>
</form>


<%if(item_id != null && price != null){ %>
<form action="DirectBuyItem.jsp">
Price: <%=price %> | 
<input type="hidden" name="item_id" value=<%= item_id %> />
<input type="hidden" name="amount" value="1"/>
Credit Card: <select name = "credit_card">
<%for(Long number : credit_cards.keySet()){ %>
<option value=<%= number.toString()%>><%= credit_cards.get(number) %></option>
<%} %>
</select>
Address: <select name = "address_id">
<%for(Integer add_id : addresses.keySet()){ %>
<option value=<%= add_id.toString()%>><%= addresses.get(add_id) %></option>
<%} %>
</select>
<input type="submit"/>
</form>
</div>
<%} %>

<%
}catch(Exception e){
	try{
		e.printStackTrace();
		if(con != null){
			con.rollback();
		}
	}catch(Exception e2){}
	session.setAttribute(SUCCESS_LABEL, "Fail");
}finally{
	if(con != null){
		con.close();
	}
}
%>
</body>
</html>