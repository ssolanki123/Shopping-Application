<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
<%
	if(session.getAttribute("roleName") != null) { %>
		<table cellspacing="5">
				<tr>
					<td valign="top"><jsp:include page="menu.jsp"></jsp:include></td>
					<td></td>
					<td>
		<%
			Connection con = ConnectionManager.getConnection();	
			String role =(String) session.getAttribute("roleName"); 
			int role_flag = 0; //Default owner
			if(role.equals("Customer"))
				role_flag=1;
			CategoryDAO cd = new CategoryDAO(con);
			List<CategoryModel> category_list = cd.getCategories();
			con.close();
		%>
		<h3>Hello <%= session.getAttribute("personName") %></h3>
		<h3> Browse Products</h3>	
		<form id="catform" action="ProductSearchResultsController" method="GET">
		<label for="search">Enter search keyword</label>
		<input id="search" type="text" name="browseproductname" value ="${productname}"/>
		<input id="category" type="hidden" name="browsecategory"/>
		<br/>
		</br>
		<div>
			<b>Categories</b>:
			<%
			for (CategoryModel cat : category_list) { %>
				<a href="javascript:void(0);" onclick= "addCategory(this);"><%= cat.getCategoryName()%></a> 
				<% }%>
				<a href="javascript:void(0);" onclick= "addCategory(this);">All products</a>
		<button type="submit"> Search for Products</button>
		</div>
		
		<div id="result">
		<c:if test="${zeroresults==1}">
		  <h4> No results found</h4>
		</c:if>
		<c:if test="${pres==1}">
		    <table border='10'>
		    	<tr>
		    		<th>Name </th>
		    		<th> SKU </th>
		    		<th> Category </th>
		    		<th> Price </th>
		    		<th> Add to Shopping Cart </th>
		    	</tr>
		    	<%
		    	ArrayList<ProductModel> products = new ArrayList<ProductModel>();
				if(request.getAttribute("products") != null) 
					products = (ArrayList<ProductModel>) request.getAttribute("products");
				
		   		for (ProductModel product : products){
		    	%>
		            <tr>
		                <td><%=product.getProduct_name() %></td>
		                <td><%=product.getSku_id() %></td>
		                <td><%=product.getCategory_name() %></td>
		                <td><%= product.getPrice() %></td>
		                <td><a href="./ShoppingCartController?pid=<%= product.getProduct_id()%>">Add to cart</a></td>
		            </tr>
		        <% } %>
		    </table>
		</c:if>
		</div>
		</form>
		</td>
				</tr>
			</table>
		
		
		<script type="text/javascript">
		function addCategory(obj){
			var cat_obj = document.getElementById("category");
			cat_obj.setAttribute("value", obj.text);
			document.querySelector('form').submit();
			return false;
		}
		
		</script>
	<%}
	else { %>
	<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
	<% } %>
</body>
</html>