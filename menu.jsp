<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
<%
  session.setAttribute("beginrow", "0");
	session.setAttribute("endrow", "0");
	session.setAttribute("begincolumn", "0");
	session.setAttribute("endcolumn", "0");
%>

<h3>Menu</h3>
<ul>
	<% if(session.getAttribute("roleName") != null) {
	%>
		<% if(session.getAttribute("roleName").equals("Owner")) {
			out.write("<li><a href='./CategoryController?action=listCategories'/>Categories</a></li>");
			out.write("<li><a href='./product.jsp'/>Products</a></li>");
			out.write("<li><a href='./salesAnalytics2.jsp'/> Sales Analytics</a></li>");
		}
		%>
		<li><a href='productsearch.jsp'>Products Browsing</a></li>
		<!-- <li><a href='#'>Product Order</a></li> -->
		<li><a href='./BuyController'>Buy Shopping Cart</a></li>
	    <li> <a href ='buyOrders.jsp'> Buy Orders Page(Only Available to Customers</a></li>
	<% } %>
</ul>
</body>
</html>
