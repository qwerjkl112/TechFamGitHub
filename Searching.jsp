<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@ page import="javax.servlet.http.HttpUtils.*" %>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>Search Results</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
</head>
<style>
.arrow-up {
  width: 0; 
  height: 0; 
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  
  border-top: 5px solid black;
}
</style>
</head>
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
	
	//----------------------------------------------------------------------------------------------------------
	// This jsp file displays the desired items depending on the user's search. Filters include keywords, 
	// price range, state, and size.
	//----------------------------------------------------------------------------------------------------------
	// input: any number of the following (all are in text form):
	//	keyword
	//	bottom price range
	//	top price range
	//	state
	//	size
	// can also order outputs by name and list_price (ascending or descending)
	// output: the fields below (except the id's) - stored in ResultSet results;
	//----------------------------------------------------------------------------------------------------------
	// databases and fields used: 
	//     	Sales_Item - count, brand, list_price, state, name
	//	Footwear - size
	//	category - category_id, category_name
	//     	suppliers - supplier_id, name
	//----------------------------------------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_items, select_category, select_category2;
	ResultSet results, result_category, result_category2;
	int comma = 0;
	
	String sql_query = "SELECT S.item_id, S.brand, S.count, S.list_price, S.name, S.state, F.size, C.category_name, C.description, SU.name, SU.supplier_id " + 
				"FROM sales_item S, footwear F, category C, suppliers SU " + 
				"WHERE S.item_id = F.item_id AND S.category_id = C.category_id AND S.supplier_id = SU.supplier_id ";
	
	String sql_category_tree = "SELECT category_id FROM category WHERE parent_id = ";
	
	String url = request.getRequestURL().toString() + "?";
	
	// search keywords in name, brand, item description, category name, category description, supplier name
	try {
		if (request.getParameter("keyword").length() > 0) {
			sql_query += "AND (S.name LIKE '%" + request.getParameter("keyword") + "%' " + 
					"OR S.brand LIKE '%" + request.getParameter("keyword") + "%' " + 
					"OR S.description LIKE '%" + request.getParameter("keyword") + "%' " +
					"OR C.category_name LIKE '%" + request.getParameter("keyword") + "%' " +
					"OR C.description LIKE '%" + request.getParameter("keyword") + "%' " +
					"OR SU.name LIKE '%" + request.getParameter("keyword") + "%') ";
			url += "keyword=" + request.getParameter("keyword") + "&";
		}
	} catch(NullPointerException e) {}
	
	try {
		if (request.getParameter("state").length() > 0) {
			sql_query += "AND S.state = '" + request.getParameter("state") + "' ";
			url += "state=" + request.getParameter("state") + "&";;
		}
	} catch(NullPointerException e) {}

	// search by category
	try {
		if (request.getParameter("category_id").length() > 0) {
			if (Integer.parseInt(request.getParameter("category_id")) != 1) {
				sql_query += "AND (S.category_id = " + request.getParameter("category_id") + " ";
				select_category = con.prepareStatement("SELECT category_id FROM category WHERE parent_id = ?");
				select_category.setString(1, request.getParameter("category_id"));
				result_category = select_category.executeQuery();
				while (result_category.next()) {
					sql_query += "OR S.category_id = " + result_category.getString("category_id") + " ";
					select_category2 = con.prepareStatement("SELECT category_id FROM category WHERE parent_id = ?");
					select_category2.setString(1, result_category.getString("category_id"));
					result_category2 = select_category2.executeQuery();
					while (result_category2.next()) {
						sql_query += "OR S.category_id = " + result_category2.getString("category_id") + " ";
					}
				}
				sql_query += ") ";
			}
			url += "category_id=" + request.getParameter("category_id") + "&";;
		}
	} catch(NullPointerException e) {}

	// bottom end of price range
	try {
		sql_query += "AND S.list_price >= " + Long.parseLong(request.getParameter("bottom_price")) + " ";
		url += "bottom_price=" + request.getParameter("bottom_price") + "&";;
    } catch(NumberFormatException e) {}
	
	// top end of price range
	try {
		sql_query += "AND S.list_price <= " + Long.parseLong(request.getParameter("top_price")) + " ";
		url += "top_price=" + request.getParameter("top_price") + "&";;
    } catch(NumberFormatException e) {}
	
	// Order by list_price
	try {
		if (request.getParameter("order_price").length() > 0) {
			if (Integer.parseInt(request.getParameter("order_price")) == 1) {
				sql_query += "ORDER BY S.list_price DESC";
			}
			else {
				sql_query += "ORDER BY S.list_price ASC";
			}
			comma = 1;
			url += "order_price=" + request.getParameter("order_price") + "&";;
		}
	} catch(NullPointerException e) {}
	
	// Order by alphabetical order
	try {
		if (request.getParameter("order_name").length() > 0) {
			if (comma == 1) {
				sql_query += ", ";
			}
			else {
				sql_query += " ORDER BY ";
			}
			if (Integer.parseInt(request.getParameter("order_name")) == 1) {
				sql_query += "S.name DESC";
			}
			else {
				sql_query += "S.name ASC";
			}
			url += "order_name=" + request.getParameter("order_name") + "&";;
		}
	} catch(NullPointerException e) {}
	
	
	System.out.println(sql_query);
	
	select_items = con.prepareStatement(sql_query);
	results = select_items.executeQuery();
	System.out.println(url);
	
// this is just a test display - remove before final product				
%>

  
<div class="w3-panel w3-card w3-light-grey"><p>Search Results</p></div>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:100%;">
	<thead>
		<tr>
			<th>Item Name<a class="arrow-up" href="<%=url%>order_name=1"></a></th>
			<th>Brand</th>
			<th>List Price<a class="arrow-up" href="<%=url%>order_price=1"></a></th>
			<th>Category</th>
			<th>State</th>
			<th>Count</th>
			<th>Size</th>
			<th>Seller</th>
		</tr>
	</thead>
	<% while(results.next()) { %>
  <tr>
    <td><a href="DisplayItem.jsp?item_id=<%=results.getString("item_id")%>"><%= results.getString("name") %></a></td>
    <td><%= results.getString("brand") %></td> 
    <td><%= results.getString("list_price") %></td>
    <td><%= results.getString("description") %></td>
    <td><%= results.getString("state") %></td>
    <td><%= results.getString("count") %></td>
    <td><%= results.getString("size") %></td>
    <td><a href="Profile.jsp?supplier_id=<%=results.getString("supplier_id")%>"><%= results.getString("SU.name") %></a></td>
  </tr>
  <% } %>
</table>