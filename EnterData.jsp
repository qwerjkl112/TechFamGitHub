<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%Class.forName("com.mysql.jdbc.Driver"); %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<title>My Profile</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://www.w3schools.com/lib/w3.css">
<body>
<div class="w3-topnav w3-black">
	<a href="Login.html">Home</a>
  	<a href="EnterData.jsp">Seller List</a>
 	<a href="#">Link 2</a>
  	<a href="#">Link 3</a>
  	
  	<button onclick="myFunction()" class="w3-btn" style="float:right; padding: 0px 16px !important;">Sign In</button>
  	<a href="Signup.html" class="w3-btn" style="float:right; padding: 0px 16px !important;">Register</a>
  	
    <div id="Demo" class="w3-dropdown-content w3-light-grey w3-display-topright" style="float:right; margin-top: 40px;">
      <div class="w3-container w3-right-align">
        <form class="w3-form" action="Login.jsp" style="width:100%" style="float:right" method="post">
  			<h3>Sign-in</h3>
 				<input class="w3-input" type="text" name="username" required>
 				<label class="w3-label w3-validate">username</label>
  				<input class="w3-input" type="password" name="password" required>
  				<label class="w3-label w3-validate">password</label>
  				<p><button class="w3-btn">Signin</button></p>
		</form>
      </div>
    </div>
</div>
<div class="w3-container w3-red">
  <h1>List of Users</h1>
</div>
	<%
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/techfam?autoReconnect=true&useSSL=false","root", "noclown1");
	PreparedStatement insertt;
	int thing;
	/* insertt = con.prepareStatement("INSERT INTO name" + " VALUES (?,?)");
	insertt.setString(1, request.getParameter("name"));
	insertt.setString(2, request.getParameter("number"));
	thing = insertt.executeUpdate(); */
	//user and pass are root
	
	//here we create our query
	Statement mystmt = con.createStatement();
	
	
	ResultSet result = mystmt.executeQuery("select * from Suppliers");
	
	//while(result.next()){
	//	System.out.println(result.getString("name") + ", " + result.getString("number"));
	//	newuser.name = result.getString("name");
	//	newuser.id = result.getString("number");
	//}

%>
<table class="w3-table w3-striped w3-bordered w3-border w3-hoverable" style="width:75%;">
<thead>
<tr>
    <th>supplier id</th>
    <th>email</th> 
    <th>name</th> 
</tr>
</thead>
  <%while(result.next()){%>
  <tr>
    <td><%= result.getString("supplier_id") %></td>
    <td><%= result.getString("email") %></td> 
    <td><%= result.getString("name") %></td> 
  </tr>
  <% } %>

  </table>
</body>
</html>