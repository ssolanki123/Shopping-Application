<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*, ucsd.shoppingApp.*" %>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Shopping Application</title>
	</head>
	<body>
		<% if(request.getAttribute("registration_message") != null) { %>
			<font color=green><%= request.getAttribute("registration_message") %></font>
			</br>
			<% request.setAttribute("registration_message", null); %>
		<% } %>
		<h1>Login</h1>
		
		<form name="loginForm" method="POST" action="LoginController">
			Enter Name: <input type="text" name="username" />
			<input type="submit" value="login" />
		</form>
	</body>
</html>