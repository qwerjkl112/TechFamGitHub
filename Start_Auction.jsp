 <%@ page language="java" contentType="text/html; charset=UTF-8"

    pageEncoding="UTF-8"%>

<%@page import="java.sql.*"%>

<%@page import="javax.sql.*"%>

<%@page import="java.util.Calendar"%>

<%@page import="java.text.SimpleDateFormat"%>

<%Class.forName("com.mysql.jdbc.Driver"); %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>

<body>

<%

//--------------------------------------------------------------------

// This jsp file allows a supplier to start an auction
// Input the item to auction and the time the auction ends

//--------------------------------------------------------------------

// required inputs: item_id (Integer) 		- item id of item to be auctioned
// 					timestamp_end (String) 	- timestamp of when to end the auction
//											- yyyy-MM-dd HH:mm:ss

// output: if adding the item was a success

//--------------------------------------------------------------------

// databases and fields used: 

//		Auction		- timestamp_start, timestamp_end, item_id	

//     	Sales_Item	- 	item_id (input)

//--------------------------------------------------------------------
String DATABASE_NAME = "techfam";
String DATABASE_USERNAME = "root";
String DATABASE_PASSWORD = "noclown1";
String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
String DRIVER_LOC = "com.mysql.jdbc.Driver";
String SUCCESS_LABEL = "AddSales_Item";

String DATE_FORMAT = "yyyy-MM-dd HH:mm:ss";

boolean IDENTIFY_NOT_AUCTION = false;

Connection con = null;
PreparedStatement product_count, reduce_count, add_to_auction;
ResultSet result_count;

int item_id;
int count;
String end_time_str;
Calendar cal = Calendar.getInstance();
SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT);

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);

	// get the count of the item to be auctioned

	item_id = Integer.parseInt(request.getParameter("item_id"));
	
	System.out.println(request.getParameter("timestamp_end"));
	
	cal.setTime(sdf.parse(request.getParameter("timestamp_end")));	
	
	product_count = con.prepareStatement("SELECT count FROM Sales_Item WHERE item_id = ?");
	
	product_count.setInt(1, item_id);

	result_count = product_count.executeQuery();
	
	result_count.next();
	
	count = result_count.getInt(1);
	
	// if the item is in stock
	
	if(count > 0){
		
		// create new auction
		
		add_to_auction = con.prepareStatement("INSERT INTO Auction VALUES (?, ?, ?)");
		
		add_to_auction.setLong(1, System.currentTimeMillis()/1000);
		
		add_to_auction.setLong(2, cal.getTimeInMillis()/1000);
		
		add_to_auction.setInt(3, item_id);
		
		add_to_auction.executeUpdate();
		
		// reduce count of Sales_Item
		
		reduce_count = con.prepareStatement("UPDATE Sales_Item SET count = count - ? WHERE item_id = ?");
		
		reduce_count.setInt(1, 1);
		
		reduce_count.setInt(2, item_id);
		
		reduce_count.executeUpdate();
		
		session.setAttribute(SUCCESS_LABEL, "Success");
		
	}else{
		session.setAttribute(SUCCESS_LABEL, "Fail");
	}
	
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
		
// redirect to previous page
// String redirectURL = String.format("Profile.jsp?supplier_id=%s", request.getParameter("supplier_id"));

String redirectURL = "Profile.jsp?supplier_id=" + Integer.parseInt(request.getParameter("supplier_id"));
		
response.sendRedirect(redirectURL);

%>
</body>
</html>