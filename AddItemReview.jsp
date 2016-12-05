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
	// which inserts that information into the Item_Review table
	//--------------------------------------------------------------------
	// input: item_id of the user Item_Review and username 
	//        of the user being rated (in that order)
	// output: if Item_Review was succesful
	//--------------------------------------------------------------------
	// databases and fields used: 
	//     suppliers - item_id (this is given)
	//     register_user - username (stored in result_username)
	//     Item_Review - Item_Review_id, explanation, value, username, item_id
	//--------------------------------------------------------------------
	
	String DATABASE_NAME = "techfam";
	String DATABASE_USERNAME = "root";
	String DATABASE_PASSWORD = "noclown1";
	String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
			"?autoReconnect=true&useSSL=false";
	String DRIVER_LOC = "com.mysql.jdbc.Driver";
	String SUCCESS_LABEL = "AddSales_Item";
	
	String CHECK_USER_BOUGH_SQL = 	"SELECT transaction_id, R.username " +
									"FROM sale S, credit_card C, register_users R " +
									"WHERE S.credit_card_number = C.number AND " +
			      					"C.username = R.username AND "+
			      					"S.item_id = ? AND " + 
				  					"R.username = ?";
	
	Connection con = null;
	PreparedStatement check_username, select_Item_Review_id, insert_Item_Review, check_user_bought;
	ResultSet result_check, result_max_Item_Review_id, result_user_bought;
	int increment_id;
	int item_id;
	String username;
	try{
		con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);

		item_id = Integer.parseInt(request.getParameter("item_id"));
		username = request.getParameter("username");
		System.out.println("username is " + request.getParameter("username"));
		
		// check if the user has already given a Item_Review to this user before -  deny Item_Review if true
		check_username = con.prepareStatement("SELECT username FROM Item_Review WHERE username = ? AND item_id = ?");
		check_username.setString(1, request.getParameter("username"));
		check_username.setInt(2, Integer.parseInt(request.getParameter("item_id")));
		result_check = check_username.executeQuery();
		
		check_user_bought = con.prepareStatement(CHECK_USER_BOUGH_SQL);
		check_user_bought.setInt(1, item_id);
		check_user_bought.setString(2, username);
		result_user_bought = check_user_bought.executeQuery();
		
		if (result_check.next() || !result_user_bought.next()) {
			//user has already submitted a Item_Review before
			session.setAttribute(SUCCESS_LABEL, "Fail");
		}else{
			
			// obtain max Item_Review_id and increment by one - this is the latest Item_Review's id
			select_Item_Review_id = con.prepareStatement("SELECT MAX(review_id) FROM Item_Review");
			result_max_Item_Review_id = select_Item_Review_id.executeQuery();
			result_max_Item_Review_id.next();
			increment_id = result_max_Item_Review_id.getInt(1) + 1;
			
			
			// insert Item_Review for that user
			insert_Item_Review = con.prepareStatement("INSERT INTO Item_Review VALUES (?,?,?,?,?)");
			insert_Item_Review.setInt(1, increment_id);
			insert_Item_Review.setString(2, request.getParameter("explanation"));
			insert_Item_Review.setFloat(3, Float.parseFloat(request.getParameter("value")));
			insert_Item_Review.setString(4, username);
			insert_Item_Review.setInt(5, item_id);	// item_id of the user being rated
			insert_Item_Review.executeUpdate();	// result_Item_Reviews contains all Item_Reviews for user
			session.setAttribute(SUCCESS_LABEL, "Success");
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
	// redirectURL = String.format("Profile.jsp?item_id=%s", request.getParameter("item_id"));
	//response.sendRedirect(redirectURL);
	String redirectURL = "DisplayItem.jsp?item_id=" + request.getParameter("item_id");
	
	response.sendRedirect(redirectURL);
%>