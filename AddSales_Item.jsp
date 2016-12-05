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

// This jsp file allows a supplier to add a new sales_item

// which inserts that information into the sales_item table

//--------------------------------------------------------------------

// required inputs: count (Integer) 		- number of items in stock
//					brand (String)			- name of the brand of the product
//					list_price (Decimal)	- price of the item when not being auctioned
//					state (String)			- 'new' or 'old'
//					description (String)	- describes the product
//					name (String)			- name of the product
//					reserved_price (Decimal)- min price of item when being auctioned
//					category_id (Integer)	- id of the category the item belongs to
//					supplier_id (Integer)	- id of the supplier who is selling the item
//					address_id	(Integer)	- id of the address for this item
//                  
// optional inputs: size (String)			- size of shoes, if it is a shoe

// output: if adding the item was a success

//--------------------------------------------------------------------

// databases and fields used: 

//		Suppliers 	- 	supplier_id (Given as Input)

//		Cateogry 	- 	category_id (Given as Input)

//		Address		- 	address_id (Given as Input)

//     Sales_Item 	- 	count, brand, list_price, state, description, name,
//						category_id, supplier_id, address_id

//     Footwear		- 	size

//--------------------------------------------------------------------
String DATABASE_NAME = "techfam";
String DATABASE_USERNAME = "root";
String DATABASE_PASSWORD = "noclown1";
String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
String DRIVER_LOC = "com.mysql.jdbc.Driver";
String SUCCESS_LABEL = "AddSales_Item";

Connection con = null;
PreparedStatement select_product_id, insert_sales_item, insert_footwear;
ResultSet result_max_id;

int increment_id; 
String size;
int supplier_id = Integer.parseInt((String) session.getAttribute("SupplierId"));

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);

	// obtain max sales_item_id and increment by one - this is the latest sales_item_id

	select_product_id = con.prepareStatement("SELECT MAX(item_id) FROM Sales_Item");

	result_max_id = select_product_id.executeQuery();

	result_max_id.next();

	increment_id = result_max_id.getInt(1) + 1;

	// insert Sales_Item for the user

	insert_sales_item = con.prepareStatement("INSERT INTO Sales_Item VALUES (?,?,?,?,?,?,?,?,?,?,?)");

	insert_sales_item.setInt(1, increment_id);

	insert_sales_item.setInt(2, Integer.parseInt(request.getParameter("count")));

	insert_sales_item.setString(3, request.getParameter("brand"));

	insert_sales_item.setFloat(4, Float.parseFloat(request.getParameter("list_price")));

	insert_sales_item.setString(5, request.getParameter("state"));

	insert_sales_item.setString(6, request.getParameter("description"));

	insert_sales_item.setString(7, request.getParameter("name"));

	insert_sales_item.setFloat(8, Float.parseFloat(request.getParameter("reserved_price")));

	insert_sales_item.setInt(9, Integer.parseInt(request.getParameter("category_id")));

	insert_sales_item.setInt(10, supplier_id);

	insert_sales_item.setInt(11, 1);//Integer.parseInt(request.getParameter("address_id")));

	insert_sales_item.executeUpdate();
	
	// insert Footwear for the user
	size = request.getParameter("size");
	
	if(size != null && !size.isEmpty()){
		insert_footwear =  con.prepareStatement("INSERT INTO Footwear VALUES (?,?)");
		insert_footwear.setString(1, size);
		insert_footwear.setInt(2, increment_id);
		insert_footwear.executeUpdate();
	}
	session.setAttribute(SUCCESS_LABEL, "Success");
}catch(Exception e){
	e.printStackTrace();
	try{
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

String redirectURL = "Profile.jsp?supplier_id=" + supplier_id;
		
response.sendRedirect(redirectURL);

%>
success
</body>
</html>