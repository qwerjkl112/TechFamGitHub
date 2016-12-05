<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="java.net.URLDecoder" %>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<body>
	
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
	// output: the fields below (except the id's) - stored in ResultSet results;
	//----------------------------------------------------------------------------------------------------------
	// databases and fields used: 
	//     	Sales_Item - count, brand, list_price, state, name
	//	Footwear - size
	//	category - category_id, category_name
	//     	suppliers - supplier_id, name
	//----------------------------------------------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement select_items, select_category;
	ResultSet results, result_category;
	boolean validate = true;
	String keyword = null;
	float bottom_price = 0;
	float top_price = 1000000;
	float category_id = 1000000;
	System.out.println(request.getParameter("keyword"));
	if(request.getParameter("keyword")!= null){
		keyword = request.getParameter("keyword");
	} 
	if(request.getParameter("bottom_price")!= null){
		bottom_price = Long.parseLong(request.getParameter("bottom_price"));
	}
	if(request.getParameter("top_price")!= null){
		top_price = Long.parseLong(request.getParameter("top_price"));
	}
	if(request.getParameter("category_id")!= null){
		category_id = Long.parseLong(request.getParameter("category_id"));
	}
	
	
	System.out.println(request.getParameter("keyword"));
	
	String sql_query = "SELECT S.item_id, S.brand, S.count, S.list_price, S.name, S.state, F.size, C.category_name, SU.name " + 
				"FROM sales_item S, footwear F, category C, suppliers SU " + 
				"WHERE S.item_id = F.item_id AND S.category_id = C.category_id AND S.supplier_id = SU.supplier_id ";
	
	String sql_query2;
	
	// search keywords in name, brand, item description, category name, category description, supplier name
	if (request.getParameter("keyword") != null) {
		sql_query += "AND (S.name LIKE '%" + keyword + "%' " + 
				"OR S.brand LIKE '%" + keyword + "%' " + 
				"OR S.description LIKE '%" + keyword + "%' " +
				"OR C.category_name LIKE '%" + keyword + "%' " +
				"OR C.description LIKE '%" + keyword + "%' " +
				"OR SU.name LIKE '%" + keyword + "%') ";
	}
	
	// bottom end of price range
	if (bottom_price > 0) {
		// error handling if price range is not a number
		try {
			Long.parseLong(request.getParameter("bottom_price"));
	    	}
	    	catch(NumberFormatException e) {
	        	validate = false;
	    	}
		if (validate) {
			sql_query += "AND S.list_price >= " + Long.parseLong(request.getParameter("bottom_price")) + " ";
		} 
		else {
			validate = true;
		}
	}
	
	// top end of price range
	if (top_price < (float) 1000000) {
		System.out.println(top_price);
		// error handling if price range is not a number
		try {
			Long.parseLong(request.getParameter("top_price"));
	    	}
	    	catch(NumberFormatException e) {
	        	validate = false;
	    	}
		if (validate) {
			sql_query += "AND S.list_price <= " + Long.parseLong(request.getParameter("top_price")) + " ";
		} 
		else {
			validate = true;
		}
	}
	
 	if (request.getParameter("category_id") != null) {
		//sql_query2 = "SELECT category_id FROM category where parent_id = " + request.getParameter("category_id");
		//select_category = con.prepareStatement(sql_query2);
		//result_category = select_category.executeQuery();
		
		//if (result_category.next()) {
		sql_query += "AND C.parent_id = " + request.getParameter("category_id") + " ";
			//while (result_category.next()) { 
				
			//}
		//}
		 
	} 
	
	// search by state
	if (request.getParameter("state") != null) {
		sql_query += "AND S.state = '" + request.getParameter("state") + "' ";
	}
	
	// search by size - trouble with how to do this because the sizes are ranges in char form
	if (request.getParameter("size") != null) {
		sql_query += "AND F.size = '" + request.getParameter("size") + "' ";
	}
	
	select_items = con.prepareStatement(sql_query);
	results = select_items.executeQuery();
	
// this is just a test display - remove before final product				
%>

<p style='color:red'> This is the user</p>
<table style='width:100%'>
<tr>
    <th>name</th>
    <th>brand</th> 
    <th>list price</th> 
    <th>state</th> 
    <th>count</th> 
  </tr>
  <%while(results.next()){%>
  <tr>
    <td><a href="DisplayItem.jsp?item_id=<%=results.getString("item_id")%>"><%= results.getString("name") %></a></td>
    <td><%= results.getString("brand") %></td> 
    <td><%= results.getString("list_price") %></td>
    <td><%= results.getString("state") %></td>
    <td><%= results.getString("count") %></td>
  </tr>
  <% } %>

  </table>
</body>