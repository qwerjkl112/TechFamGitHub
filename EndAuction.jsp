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

boolean IDENTIFY_AUCTION = true;

Connection con = null;
PreparedStatement select_highest_bid, select_reserved_price, delete_auction, add_to_sale, select_bid_info, select_sale_id, select_ups_id, add_to_ups;
ResultSet result_highest_bid, result_reserved_price, result_bid_info, result_max_id, result_max__shipping_id;

int bid_id;
int item_id;
long start_time;
float highest_bid;
float reserved_price;

long credit_card_number;
int address_id;
int transaction_id;
int shipping_id;

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
	
	// get parameters
	item_id = Integer.parseInt(request.getParameter("item_id"));
	
	start_time = Long.parseLong(request.getParameter("auction_timestamp_start"));
	
	// get highest bid
	select_highest_bid = con.prepareStatement("SELECT MAX(amount) FROM Bid " +
			"WHERE item_id = ? AND auction_timestamp_start = ?");
	
	select_highest_bid.setInt(1, item_id);
	
	select_highest_bid.setLong(2, start_time);
	
	result_highest_bid = select_highest_bid.executeQuery();
	
	result_highest_bid.next();
	
	highest_bid = result_highest_bid.getFloat(1);
	
	// get reserved price
	
	select_reserved_price = con.prepareStatement("SELECT reserved_price FROM Sales_Item WHERE item_id = ?");
	
	select_reserved_price.setInt(1, item_id);
	
	result_reserved_price = select_reserved_price.executeQuery();
	
	result_reserved_price.next();
	
	reserved_price = result_reserved_price.getFloat(1);
	
	if(highest_bid >= reserved_price){
		// get bid info
		select_bid_info = con.prepareStatement("SELECT credit_card_number, shipping_address_id FROM Bid " +
			"WHERE item_id = ? AND auction_timestamp_start = ? AND amount = ?");
		
		select_bid_info.setInt(1, item_id);
		
		select_bid_info.setLong(2, start_time);
		
		select_bid_info.setFloat(3, highest_bid);
		
		result_bid_info = select_bid_info.executeQuery();
		
		result_bid_info.next();
		
		credit_card_number = result_bid_info.getLong(1);
		
		address_id = result_bid_info.getInt(2);

		
		// get Max sales id
		
		select_sale_id = con.prepareStatement("SELECT MAX(transaction_id) FROM Sale");

		result_max_id = select_sale_id.executeQuery();

		result_max_id.next();

		transaction_id = result_max_id.getInt(1) + 1;

		// add item to Sale
		
		add_to_sale = con.prepareStatement("INSERT INTO Sale VALUES (?, ?, ?, ?, ?, ?, ?)");
		
		add_to_sale.setInt(1, transaction_id);
		
		add_to_sale.setFloat(2, highest_bid);
		
		add_to_sale.setLong(3, System.currentTimeMillis()/1000);
		
		add_to_sale.setBoolean(4, IDENTIFY_AUCTION);
		
		add_to_sale.setInt(5, item_id);
		
		add_to_sale.setLong(6, credit_card_number);
		
		add_to_sale.setInt(7, address_id);
		
		add_to_sale.executeUpdate();
		
		// get Max ups id
		
		select_ups_id = con.prepareStatement("SELECT MAX(shipping_id) FROM Ups");

		result_max__shipping_id = select_ups_id.executeQuery();

		result_max__shipping_id.next();

		shipping_id = result_max_id.getInt(1) + 1;
		
		// add sale to ups
		
		add_to_ups = con.prepareStatement("INSERT INTO Ups VALUES (?, ?, ?, ?)");
		
		add_to_ups.setInt(1, shipping_id);
		
		add_to_ups.setFloat(2, System.currentTimeMillis()/1000);
		
		add_to_ups.setString(3, "Processing");
		
		add_to_ups.setInt(4, transaction_id);
		
		add_to_ups.executeUpdate();
	
	}
	
	delete_auction = con.prepareStatement("DELETE FROM Auction WHERE item_id = ? AND timestamp_start = ?");
	
	delete_auction.setInt(1, item_id);
	
	delete_auction.setLong(2, start_time);
	
	delete_auction.executeUpdate();
	
	session.setAttribute(SUCCESS_LABEL, "Success");
	
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

String redirectURL = "Profile.jsp?supplier_id=" + Integer.parseInt(request.getParameter("supplier_id"));
		
response.sendRedirect(redirectURL);

%>
</body>
</html>