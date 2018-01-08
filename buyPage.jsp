<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="ucsd.shoppingApp.PersonDAO"%>
<%@ page import="ucsd.shoppingApp.models.*, java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Shopping Cart</title>
</head>
<body>
	<% if(session.getAttribute("roleName") != null) { %>
		<table cellspacing="5">
			<tr>
				<td valign="top"><jsp:include page="./menu.jsp"></jsp:include></td>
				<td></td>
				<td>
					<h3>Hello <%= session.getAttribute("personName") %></h3>
					<h3>Shopping Cart</h3>
					<table border=1>
				        <thead>
				            <tr>
				                <th>Product Name</th>
				                <th>Price</th>
				                <th>Quantity</th>
				            </tr>
				        </thead>
				        <% 	ArrayList<ShoppingCartModel> sc = (ArrayList<ShoppingCartModel>)request.getAttribute("shoppingCart");
				        	float total = 0;
							for(ShoppingCartModel prod : sc) { %>
								<tr>
								<td><%= prod.getProductName() %></td>
								<td><%= prod.getPrice() %></td>
								<td><%= prod.getQuantity() %></td>
								</tr>
								<% 	
								total = total + prod.getPrice() * prod.getQuantity();
							} %>
							<p>Total = <%= total %></p>
							<form method="post" action="./BuyController">
							<p>Credit Card Information : 
							<input type="text" name="ccinfo" style="margin:10px;" required="true"></input></p>
							<% if(sc.size() > 0) { %>
								<button type="submit" value="pay" style="margin: 10px;">Purchase</button>
							<% } %>
					</form>
						</table>
					</td>
				</tr>
			</table>
		<% } else { %>
			<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
		<% } %>
	</body>
</html>