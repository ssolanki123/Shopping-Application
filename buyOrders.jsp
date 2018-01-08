<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="ucsd.shoppingApp.PersonDAO"%>
<%@ page import="ucsd.shoppingApp.models.*, java.util.*, ucsd.shoppingApp.*, java.sql.*, java.util.Random" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Shopping Application</title>
</head>
<body>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript">
	$(function(){
	    $(".submitBtn").click(function () {
	      $(".submitBtn").attr("disabled", true);
	      $('#buyOrders').submit();
	    });
	  });
</script>
	<% if(session.getAttribute("roleName") != null) { %>
		<% if(request.getParameter("totalOrder") != null && !request.getParameter("totalOrder").equals("")) {
			try {
				if(Integer.parseInt(request.getParameter("totalOrder")) <= 0 ) {
					request.setAttribute("message", "Order value is negative. Please provide a positive integer");
					request.setAttribute("error", true);
				} else {
					Connection con = ConnectionManager.getConnection();
					String INSERT_SHOPPING_CART = "INSERT INTO shopping_cart(person_id, is_purchased, purchase_info) VALUES(?, ?, ?) ";
					String INSERT_PRODUCTS_IN_CART = "INSERT INTO products_in_cart(cart_id, product_id, price, quantity) VALUES(?, ?, ?, ?)";
					String GET_RANDOM_PERSON = "SELECT id FROM person OFFSET floor(random()* (select count(*) from person)) LIMIT 1";
					String GET_RANDOM_5_PRODUCTS = "SELECT id, price FROM product OFFSET floor(random()* (select count(*) from product)) LIMIT 5";
					Random rand = new Random();
					int noOfSales = Integer.parseInt(request.getParameter("totalOrder"));
					int batchSize = 10000;
					int personId = 0;
					int noOfRows = 0;
					int productId = 0;
					int productPrice = 0;
					int quantity = 0;			
					PreparedStatement shoppingCartPtst = null, productsCartPtst  = null;
					Statement personSt = null, productSt = null;
					ArrayList<Integer> cartIds = new ArrayList<Integer>();
					try {
						shoppingCartPtst = con.prepareStatement(INSERT_SHOPPING_CART, Statement.RETURN_GENERATED_KEYS);
						productsCartPtst = con.prepareStatement(INSERT_PRODUCTS_IN_CART);
						personSt = con.createStatement();
						productSt = con.createStatement();
						
						for(int i=0;i<noOfSales;i++) {
							ResultSet personRs = personSt.executeQuery(GET_RANDOM_PERSON);
							if(personRs.next()) {
								personId = personRs.getInt("id");
							}
							personRs.close();
							
							shoppingCartPtst.setInt(1, personId);
							shoppingCartPtst.setBoolean(2, true);
							shoppingCartPtst.setString(3, "Buy N Orders Generated");
							
							shoppingCartPtst.addBatch();
							noOfRows++;
							
							if(noOfRows % batchSize == 0) {
								shoppingCartPtst.executeBatch();							
								ResultSet cartRs = shoppingCartPtst.getGeneratedKeys();
								while(cartRs.next()) {
									cartIds.add(cartRs.getInt(1));
								}
								cartRs.close();
							}
							
						}
						shoppingCartPtst.executeBatch();
						ResultSet cartRs = shoppingCartPtst.getGeneratedKeys();
						while(cartRs.next()) {
							cartIds.add(cartRs.getInt(1));
						}
						cartRs.close();
						shoppingCartPtst.close();
						
						int totalRows = 0;
						for(int i=0;i<noOfSales;i++) {
							ResultSet productRs = productSt.executeQuery(GET_RANDOM_5_PRODUCTS);
							while(productRs.next()) {
								productsCartPtst.setInt(1, cartIds.get(i));
								productId = productRs.getInt("id");
								productsCartPtst.setInt(2, productId);
								productPrice = productRs.getInt("price");
								productsCartPtst.setInt(3, productPrice);
								quantity = rand.nextInt(10)+1;
								productsCartPtst.setInt(4, quantity);
								
								productsCartPtst.addBatch();
								totalRows++;
								
								if(totalRows % batchSize == 0) {
									productsCartPtst.executeBatch();
								}
							}
							productsCartPtst.executeBatch();
						}
						con.commit();
						request.setAttribute("message", "Orders inserted successfully");
						request.setAttribute("error", false);	
					} catch(Exception e) {
						con.rollback();
						e.printStackTrace();
						request.setAttribute("message", e);
						request.setAttribute("error", true);
					} finally {
						try { 
							if(shoppingCartPtst != null) {
								shoppingCartPtst.close();
							}
							if(productsCartPtst != null) {
								productsCartPtst.close();
							}
							if(personSt != null) {
								personSt.close();
							}
							if(productSt != null) {
								productSt.close();
							}
						} catch(Exception e1) {
							e1.getStackTrace();
							request.setAttribute("message", e1);
							request.setAttribute("error", true);
						}
						if(con != null) {
							ConnectionManager.closeConnection(con);
						}
					}
				}
			}catch(Exception e2) {
				e2.printStackTrace();
			}
		}
		%>
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
		<table cellspacing="5">
			<tr>
				<td valign="top"> <jsp:include page="./menu.jsp"></jsp:include></td>
				<td></td>
				<td>
					<h3>Hello <%= session.getAttribute("personName") %></h3>
				<h3>Buy N Orders</h3>
				<p> Provide number of orders to be inserted. It will insert 'N' carts and '5' products for each cart, of random quantity between 1 and 10. Customers and Products are picked up randomly from the table </p> 
				<form method="GET" action="buyOrders.jsp" id="buyOrders">
					Enter number of Orders : <input type="text" name="totalOrder" required=true/>
					<input type="submit" value="Buy" class="submitBtn"/>
				</form>
				<br/>
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