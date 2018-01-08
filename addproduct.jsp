<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Add new product</title>
</head>
<body>
<%
	Connection con = ConnectionManager.getConnection();	
	CategoryDAO categoryDao = new CategoryDAO(con);
	List<CategoryModel> category_list = categoryDao.getCategories();
	con.close();
	if(session.getAttribute("roleName") != null) {
		String role = session.getAttribute("roleName").toString();
		if("owner".equalsIgnoreCase(role) == true){
			int category_id = -1;
			if (request.getSession().getAttribute("sess_category_id") != null){
				category_id = Integer.parseInt(request.getSession().getAttribute("sess_category_id").toString());
			}
%>
			<h3>
				Add a new product
			</h3>
			<form action="ProductController" method="post" >
				<table>
					<tr>
						<td>
							Name:
						</td>
						<td>
							<input value="<%=(request.getSession().getAttribute("sess_match_prod_name")==null)? "" : request.getSession().getAttribute("sess_match_prod_name").toString() %>" name="prod_name" required>
						</td>
					</tr>
					
					<tr>
						<td>
							SkuId:
						</td>
						<td>
							<input value="" name="sku_id" required>
						</td>
					</tr>
					
					<tr>
						<td>
							Price:
						</td>
						<td>
							<input type="number" value="" name="price" required>
						</td>
					</tr>
					
					<tr>
						<td>
							Category:
						</td>
						<td>
							<select required name="category_id">
										<option selected disabled hidden style='display: none' value=""></option>
										<%
											for (CategoryModel cat : category_list) {
										%>
										<option value="<%=cat.getId()%>" <%if (cat.getId() == category_id) { %> selected="selected" <%} %>> 
											<%=cat.getCategoryName()%>
										</option>
										<%
											}
										%>
								</select>
						</td>
					</tr>
					<tr>
						<td>
							<input type="submit" value="insert" name="action">
						</td>
					</tr>
				</table>
			</form>
			
			<a href="./product.jsp">cancel</a>
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