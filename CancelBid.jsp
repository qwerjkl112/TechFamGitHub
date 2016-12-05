 <%@ page language="java" contentType="text/html; charset=UTF-8"

    pageEncoding="UTF-8"%>

<%@page import="java.sql.*"%>

<%@page import="javax.sql.*"%>

<%Class.forName("com.mysql.jdbc.Driver"); %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>

<body>

<%

//--------------------------------------------------------------------

// This jsp file allows a user to bid on an item in an auction

//--------------------------------------------------------------------

// required inputs: item_id (Integer) 		 		- item id of item being auctioned
// 					auction_timestamp_start(Long) 	- timestamp for start of given auction
//					bid_id (Integer)				- item_id

// output: if adding the item was a success

//--------------------------------------------------------------------

// databases and fields used: 
	
// Bid	-	all fields

//--------------------------------------------------------------------
System.out.println("start");
String DATABASE_NAME = "techfam";
String DATABASE_USERNAME = "root";
String DATABASE_PASSWORD = "noclown1";
String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
String DRIVER_LOC = "com.mysql.jdbc.Driver";
String SUCCESS_LABEL = "AddSales_Item";

Connection con = null;
PreparedStatement select_bid_data, drop_bid;
ResultSet result_bid_data;

int bid_id;
int item_id;
long start_time;
long cancelation_time;

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
	
	// get parameters
		System.out.println("here");	
	item_id = Integer.parseInt(request.getParameter("item_id"));
	System.out.println("here");	
	bid_id = Integer.parseInt(request.getParameter("bid_id"));
	System.out.println("here");	
	start_time = Long.parseLong(request.getParameter("auction_timestamp_start"));
	System.out.println("here");	
	// get cancelation timestamp
	select_bid_data = con.prepareStatement("SELECT cancellation_timestamp FROM Bid " +
					"WHERE bid_id = ? AND item_id = ? AND auction_timestamp_start = ?");
			
	select_bid_data.setInt(1, bid_id);
			
	select_bid_data.setInt(2, item_id);
			
	select_bid_data.setLong(3, start_time);
		
	result_bid_data = select_bid_data.executeQuery();
	
	result_bid_data.next();
	
	cancelation_time = result_bid_data.getLong(1);
	System.out.println("" + cancelation_time + " " + System.currentTimeMillis()/1000);
	if(cancelation_time >= System.currentTimeMillis()/1000){
		System.out.println("2");
		drop_bid = con.prepareStatement("DELETE FROM Bid " +
				"WHERE bid_id = ? AND item_id = ? AND auction_timestamp_start = ?");
		
		drop_bid.setInt(1, bid_id);
		
		drop_bid.setInt(2, item_id);
		
		drop_bid.setLong(3, start_time);
	
		drop_bid.executeUpdate();
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

//result_bid_data.next();
//max_amount = result_bid_data.getFloat(1);
		
// redirect to previous page
// String redirectURL = String.format("Profile.jsp?supplier_id=%s", request.getParameter("supplier_id"));

String redirectURL = "MyBid.jsp";
		
response.sendRedirect(redirectURL);

%>
</body>
</html>