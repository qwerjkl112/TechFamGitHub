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
PreparedStatement select_address, select_credit, select_item;
ResultSet result_address, result_credit, result_item;
ArrayList<Long> credit_card_numbers = new ArrayList<Long>();
ArrayList<String> credit_star = new ArrayList<String>();
HashMap<Integer, String> address = new HashMap<Integer, String>();

Long credit;
String credit_enc;

String address_sql = "SELECT address_id, street_address FROM address where supplier_id = ?";
String credit_sql = "SELECT number FROM credit_card WHERE username = ?";

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

try{
	con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
	System.out.println("moo");
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
	select_credit = con.prepareStatement(credit_sql);
	System.out.println((String) session.getAttribute("UserName"));
	select_credit.setString(1, (String) session.getAttribute("UserName"));
	result_credit = select_credit.executeQuery();

	while(result_credit.next()){
		System.out.println("here in loop");
		credit = result_credit.getLong(1);
		credit_card_numbers.add(credit);
		credit_enc = credit.toString();
		credit_enc = "************" + credit_enc.substring(credit_enc.length()-4);
		credit_star.add(credit_enc);
	}
	
}catch(Exception e){
	e.printStackTrace();
	System.out.println("here");
	try{
		if(con != null){
			con.rollback();
		}
	}catch(Exception e2){}
}

%>

<div class="w3-topnav w3-black">
	<a href="Login.jsp">Home</a>
  	<a href="Login.jsp">Suppliers</a>
 	<a href="Auction.jsp">Auction</a>
 	<a href="Custom_Shoes.jsp">Custom Shoes</a>
  	<a href="AddSales_ItemPage.jsp">Add an Item</a>
  	<a href="MyBid.jsp">My Bids</a>
  	<input type="button" class="w3-btn" style="float:right; padding: 0px 16px !important;" value="myprofile" onclick="window.document.location.href='Profile.jsp?supplier_id=<%=session.getAttribute("SupplierId")%>'"/>
</div>
<div class="w3-container w3-half w3-red">
<%	
select_item = con.prepareStatement("SELECT count, item_id, brand, list_price, state, description, name, category_id, supplier_id " + 
			"FROM sales_item " + 
			"WHERE item_id = ?");
select_item.setInt(1, Integer.parseInt((String)session.getAttribute("ItemId")));
result_item = select_item.executeQuery();
result_item.next();	// select the item result - this is needed for finding the category and supplier 

%>
<h1>Item</h1>
	<p><img src="/hellow/images/<%=result_item.getString("item_id")%>.png" width="250px" height="250px"></p>
    <p>Item Name: <%= result_item.getString("name") %></p>
    <p>Brand: <%= result_item.getString("brand") %></p> 
    <p>List Price: <%= result_item.getString("list_price") %></p>
    <p>State: <%= result_item.getString("state") %></p>
    <p>Item Description: <%= result_item.getString("description") %></p>
</div>

<div class="w3-container w3-half">
  <h2>Please select a type of payment</h2>

  <form action="DirectBuyItem.jsp">
	<input type="hidden" name="item_id" value="<%= session.getAttribute("ItemId") %>"/>
	<input type="hidden" name="amount" value="1"/>
	<p>Credit Card: <select name="credit_card"> 
	<% for(int x = 0; x <credit_card_numbers.size(); x++){%>
		<option value = <%=credit_card_numbers.get(x) %>><%=credit_star.get(x)%></option>
		<%} %>
	</select></p>
	<p>Address: <select name = "address_id">
		<%for(Integer add_id : address.keySet()){ %>
			<option value=<%= add_id.toString()%>><%= address.get(add_id) %></option>
		<%} %>
	</select></p>
	<button class="w3-btn w3-red" type="submit">Buy</button>
	</form>
	<button onclick="addCreditCard()" class="w3-btn w3-light-grey">Add a new card</button>
	
  	<div id="card" class="w3-dropdown-content w3-light-grey" style="float:right;">
      <div class="w3-container w3-right-align">
        <form class="w3-form" action="AddCreditCard.jsp" style="width:100%" style="float:right" method="post">
  			<h3>Credit Card Information</h3>
 				<input class="w3-input" type="text" name="number" required>
 				<label class="w3-label w3-validate">number</label>
 				<input class="w3-input" type="text" name="name" required>
 				<label class="w3-label w3-validate">name</label>
 				<p><select class="w3-select" name="type">
			    <option value="" disabled selected>Select Credit or Debit</option>
			    <option value="cebit">Debit</option>
			    <option value="debit">Credit</option>
			 	</select></p>
 				<input class="w3-input" type="text" name="date" required>
 				<label class="w3-label w3-validate">date</label>
 				<p><select name = "billing_address_id">
				 <%for(Integer add_id : address.keySet()){ %>
  				<option value=<%= add_id.toString()%>><%= address.get(add_id) %></option>
 				<%} %>
				</select></p>
  				<p><button class="w3-btn" type="submit">Add Credit Card</button></p>
  				
		</form>
      </div>
    </div>
    <button onclick="addAddress()" class="w3-btn w3-light-grey">Add a new address</button>
	
  	<div id="address" class="w3-dropdown-content w3-light-grey" style="float:right;">
      <div class="w3-container w3-right-align">
        <form class="w3-form" action="AddAddress.jsp" style="width:100%" style="float:right" method="post">
  			<h3>New Address Information</h3>
 				<input class="w3-input" type="text" name="app_num" required>
 				<label class="w3-label w3-validate">app_num</label>
 				<input class="w3-input" type="text" name="street_address" required>
 				<label class="w3-label w3-validate">street_address</label>
 				<input class="w3-input" type="text" name="city" required>
 				<label class="w3-label w3-validate">city</label>
 				<input class="w3-input" type="text" name="state" required>
 				<label class="w3-label w3-validate">state</label>
 				<input class="w3-input" type="text" name="zip" required>
 				<label class="w3-label w3-validate">zip</label>
 				<p><button class="w3-btn" type="submit" >Add New Address</button></p>
		</form>
      </div>
    </div>
    <script>
	function addCreditCard() {
	    var x = document.getElementById("card");
	    if (x.className.indexOf("w3-show") == -1) {
	        x.className += " w3-show";
	        x.className += " w3-half"
	    } else {
	        x.className = x.className.replace(" w3-show", "");
	    }
	}
	function addAddress() {
	    var x = document.getElementById("address");
	    if (x.className.indexOf("w3-show") == -1) {
	        x.className += " w3-show";
	        x.className += " w3-half"
	    } else {
	        x.className = x.className.replace(" w3-show", "");
	    }
	}
	</script>
</div>




<script>
function myFunction() {
    var d = new Date();
    var n = d.valueOf();
    document.getElementById("demo").innerHTML = n;
}
</script>

					



</body>
</html>


