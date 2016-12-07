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
//					amount (Float)					- amount to bid
//					credit_card(Long)				- number of credit card user is paying with
//					address_id(Int)					- shipping address
//					is_auto (Boolean)				- is auto bid True or False
//					max_amount (Float)				- max ammount you are willing to bid

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
String UPDATE_BID_SQL = "UPDATE Bid SET amount = ? " +
		"WHERE bid_id = ? AND item_id = ? AND auction_timestamp_start = ?";		

int TIME_TO_CANCEL = 60*60*24;
float MIN_BID_INCREASE = 2.0f;

Connection con = null;
PreparedStatement get_end_time, select_bid_id, add_to_bid, select_highest_bid, update_autos, get_autos;
ResultSet result_end_time, result_max_id, result_highest_bid, result_autos;

int high_bid_id = -1;
float high_max = -1;
int sec_bid_id = -2;
float sec_max = -2;
int temp_bid_id = 0;
float temp_max = 0;
float auto_bid_amount = -1;

int bid_id;
boolean is_auto;
long end_time;
long start_time;
int item_id;
float amount;
float highest_bid;
float max_amount;
float reserved;
try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
	
	// get the end time for the auction
	item_id = Integer.parseInt(request.getParameter("item_id"));
	
	start_time = Long.parseLong(request.getParameter("auction_timestamp_start"));
	
	amount = Float.parseFloat(request.getParameter("amount"));
	
	System.out.println("item id is " + item_id + "start time is" + start_time + "amount is " + amount);
	
	if(request.getParameter("max_amount") != null){
		max_amount = Float.parseFloat(request.getParameter("max_amount")); 
	}else{
		max_amount = 0f;
	}
	
	System.out.println("max amount: " + max_amount);
	
	is_auto = Boolean.parseBoolean(request.getParameter("is_auto"));
	
	get_end_time = con.prepareStatement("SELECT A.timestamp_end, S.reserved_price FROM Auction A, Sales_Item S WHERE A.item_id = S.item_id AND A.timestamp_start = ? AND A.item_id = ?");
	
	get_end_time.setLong(1, start_time);
	
	get_end_time.setInt(2, item_id);
	
	result_end_time = get_end_time.executeQuery();
	
	result_end_time.next();
	
	end_time = result_end_time.getLong(1);
	
	reserved = result_end_time.getFloat(2);
	// get highest bid
	
	select_highest_bid = con.prepareStatement("SELECT MAX(amount) FROM Bid " +
			"WHERE item_id = ? AND auction_timestamp_start = ?");
	
	select_highest_bid.setInt(1, item_id);
	
	select_highest_bid.setLong(2, start_time);
	
	result_highest_bid = select_highest_bid.executeQuery();
	
	result_highest_bid.next();
	
	highest_bid = result_highest_bid.getFloat(1);
	if(is_auto && amount < reserved){
		amount = reserved;
	}
	// if the timelimit for the auction has not been reached
	System.out.println("asdfasldfhasldkhgalksdhgal;ksdhgak;sofiewbvklsebiwofbisovgbao;iheihfaiosdh");
	if(end_time >= System.currentTimeMillis()/1000 && (result_highest_bid.wasNull() || 
			amount >= highest_bid + MIN_BID_INCREASE) && reserved <= amount && (!is_auto || amount <= max_amount)){
		
		// get Max bid id
		// if the timelimit for the auction has not been reached
	System.out.println("1");
		select_bid_id = con.prepareStatement("SELECT MAX(bid_id) FROM Bid");

		result_max_id = select_bid_id.executeQuery();

		result_max_id.next();

		bid_id = result_max_id.getInt(1) + 1;
		
		// add item to Bid
	
		add_to_bid = con.prepareStatement("INSERT INTO Bid VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
	
		add_to_bid.setInt(1, bid_id);
	
		add_to_bid.setFloat(2, amount);
	
		add_to_bid.setLong(3, System.currentTimeMillis()/1000 + TIME_TO_CANCEL);
	
		add_to_bid.setInt(4, item_id);
	
		add_to_bid.setLong(5, start_time);
	
		add_to_bid.setLong(6, Long.parseLong(request.getParameter("credit_card")));
	
		add_to_bid.setInt(7, Integer.parseInt(request.getParameter("address_id")));
	
		add_to_bid.setBoolean(8, is_auto);
		
		if(is_auto){
			add_to_bid.setFloat(9, max_amount);
			System.out.println("2");
		}else{
			add_to_bid.setNull(9, java.sql.Types.DECIMAL);
			System.out.println("3");
		}
	
		add_to_bid.executeUpdate();
		
		
		// Perform all auto updates
		get_autos = con.prepareStatement("SELECT bid_id, max_amount FROM Bid " +
				"WHERE is_auto = 1 AND item_id = ? AND auction_timestamp_start = ?");
		get_autos.setInt(1, item_id);
		get_autos.setLong(2, start_time);
		result_autos = get_autos.executeQuery();
		System.out.println("4");
		while(result_autos.next()){
			temp_bid_id = result_autos.getInt(1);
			temp_max = result_autos.getFloat(2);
			if(temp_max > high_max){
				sec_max = high_max;
				sec_bid_id = high_bid_id;
				high_max = temp_max;
				high_bid_id = temp_bid_id;
			}else{
				if(temp_max > sec_max){
					sec_max = temp_max;
					sec_bid_id = temp_bid_id;
				}
			}
		}
		
		// if there is at least one auto-bid
		
		if(high_max >= 0){
			// if there is more then one auto-bid
			if(sec_max >= amount + MIN_BID_INCREASE){
				auto_bid_amount = sec_max + MIN_BID_INCREASE;
			// if there is exactly 1 auto-bid
			}else if(high_bid_id != bid_id){
				auto_bid_amount = amount + MIN_BID_INCREASE;
			}else{
				auto_bid_amount = -1;
			}
			
			if(auto_bid_amount > high_max){
				auto_bid_amount = high_max;
			}
			
			if(auto_bid_amount >= amount + MIN_BID_INCREASE){
				update_autos = con.prepareStatement(UPDATE_BID_SQL);
				
				update_autos.setFloat(1, auto_bid_amount);
				
				update_autos.setInt(2, high_bid_id);
				
				update_autos.setInt(3, item_id);
				
				update_autos.setLong(4, start_time);
			
				update_autos.executeUpdate();
				
			}
		}
		
		session.setAttribute(SUCCESS_LABEL, "Success");
		System.out.println("successs");
	}else{
		System.out.println("failed here");
		session.setAttribute(SUCCESS_LABEL, "Fail");
	}
	
}catch(Exception e){
	System.out.println("failed");
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

String redirectURL = "MyBid.jsp";
		
response.sendRedirect(redirectURL);

%>
</body>
</html>