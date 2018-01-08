<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="ucsd.shoppingApp.PersonDAO"%>
<%@ page import="ucsd.shoppingApp.models.*, java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Shopping Application</title>
</head>
<body>
	<% if(session.getAttribute("roleName") != null) { %>
		<table cellspacing="5">
			<tr>
				<td valign="top"> <jsp:include page="./menu.jsp"></jsp:include></td>
				<td></td>
				<td>
					<h3>Hello <%= session.getAttribute("personName") %></h3>
				<h3>Product Order</h3>
				<form method="post" action="./ShoppingCartController">
					<p>Product : <%= request.getAttribute("pname") %></p>
					<input type='hidden' name='pid' value="<%= request.getAttribute("pid") %>"></input>
					<input type='hidden' name='pprice' value="<%= request.getAttribute("pprice") %>"></input>
					Quantity : <select name='quantity'>
						<% for(int i = 1; i < 100; i++) { %>
							<option value = "<%= Integer.toString(i) %>"><%= Integer.toString(i) %></option>
						<% } %>
					</select>
					<input type="submit" value="Order" style="margin-left:10px;" />
				</form>
				<br/>
				<h3>Your shopping cart</h3>
				<table border=1>
			        <thead>
			            <tr>
			                <th>Product Name</th>
			                <th>Price</th>
			                <th>Quantity</th>
			            </tr>
			        </thead>
			        <% 	ArrayList<ShoppingCartModel> sc = (ArrayList<ShoppingCartModel>)request.getAttribute("shoppingCart");
						for(ShoppingCartModel prod : sc) {
					%>
						<tr>
							<td><%= prod.getProductName() %></td>
							<td><%= prod.getPrice() %></td>
							<td><%= prod.getQuantity() %></td>
						</tr>
					<% 
						}
					%>
			    </table>
				</td>
			</tr>
		</table>
	<%     
	}
	else { %>
			<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
	<% } %>
</body>
</html>