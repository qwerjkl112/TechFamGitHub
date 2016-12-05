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

// This jsp file allows a user to buy an item directly
// Input the item to buy and the number of that item to buy
// Database is checked to make sure the item is in stock
// Then item count is reduced into database and a sale entry is made
// 		for the item and buyer

//--------------------------------------------------------------------

// required inputs: item_id (Integer) 	- item id of item being bought
//					amount (Integer)	- amount of items person is buyting
//					credit_card (Long)	- credit card number
//					address_id (Integer)- shipping address

// output: if adding the item was a success

//--------------------------------------------------------------------

// databases and fields used: 

//		Register_Users 	- 	username (Given as Input)

//     	Sales_Item 		- 	item_id (input), count, list_price

//		credit_card 	-   number (input)

//		Sale			-	transaction_id, price, data, auction_or_sale, item_id, 
//							username, credit_card_number

//--------------------------------------------------------------------
String DATABASE_NAME = "techfam";
String DATABASE_USERNAME = "root";
String DATABASE_PASSWORD = "noclown1";
String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
String DRIVER_LOC = "com.mysql.jdbc.Driver";
String SUCCESS_LABEL = "AddSales_Item";

boolean IDENTIFY_NOT_AUCTION = false;

Connection con = null;
PreparedStatement product_count, reduce_count, add_to_sale, select_sale_id;
ResultSet result_count, result_max_id;

int item_id;
int count;
float list_price;
int amount;
int transaction_id;

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);

	// get the count and price of the object being bought

	item_id = Integer.parseInt(request.getParameter("item_id"));
	
	product_count = con.prepareStatement("SELECT count, list_price FROM Sales_Item WHERE item_id = ?");
	
	product_count.setInt(1, item_id);

	result_count = product_count.executeQuery();
	
	result_count.next();
	
	count = result_count.getInt(1);
	
	list_price = result_count.getFloat(2);
	
	amount = Integer.parseInt(request.getParameter("amount"));
	
	// if the item is in stock
	
	if(count >= amount){
		
		// get Max sales id
		
		select_sale_id = con.prepareStatement("SELECT MAX(transaction_id) FROM Sale");

		result_max_id = select_sale_id.executeQuery();

		result_max_id.next();

		transaction_id = result_max_id.getInt(1) + 1;
		
		// add item to Sale
		
		add_to_sale = con.prepareStatement("INSERT INTO Sale VALUES (?, ?, ?, ?, ?, ?, ?)");
		
		add_to_sale.setInt(1, transaction_id);
		
		add_to_sale.setFloat(2, list_price*amount);
		
		add_to_sale.setLong(3, System.currentTimeMillis()/1000);
		
		add_to_sale.setBoolean(4, IDENTIFY_NOT_AUCTION);
		
		add_to_sale.setInt(5, item_id);
		
		add_to_sale.setLong(6, Long.parseLong(request.getParameter("credit_card")));
		
		add_to_sale.setInt(7, Integer.parseInt(request.getParameter("address_id")));
		
		add_to_sale.executeUpdate();
		
		// reduce count of Sales_Item
		
		reduce_count = con.prepareStatement("UPDATE Sales_Item SET count = count - ? WHERE item_id = ?");
		
		reduce_count.setInt(1, amount);
		
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
		session.setAttribute(SUCCESS_LABEL, "Fail");
	}catch(Exception e2){}
}finally{
	if(con != null){
		con.close();
	}
}
		
String redirectURL = String.format("SalesReport.jsp");
response.sendRedirect(redirectURL);

		

%>
</body>
</html>