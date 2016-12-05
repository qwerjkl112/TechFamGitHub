<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>


<form action="Upload_Image.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="item_id" value="1"/>
<select name="color">
<option value="red">Red</option>
<option value="red orange">Red Orange</option>
<option value="orange">Orange</option>
<option value="yellow">Yellow</option>
<option value="yellow green">Yellow Green</option>
<option value="green">Green</option>
<option value="sky blue">Sky Blue</option>
<option value="blue">Blue</option>
<option value="violet">Violet</option>
<option value="red">Light Brown</option>
<option value="brown">Brown</option>
<option value="black">Black</option>
<option value="gold">Gold</option>
<option value="silver">Silver</option>
</select>
<input type="file" name="pic"/>
<input type="submit" value="Upload"/>
</form>
</body>
</html>