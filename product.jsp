<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Products</title>
</head>
<body>
<%
	if(session.getAttribute("roleName") != null) {
		String role = session.getAttribute("roleName").toString();
		if("owner".equalsIgnoreCase(role) == true){
			Connection con = ConnectionManager.getConnection();	
			CategoryDAO categoryDao = new CategoryDAO(con);
			List<CategoryModel> category_list = categoryDao.getCategories();
			con.close();
			
%>
			<table cellspacing="5">
				<tr>
					<td valign="top"> <jsp:include page="./menu.jsp"></jsp:include></td>
					<td></td>
					<td>
						<h3>Hello <%= session.getAttribute("personName") %></h3>
						<h3>Products<h4><a href="./addproduct.jsp">Add Product</a></h4></h3>
						
						<% if (request.getAttribute("error")!=null && Boolean.parseBoolean(request.getAttribute("error").toString())) {%>
							<h4 style="color:red"> Error : <%= request.getAttribute("errorMsg").toString()%></h4> 
						<%}%>
						<% if (request.getAttribute("message")!=null) {%>
							<h4> Message : <%= request.getAttribute("message").toString()%></h4> 
						<%}%>
						<form action="ProductController" method="get" >
							
								Product Id: <input type="text" name="prod_id" value="${prod_id}" />
								Search by name: <input type="text" name="match_prod_name" value="<%= (request.getAttribute("match_prod_name")==null)? "" : request.getAttribute("match_prod_name").toString() %>" />
								</br>
								<label>
									<input type="radio" name="category_id" value="-1" checked="checked">
									all
								</label>
								<%
								int checked = -1;
								if (request.getAttribute("category_id") != null){
									checked = Integer.parseInt(request.getAttribute("category_id").toString());
								}
								for (CategoryModel cat : category_list) {
								%>
									<label>
										<input type="radio" name="category_id" value="<%=cat.getId()%>" <%if (cat.getId() == checked) { %>checked="checked" <%} %> >
										<%=cat.getCategoryName()%>
									</label>
								<%
								}
								%>
								</br>
							<h4><input type="submit" value="Search for Products" /></h4>
						</form>
						<% 
						ArrayList<ProductModelExtended> products = new ArrayList<ProductModelExtended>();
						if(request.getAttribute("products") != null) 
							products = (ArrayList<ProductModelExtended>) request.getAttribute("products");
						if (products.size()>0) { 
						%>
						<table border="1" style="border-collapse: collapse">
						<thead>
					            <tr>
					                <th>SkuId</th>
					                <th>ProductName</th>
					                <th>Category</th>
					                <th>Price</th>
					                <th colspan=2>Action</th>
					            </tr>
					        </thead>
							<%
					   		for (ProductModelExtended product : products){
					   		%>
					       		<tr>
					           		<form action="ProductController" method="post">
					           			<input type="hidden" readonly="readonly" value="<%= product.getProduct_id()%>" name="prod_id">
					            		<td>
					            			<input type="text" value="<%= product.getSku_id()%>" name="sku_id">
					            		</td>
					            		<td>
					            			<input type="text" value="<%=product.getProduct_name()%>" name="prod_name">
					            		</td>
					            		<td>
					            			<select required name="category_id">
												<%
												for (CategoryModel cat : category_list) {
												%>
												<option value="<%=cat.getId()%>" <%if (cat.getId() == product.getCategory_id()) { %> selected="selected" <%} %>> 
													<%=cat.getCategoryName()%>
												</option>
												<%
												}
												%>
											</select>
					            		</td>
					            		<td> 
					            			<input type="number" value="<%=product.getPrice() %>" name="price">
					            		</td>
					            		<td> 
					            			<input type="submit" name="action" value="update">
					            		</td>
					           		</form>
					           		
					           		<%if (product.getProduct_buy_count() ==0) {%>
					           		<form action="ProductController" method="post">
					           			<input type="hidden" readonly="readonly" value="<%= product.getProduct_id()%>" name="prod_id">
					       				<td>
					       					<input type="submit" name="action" value="delete">
					       				</td>
					           		</form>
					           		<%} else {%>
					           			<td></td>
					           		<%} %>
					       		</tr>
					   		<%
					   		} 
					   		%>
						</table>
						<%}
						else {
						%>
							<label> </label>
						<%
						}
						%>
					</td>
				</tr>
			</table>	
	<%
		} 
		else { %>
			<h3>This page is available to owners only</h3>
		<%
		}
	}
	else { %>
			<h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
	<%} %>
</body>
</html>