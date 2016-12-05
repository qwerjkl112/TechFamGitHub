<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="hellow.Get_Drop_Downs"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>My Profile</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">

<body onLoad="myFunction()">
<% 
String DATABASE_NAME = "techfam";
String DATABASE_USERNAME = "root";
String DATABASE_PASSWORD = "noclown1";
String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
String DRIVER_LOC = "com.mysql.jdbc.Driver";
Get_Drop_Downs gdd = new Get_Drop_Downs();

Connection con = null;
PreparedStatement select_address, select_categories;
ResultSet result_address, result_categories = null;
ArrayList<Long> credit_card_numbers = new ArrayList<Long>();
ArrayList<String> credit_star = new ArrayList<String>();
HashMap<Integer, String> address = new HashMap<Integer, String>();
HashMap<String, ArrayList<Integer>> result_hash = new HashMap<String, ArrayList<Integer>>(); //for result category
HashMap<Integer, String> id_to_name = new HashMap<Integer, String>();
String size;
String big_group;
String small_group;
int category;
int supplier_id = Integer.parseInt((String) session.getAttribute("SupplierId"));


//
// Checking success and failures
if(session.getAttribute("AddSales_Item") == null){
	System.out.println("None");
}else if (session.getAttribute("AddSales_Item").equals("Success")){
	System.out.println("Success");
}else{
	System.out.println("Fail");
}

session.setAttribute("AddSales_Item", null);

String address_sql = "SELECT address_id, street_address FROM address where supplier_id = ?";

String category_sql = 	"SELECT DISTINCT C2.category_name, C4.category_name, C4.category_id " +
		"FROM category C1, category C2, category C3, category C4 " +
		"WHERE C1.parent_id IS NULL AND " +
		"C2.parent_id = C1.category_id AND " + 
		"C3.parent_id = C2.category_id AND " +
		"C4.parent_id = C3.category_id";
try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
	select_categories = con.prepareStatement(category_sql);
	result_categories = select_categories.executeQuery();
	while(result_categories.next()){	
		big_group = result_categories.getString(1);
		small_group = result_categories.getString(2);
		category = result_categories.getInt(3);
		
		if(result_hash.get(big_group) == null){
			result_hash.put(big_group, new ArrayList<Integer>());
		}
		
		result_hash.get(big_group).add(category);
		
		id_to_name.put(category, small_group);
	}
	// get addresses
	HashMap<Integer, String> addresses = gdd.get_addresses(supplier_id);
	//
	select_address = con.prepareStatement(address_sql);
	select_address.setInt(1, supplier_id);
	result_address = select_address.executeQuery();
	System.out.println("bloop");
	
	while(result_address.next()){
		address.put(result_address.getInt(1), result_address.getString(2));
	}
	
	System.out.println("start finding credit cards");
	
	// get credit cards

	
}catch(Exception e){
	e.printStackTrace();
	System.out.println("here");
	try{
		if(con != null){
			con.rollback();
		}
	}catch(Exception e2){}
}finally{
	if(con != null){
		con.close();
	}
}



%>

<div class="w3-topnav w3-black">
	<a href="Login.html">Home</a>
  	<a href="Login.jsp">Suppliers</a>
 	<a href="#">Link 2</a>
  	<a href="#">Link 3</a>
</div>

<div class="w3-container">
	<form class="w3-form w3-half" action="AddSales_Item.jsp">
	  <h2>Fill out your information</h2>
	  <h3>Item Information:</h3>
	  <p><input class="w3-input" name="name" type="text" placeholder="Product Name"></p>
	  <p><input class="w3-input" name="description" type="text" placeholder="description"></p>
	  <p><input class="w3-input" name="brand" type="text" placeholder="brand"></p>
	  <p><select class="w3-select" name="state">
	  	<option value="" disabled selected>Select the State of your Item</option>
	    <option value="new">New</option>
	    <option value="old">Old</option>
	  </select></p>
	  <p><input class="w3-input" name="count" type="number" placeholder="number of items"></p>
	  <p><input class="w3-input" name="list_price" type="number" placeholder="Item Price"></p>
	  <p><input class="w3-input" name="reserved_price" type="number" placeholder="Auction Minimum Price"></p>
	  <p>Address: <select name = "address_id">
				 <%for(Integer add_id : address.keySet()){ %>
  	  <option value=<%= add_id.toString()%>><%= address.get(add_id) %></option>
 	  <%} %>
	  </select></p>
	  <p>Category: <select name = "category_id">
		<% for(String group : result_hash.keySet()){%>
			<optgroup label= <%= group%>>
			<% for(Integer cat_id : result_hash.get(group)){ %>
				<option value=<%= cat_id.toString()%>><%= id_to_name.get(cat_id)%></option>
			<%} %>
			</optgroup>
		<%} %>
	</select></p>

	  
	  <p><button class="w3-btn" >Create New Item</button></p>
	</form>	
</div>
    




<script>
function myFunction() {
    var d = new Date();
    var n = d.valueOf();
    document.getElementById("demo").innerHTML = n;
}
</script>

					


<p style='color:red'> This is the user</p>

</body>


