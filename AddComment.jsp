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
	// This jsp file allows a user to rate another user,
	// which inserts that information into the rating table
	//--------------------------------------------------------------------
	// input: supplier_id of the user rating and username 
	//        of the user being rated (in that order)
	// output: if rating was succesful
	//--------------------------------------------------------------------
	// databases and fields used: 
	//     suppliers - supplier_id (this is given)
	//     register_user - username (stored in result_username)
	//     rating - rating_id, explanation, value, username, supplier_id
	//--------------------------------------------------------------------
	
	
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement check_username, select_rating_id, insert_rating;
	ResultSet result_check, result_max_rating_id;
	int increment_id;
		
	// check if the user has already given a rating to this user before -  deny rating if true
	check_username = con.prepareStatement("SELECT username FROM rating WHERE username = ? AND supplier_id = ?");
	check_username.setString(1, request.getParameter("username"));
	check_username.setInt(2, Integer.parseInt(request.getParameter("supplier_id")));
	result_check = check_username.executeQuery();
	if (result_check.next()) {
		//user has already submitted a rating before
	}
	
	
	// obtain max rating_id and increment by one - this is the latest rating's id
	select_rating_id = con.prepareStatement("SELECT MAX(rating_id) FROM rating");
	result_max_rating_id = select_rating_id.executeQuery();
	result_max_rating_id.next();
	increment_id = result_max_rating_id.getInt(1) + 1;
	
	
	// insert rating for that user
	insert_rating = con.prepareStatement("INSERT INTO rating VALUES (?,?,?,?,?)");
	insert_rating.setInt(1, increment_id);
	insert_rating.setString(2, request.getParameter("explanation"));
	insert_rating.setFloat(3, Float.parseFloat(request.getParameter("value")));
	insert_rating.setString(4, request.getParameter("username"));
	insert_rating.setInt(5, Integer.parseInt(request.getParameter("supplier_id")));	// supplier_id of the user being rated
	insert_rating.executeUpdate();	// result_ratings contains all ratings for user
	
	String redirectURL = String.format("Profile.jsp?supplier_id=%s", request.getParameter("supplier_id"));
	response.sendRedirect(redirectURL);
%>