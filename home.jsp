<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Shopping Application</title>
</head>
<body>
	<% 
		if(session.getAttribute("personName") == null) {
			response.sendRedirect("./index.html");
		} else {		
	%>
		<table cellspacing = "5px"><tr>
		<td valign="top"><jsp:include page="menu.jsp"></jsp:include></td>
		<td>
		<h1>Home</h1>
		<h3>Hello <%= session.getAttribute( "personName" ) %></h3></td>
		
		</tr>
		</table>
	<% 
		}
	%>
</body>
</html>