 <%@ page language="java" contentType="text/html; charset=UTF-8"

    pageEncoding="UTF-8"%>

<%@page import="java.sql.*"%>

<%@page import="javax.sql.*"%>

<%@page import="java.util.ArrayList"%>

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
//					amount (Float)					- amount to bid

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

float MIN_BID_INCREASE = 2.0f;

Connection con = null;
PreparedStatement get_end_time, select_bid_data, update_bid, select_highest_bid, get_autos, update_autos;
ResultSet result_end_time, result_bid_data, result_highest_bid, result_autos;

int high_bid_id = -1;
float high_max = -1;
int sec_bid_id = -2;
float sec_max = -2;
int temp_bid_id = 0;
float temp_max = 0;
float auto_bid_amount = -1;


int bid_id;
int item_id;
boolean is_auto;
float highest_bid;
float new_amount;
float old_amount;
Float max_amount;
long end_time;
long start_time;

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
	
	// get parameters
	item_id = Integer.parseInt(request.getParameter("item_id"));
	
	bid_id = Integer.parseInt(request.getParameter("bid_id"));
	
	start_time = Long.parseLong(request.getParameter("auction_timestamp_start"));
	
	// get the end time for the auction			
	get_end_time = con.prepareStatement("SELECT timestamp_end FROM Auction WHERE timestamp_start = ? AND item_id = ?");
	
	get_end_time.setLong(1, start_time);
	
	get_end_time.setInt(2, item_id);
	
	result_end_time = get_end_time.executeQuery();
	
	result_end_time.next();
	
	end_time = result_end_time.getLong(1);

	// if the timelimit for the auction has not been reached
	if(end_time >= System.currentTimeMillis()/1000){
		
		// get old amount and is_auto status
		select_bid_data = con.prepareStatement("SELECT amount, is_auto, max_amount FROM Bid " +
												"WHERE bid_id = ? AND item_id = ? AND auction_timestamp_start = ?");
		select_bid_data.setInt(1, bid_id);
		
		select_bid_data.setInt(2, item_id);
		
		select_bid_data.setLong(3, start_time);
		
		result_bid_data = select_bid_data.executeQuery();

		result_bid_data.next();
		
		old_amount = result_bid_data.getInt(1);

		is_auto = result_bid_data.getBoolean(2);
	
		max_amount = result_bid_data.getFloat(3);

		new_amount = Float.parseFloat(request.getParameter("amount"));
		
		// get highest bid
		
		select_highest_bid = con.prepareStatement("SELECT MAX(amount) FROM Bid " +
				"WHERE item_id = ? AND auction_timestamp_start = ?");
		
		select_highest_bid.setInt(1, item_id);
		
		select_highest_bid.setLong(2, start_time);
		
		result_highest_bid = select_highest_bid.executeQuery();
		
		result_highest_bid.next();
		
		highest_bid = result_highest_bid.getFloat(1);
		
		if(new_amount >= highest_bid + MIN_BID_INCREASE){
			
			// update bid
			update_bid = con.prepareStatement(UPDATE_BID_SQL);
			
			update_bid.setFloat(1, new_amount);
			
			update_bid.setInt(2, bid_id);
			
			update_bid.setInt(3, item_id);
			
			update_bid.setLong(4, start_time);
		
			update_bid.executeUpdate();
			
			// Perform all auto updates
			get_autos = con.prepareStatement("SELECT bid_id, max_amount FROM Bid " +
					"WHERE is_auto = 1 AND item_id = ? AND auction_timestamp_start = ?");
			get_autos.setInt(1, item_id);
			get_autos.setLong(2, start_time);
			result_autos = get_autos.executeQuery();
			
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
				if(sec_max >= new_amount + MIN_BID_INCREASE){
					auto_bid_amount = sec_max + MIN_BID_INCREASE;
				// if there is exactly 1 auto-bid
				}else if(high_bid_id != bid_id){
					auto_bid_amount = new_amount + MIN_BID_INCREASE;
				}else{
					auto_bid_amount = -1;
				}
				
				if(auto_bid_amount > high_max){
					auto_bid_amount = high_max;
				}
				
				if(auto_bid_amount >= new_amount + MIN_BID_INCREASE){
					update_autos = con.prepareStatement(UPDATE_BID_SQL);
					
					update_autos.setFloat(1, auto_bid_amount);
					
					update_autos.setInt(2, high_bid_id);
					
					update_autos.setInt(3, item_id);
					
					update_autos.setLong(4, start_time);
				
					update_autos.executeUpdate();
					
				}
			}
			
			
			session.setAttribute(SUCCESS_LABEL, "Success");
		}else{
			session.setAttribute(SUCCESS_LABEL, "Fail");
		}	
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