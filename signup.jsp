<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
<%-- taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"--%>
<%-- taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"--%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>User Sign-Up</title>
</head>
<body>
	<%
		Connection con = ConnectionManager.getConnection();	
		HashMap<Integer, String> roles = RoleDAO.getRoles(con);
		HashMap<Integer, String> states = StateDAO.getStates(con);
		con.close();
	%>
	<form action="RegistrationController" method="POST">
		<div style="color: #FF0000;">${errorMessage}</div>
		<% request.setAttribute("errorMessage", null); %>
		<table>
			<thead>
				<tr>
					<th>Register New User</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>Name</td>
					<td><input type="text" name="username" required="true"></td>
				</tr>
				<tr>
					<td>Role</td>
					<td><select required name="role">
							<option selected disabled hidden style='display: none' value=''></option>
							<%
								for (Integer key : roles.keySet()) {
							%>
							<option value=<%=key%>><%=roles.get(key)%></option>
							<%
								}
							%>
					</select></td>
				</tr>
				<tr>
					<td>Age</td>
					<td><input type="number" name="age" required="true"></td>
				</tr>
				<tr>
					<td>State</td>
					<td><select required name="state">
							<option selected disabled hidden style='display: none' value=''></option>
							<%
								for (Integer key : states.keySet()) {
							%>
							<option value=<%=key%>><%=states.get(key)%></option>
							<%
								}
							%>
					</select></td>
				</tr>
			</tbody>
		</table>
		<input type="Submit" value="Register"></input>
	</form>
</body>
</html>