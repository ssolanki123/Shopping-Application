<%@page import="java.sql.Connection"%>
<%@page import="ucsd.shoppingApp.ConnectionManager"%>
<%@page import="ucsd.shoppingApp.CategoryDAO"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ucsd.shoppingApp.models.*, java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Manage Categories</title>
</head>
<body>
	<%
	if(session.getAttribute("roleName") != null) { %>
		<% if(request.getAttribute("categories") == null && request.getAttribute("error") == null) {
			response.sendRedirect("./CategoryController?action=listCategories");
		} else {
		%>
		<table cellspacing="5">
			<tr>
				<td valign="top"><jsp:include page="./menu.jsp"></jsp:include></td>
				<td></td>
				<td>
					<h3>Hello <%= session.getAttribute("personName") %></h3>
					<h3>Categories List</h3>
					<% Connection con = ConnectionManager.getConnection(); 
						CategoryDAO categoryDao = new CategoryDAO(con);
						String role = session.getAttribute("roleName").toString();
						
						if("owner".equalsIgnoreCase(role)) { %>
						<% if(request.getAttribute("error") != null && (boolean)request.getAttribute("error")) { %>
						<h3 style="color:red;">Data Modification Failure</h3>
						<h4 style="color:red;"><%= request.getAttribute("message").toString() %></h4>
						<% request.setAttribute("message", null);
							request.setAttribute("error", false);
						} 
						
						if(request.getAttribute("message")!= null && !(boolean)request.getAttribute("error")) { %>
						<h4 style="color:green;"><%= request.getAttribute("message").toString() %></h4>
						<% 
						request.setAttribute("message", null);
						request.setAttribute("error", false);
						}
						%>
						<table border=1 style="border-collapse: collapse">
				        <thead>
				            <tr>
				                <th>Category ID</th>
				                <th>Category Name</th>
				                <th>Description</th>
				                <th colspan=2>Action</th>
				            </tr>
				        </thead>
				        <tbody>
				        	<tr>
				        		<form action="CategoryController" method="post">
				        			<input type="hidden" name="action" value="insert"/>
									<td><input value="" name="id" readonly/></td>
									<td><input value="" name="categoryName" required/></td>
									<td><textArea value="" name="description" required></textArea></td>
									<td><input type="submit" value="Insert"/></td>
				        		</form>
							</tr>
							<% 	ArrayList<CategoryModel> categories = (ArrayList<CategoryModel>)request.getAttribute("categories");
								for(CategoryModel category : categories) {
							%>
							<tr>
				        		<form action="CategoryController" method="post">
				        			<input type="hidden" name="action" value="update"/>
									<td><input value="<%= category.getId() %>" name="id" readonly/></td>
									<td><input value="<%= category.getCategoryName() %>" name="categoryName" required/></td>
									<td><textArea name="description" required><%= category.getDescription() %></textArea></td>
									<td><input type="submit" value="Update"/></td>
				        		</form>
				        		<%
				        			if(category.getProductCount() == 0) {
				        		%>
				        				<form action="CategoryController" method="post">
						        			<input type="hidden" name="action" value="delete"/>
						        			<input type="hidden" value="<%= category.getId() %>" name="id"/>
						        			<td><input type="submit" value="Delete"/></td>
						        		</form>
						        <% } %>
							</tr>
							<% } %>
				        </tbody>
				    </table>
					<% } else { %>
					<h3>This page is available to owners only</h3>
					<% } 
					con.close();
					%>
				</td>
			</tr>
		</table>
	<% } %>	
	<% 	} else { %>
		<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
	<% }
	%>
	
</body>
</html>