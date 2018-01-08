<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
<%@page import ="ucsd.shoppingApp.models.*" %>
<%@page import ="ucsd.shoppingApp.controllers.*" %>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Sales Analytics</title>
</head>
	<body>
    <%
        
        if(request.getParameter("action")!= null && request.getParameter("action").equals("dropdown")) {
            int temp1 = Integer.parseInt((String)(session.getAttribute("beginrow")));
            int temp2 = Integer.parseInt((String)(session.getAttribute("endrow")));
            int temp3 = Integer.parseInt((String)(session.getAttribute("begincolumn")));
            int temp4 = Integer.parseInt((String)(session.getAttribute("endcolumn")));

            //work on
            String x = request.getParameter("customerstate");
            if(session.getAttribute("customerstate") != null) {
                session.setAttribute("customerstate",x);
            }
            else {
                session.setAttribute("customerstate", "Customer");
            }

            x = request.getParameter("listorder");

            if(session.getAttribute("listorder") != null) {
                session.setAttribute("listorder", x);
            }
            else {
                session.setAttribute("listorder", "Alphabetical");
            }

			String s = request.getParameter("salesFiltering");
			if(request.getParameter("salesFiltering") != null)
			{
			  session.setAttribute("category", s);
			}

			else
			{
			   session.setAttribute("category", "All Categories");
			}

            session.setAttribute("beginrow", "0");
            session.setAttribute("endrow", "1");
            session.setAttribute("begincolumn", "0");
            session.setAttribute("endcolumn", "1");

        }

        String Category      = ((String) session.getAttribute("category"));
        String CustomerState = (String) session.getAttribute("customerstate");
        String ListOrder     = (String) session.getAttribute("listorder");

    %>
    <%=session.getAttribute("beginrow")%>
    <%=session.getAttribute("endrow")%>
    <%=session.getAttribute("begincolumn")%>
    <%=session.getAttribute("endcolumn")%>

    <form name = "navigationrow" action = "salesAnalytics.jsp" method = "POST">
      <input type = "hidden" name = "actionnext" value  = "NextRow"/>
      <input type = "submit" value = "Next Row"  />

    </form>

    <form name = "navigationcolumn" action = "salesAnalytics.jsp" method = "POST">
      <input type = "hidden" name = "actionnext" value  = "NextColumn"/>
      <input type = "submit" value = "Next Column"  />

    </form>
    <%
      if(CustomerState == null) {
        CustomerState = "Customer";
      }

      if(ListOrder == null) {
        ListOrder = "Alphabetical";
      }
    %>

    <% Connection con = ConnectionManager.getConnection();
        CategoryDAO categoryDao = new CategoryDAO(con);
        String role = session.getAttribute("roleName").toString();

        if("owner".equalsIgnoreCase(role)) {
            List<CategoryModel> categories = categoryDao.getCategories();

    %>

		<form name = "filterResult" action = "salesAnalytics.jsp" method = "POST">
			<input type = "hidden" name = "action" value  = "dropdown"/>

				<select name = "customerstate">
					<option selected = "selected">
						Customer
					</option>

					<option>
						State
					</option>

				</select>

				<select name = "listorder">
					<option selected = "selected">
						Alphabetical
					</option>

					<option>
						Top 20
					</option>
				</select>
            <select name="salesFiltering">
                <option selected = "selected"></option>
                <option selected disabled hidden style='display: none' value=''></option>
                <option value = "All Categories">All Categories</option>
                <%
                    for (CategoryModel category : categories) {
                %>
                <option value=<%=category.getCategoryName()%>><%=category.getCategoryName()%></option>
                <%
                    }
                    }
                %>
                <input type = "submit" value = "search"  />
            </select>

		</form>
<%
  if(request.getParameter("actionnext")!= null && request.getParameter("actionnext").equals("NextRow")) {
    if((String)session.getAttribute("beginrow") == null || (String)session.getAttribute("endrow") ==null) {
      session.setAttribute("beginrow", "0");
      session.setAttribute("endrow", "0");
    }
    else {
      int temp1 = Integer.parseInt((String)(session.getAttribute("beginrow")));
      int temp2 = Integer.parseInt((String)(session.getAttribute("endrow")));
      if(temp1 != temp2) {
        temp1++;
        temp2++;
        session.setAttribute("beginrow", Integer.toString(temp1));
        session.setAttribute("endrow", Integer.toString(temp2));

      }
    }
  }

  if(request.getParameter("actionnext")!= null && request.getParameter("actionnext").equals("NextColumn")) {
    if((String)session.getAttribute("begincolumn") == null || (String)session.getAttribute("endcolumn") ==null) {
      session.setAttribute("begincolumn", "0");
      session.setAttribute("endcolumn", "0");
    }
    else {
      int temp1 = Integer.parseInt((String)(session.getAttribute("begincolumn")));
      int temp2 = Integer.parseInt((String)(session.getAttribute("endcolumn")));
      if(temp1 != temp2) {
        temp1++;
        temp2++;
        session.setAttribute("begincolumn", Integer.toString(temp1));
        session.setAttribute("endcolumn", Integer.toString(temp2));

      }
    }
  }

  %>

  <table border = "1">
    <tr>
      <%
        if (CustomerState.equals("Customer")) {
      %>
            <th>
             Customer
            </th>
      <%
        }
        else if (CustomerState.equals("State")) {
      %>
          <th>
            State
          </th>
        <%
        }
      %>

      <%
        if (ListOrder.equals("Alphabetical")) {
      %>
            <th>
             Alphabetical
            </th>
      <%
        }
        else if (ListOrder.equals("Top 20")) {
        %>
          <th>
            Top 20
          </th>
        <%
        }
      %>

    </tr>
          <%
					long startTime = System.currentTimeMillis();


          String sql1 = null;
          ArrayList<Integer> productID = new ArrayList<Integer>();

          con = ConnectionManager.getConnection();
          PreparedStatement pstmt1 = null;
          ResultSet rs1 =  null; %>
           <%= Category%>
        <%  if(CustomerState.equals("Customer") && ListOrder.equals("Alphabetical")) {

            if(Category != null && !(Category.equals("All Categories"))) {
                con.setAutoCommit(false);
                pstmt1 = con.prepareStatement(
                        " SELECT * FROM" +
                         "  ("+
                         " SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(product_name FROM '([0-9]+)')::BIGINT ASC, product_name) NUM, * FROM"+
                         " ("+
                         "    SELECT c.product_name, SUM(d.price * d.quantity), c.id"+
                         "    FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id JOIN category e ON e.category_name = ? AND e.id = c.category_id"+
                         "    GROUP BY c.product_name, c.id"+
                        " )  AS p"+
                       " ) a"+
                       " WHERE NUM >= ? AND NUM <= ?"
                        );
                pstmt1.setString(1,Category.toUpperCase());
                int first = Integer.parseInt((String)session.getAttribute("beginrow"));
                int second = Integer.parseInt((String)session.getAttribute("endrow"));
                pstmt1.setInt(2, first*10 );
                pstmt1.setInt(3, second *10);
                pstmt1.execute();
                rs1 = pstmt1.getResultSet();
                con.setAutoCommit(true);
            }

            else if(Category != null && Category.equals("All Categories")) {
                con.setAutoCommit(false);
                pstmt1 = con.prepareStatement(
                        "SELECT * FROM" +
                        "(" +
                           "SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(product_name FROM '([0-9]+)')::BIGINT ASC, product_name) NUM, * FROM" +
                           "(" +
                               " SELECT c.product_name,SUM(d.price * d.quantity), c.id" +
                               " FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id" +
                               " GROUP BY c.product_name, c.id" +
                           " ) AS p ORDER BY SUBSTRING(product_name FROM '([0-9]+)')::BIGINT ASC, product_name" +
                        ") a" + " WHERE NUM > ? AND NUM <= ?"
                        );
                int first = Integer.parseInt((String)session.getAttribute("beginrow"));
                int second = Integer.parseInt((String)session.getAttribute("endrow"));
                pstmt1.setInt(1,first*10);
                pstmt1.setInt(2, second*10);
                pstmt1.execute();
                rs1 = pstmt1.getResultSet();
                con.commit();
                con.setAutoCommit(true);
            }


          %>
      <tr>
          <td>****</td>
          <%
              while(rs1 != null && rs1.next())
                {
          %>      <td> <b><%= rs1.getString("product_name")%></b> ($<%= rs1.getString("sum")%>)</td>
          <%productID.add(rs1.getInt("id")); %>
          <%
               }

          %>
       </tr>
       <%
          con.setAutoCommit(false);
          pstmt1 = null;
          rs1 = null;
          if(Category != null && Category.equals("All Categories")) {
              pstmt1 = con.prepareStatement(
                      "SELECT * FROM" +
                              " (" +
                              " SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(person_name FROM '([0-9]+)')::BIGINT ASC, person_name) NUM, * FROM" +
                              " (" +
                              "   SELECT c.person_name, SUM(e.price * e.quantity)" +
                              "   FROM person c LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true" +
                              "   GROUP BY c.person_name" +
                              " ) AS p ) a " +
                              " WHERE NUM > ? AND NUM <= ?"
              );
              int third = Integer.parseInt((String) session.getAttribute("begincolumn"));
              int fourth = Integer.parseInt((String) session.getAttribute("endcolumn"));
              pstmt1.setInt(1, third * 20);
              pstmt1.setInt(2, fourth * 20);
              pstmt1.execute();
              rs1 = pstmt1.getResultSet();
              con.commit();
              con.setAutoCommit(true);
          }

          else if(Category != null && !Category.equals("All Categories"))
          {
              pstmt1 = con.prepareStatement(
                      "SELECT * FROM" +
                              " (" +
                              " SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(person_name FROM '([0-9]+)')::BIGINT ASC, person_name) NUM, * FROM" +
                              " (" +
                              "   SELECT c.person_name, SUM(e.price * e.quantity)" +
                              "   FROM person c LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true" +
                              "   JOIN Category f on f.category_name = ? JOIN Product g ON g.category_id = f.id AND g.id = e.product_id " +
                              "   GROUP BY c.person_name" +
                              " ) AS p ) a " +
                              " WHERE NUM > ? AND NUM <= ?"
              );
              int third = Integer.parseInt((String) session.getAttribute("begincolumn"));
              int fourth = Integer.parseInt((String) session.getAttribute("endcolumn"));
              pstmt1.setString(1, Category);
              pstmt1.setInt(2, third * 20);
              pstmt1.setInt(3, fourth * 20);
              pstmt1.execute();
              rs1 = pstmt1.getResultSet();
              con.commit();
              con.setAutoCommit(true);
          }
          while(rs1!= null && rs1.next()) {
      %>
      <tr>
          <td><b><%=rs1.getString("person_name")%></b>  ($<%=rs1.getString("sum")%>)</td>
         <%
             int index = 0;
              PreparedStatement pstmt2 = null;
              ResultSet rs2 = null;
              while(index < productID.size()) {
                  if(!Category.equals("All Categories")) {
                      con.setAutoCommit(false);
                      pstmt2 = con.prepareStatement(
                              " SELECT SUM(c.price * c.quantity) as totalSales" +
                              " FROM person a, shopping_cart b, products_in_cart c, product d, category e "+
                              " WHERE a.person_name = ? AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id" +
                              " AND d.id = ? AND e.category_name = ? AND d.category_id = e.id "
                      );

                      pstmt2.setString(1, rs1.getString("person_name"));
                      pstmt2.setInt(2, productID.get(index));
                      pstmt2.setString(3, Category);
                      pstmt2.execute();
                      con.commit();
                      con.setAutoCommit(true);
                      rs2 = pstmt2.getResultSet();
                  }

                  else {
                      con.setAutoCommit(false);
                      pstmt2 = con.prepareStatement(
                              " SELECT SUM(c.price * c.quantity) AS totalSales "+
                              " FROM person a, shopping_cart b, products_in_cart c, product d" +
                              " WHERE a.person_name = ? AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id AND d.id = ? "

                      );

                      pstmt2.setString(1, rs1.getString("person_name"));
                      pstmt2.setInt(2, productID.get(index));
                      pstmt2.execute();
                      con.commit();
                      con.setAutoCommit(true);
                      rs2 = pstmt2.getResultSet();
                  }

                  if(rs2!= null && rs2.next()){ %>
                     <td> $<%=rs2.getInt("totalSales")%> </td>
              <% }

                  else { %>
                     <td> $0 </td>
              <%     }
              index += 1;
              }

              }

          %>


      <%
          productID.clear();
         }
      %>

      <%
           if(CustomerState.equals("State") && ListOrder.equals("Alphabetical")) {
              if(Category != null && !(Category.equals("All Categories"))) {
                pstmt1 = null;
                rs1 = null;
                con.setAutoCommit(false);
                pstmt1 = con.prepareStatement(
                        " SELECT * FROM" +
                         "  ("+
                         " SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(product_name FROM '([0-9]+)')::BIGINT ASC, product_name) NUM, * FROM"+
                         " ("+
                         "    SELECT c.product_name, SUM(d.price * d.quantity), c.id"+
                         "    FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id JOIN category e ON e.category_name = ? AND e.id = c.category_id"+
                         "    GROUP BY c.product_name, c.id"+
                        " )  AS p"+
                       " ) a"+
                       " WHERE NUM >= ? AND NUM <= ?"
                        );
                pstmt1.setString(1,Category.toUpperCase());
                int first = Integer.parseInt((String)session.getAttribute("beginrow"));
                int second = Integer.parseInt((String)session.getAttribute("endrow"));
                pstmt1.setInt(2, first*10 );
                pstmt1.setInt(3, second *10);
                pstmt1.execute();
                rs1 = pstmt1.getResultSet();
                con.setAutoCommit(true);
            }

             else if(Category != null && Category.equals("All Categories")) {
                con.setAutoCommit(false);
                pstmt1 = con.prepareStatement(
                        "SELECT * FROM" +
                        "(" +
                           "SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(product_name FROM '([0-9]+)')::BIGINT ASC, product_name) NUM, * FROM" +
                           "(" +
                               " SELECT c.product_name,SUM(d.price * d.quantity), c.id" +
                               " FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id" +
                               " GROUP BY c.product_name, c.id" +
                           " ) AS p ORDER BY SUBSTRING(product_name FROM '([0-9]+)')::BIGINT ASC, product_name" +
                        ") a" + " WHERE NUM > ? AND NUM <= ?"
                        );
                int first = Integer.parseInt((String)session.getAttribute("beginrow"));
                int second = Integer.parseInt((String)session.getAttribute("endrow"));
                pstmt1.setInt(1,first*10);
                pstmt1.setInt(2, second*10);
                pstmt1.execute();
                rs1 = pstmt1.getResultSet();
                con.commit();
                con.setAutoCommit(true);
            }

      %>
      <tr>
          <td>****</td>
          <%
              while(rs1!= null && rs1.next())
              {
          %>      <td> <b><%= rs1.getString("product_name")%></b> ($<%= rs1.getString("sum")%>)</td>
          <%productID.add(rs1.getInt("id")); %>
          <%
              }
          %>
      </tr>
      <%
          if(Category != null && Category.equals("All Categories")) {
              pstmt1 = null;
              rs1 = null;
              con.setAutoCommit(false);
              pstmt1 = con.prepareStatement(
                      "SELECT * FROM " +
                              " (" +
                              "  SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(state_name FROM '([0-9]+)')::BIGINT ASC, state_name) NUM, * FROM" +
                              "(" +
                              "  SELECT f.state_name, f.id ,SUM(e.price * e.quantity)" +
                              " FROM person c LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id JOIN products_in_cart e ON d.id = e.cart_id" +
                              "  AND d.is_purchased = true JOIN state f ON f.id = c.state_id" +
                              " GROUP BY f.state_name, f.id " +
                              " ) AS p ) a" +
                              " WHERE NUM > ? AND NUM <= ?"
              );
              int third = Integer.parseInt((String) session.getAttribute("begincolumn"));
              int fourth = Integer.parseInt((String) session.getAttribute("endcolumn"));
              pstmt1.setInt(1, third * 20);
              pstmt1.setInt(2, fourth * 20);
              pstmt1.execute();
              rs1 = pstmt1.getResultSet();
              con.commit();
              con.setAutoCommit(true);
          }

          else if (Category != null && !Category.equals("All Categories")){
              con.setAutoCommit(false);
              pstmt1 = con.prepareStatement(
                      " SELECT * FROM " +
                        " (" +
                         " SELECT ROW_NUMBER() OVER(ORDER BY SUBSTRING(state_name FROM '([0-9]+)')::BIGINT ASC, state_name) NUM, * FROM " +
                         " ("+
                          " SELECT f.state_name, f.id ,SUM(e.price * e.quantity)" +
                          " FROM person c LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id JOIN products_in_cart e ON d.id = e.cart_id" +
                          "  AND d.is_purchased = true JOIN state f ON f.id = c.state_id JOIN Category g ON g.category_name = ? " +
                          " JOIN product h ON h.category_id = g.id AND h.id = e.product_id" +
                          " GROUP BY f.state_name, f.id " +
                          "  ) AS p ) a " +
                          " WHERE NUM > ? AND NUM <= ?"
              );
              int third = Integer.parseInt((String) session.getAttribute("begincolumn"));
              int fourth = Integer.parseInt((String) session.getAttribute("endcolumn"));
              pstmt1.setString(1,Category);
              pstmt1.setInt(2, third * 20);
              pstmt1.setInt(3, fourth * 20);
              pstmt1.execute();
              rs1 = pstmt1.getResultSet();
              con.commit();
              con.setAutoCommit(true);
          }

          while(rs1!= null && rs1.next()) {
      %>

      <tr>
          <td><b><%=rs1.getString("state_name")%></b>  ($<%=rs1.getString("sum")%>)</td>
      <%
          int index = 0;
          PreparedStatement pstmt2 = null;
          ResultSet rs2 = null;
          while(index < productID.size()) {
              if(!Category.equals("All Categories")) {
                  con.setAutoCommit(false);
                  pstmt2 = con.prepareStatement(
                          " SELECT SUM(c.price * c.quantity) as totalSales" +
                          " FROM person a, shopping_cart b, products_in_cart c, product d, category e, state f" +
                          " WHERE f.id = ? AND a.state_id = f.id AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id "+
                          " AND d.id = ? AND e.category_name = ? AND d.category_id = e.id"
                  );

                  pstmt2.setInt(1, rs1.getInt("id"));
                  pstmt2.setInt(2, productID.get(index));
                  pstmt2.setString(3, Category);
                  pstmt2.execute();
                  con.commit();
                  con.setAutoCommit(true);
                  rs2 = pstmt2.getResultSet();
              }

              else {
                  con.setAutoCommit(false);
                  pstmt2 = con.prepareStatement(
                          " SELECT SUM(c.price * c.quantity) AS totalSales " +
                          " FROM person a, shopping_cart b, products_in_cart c, product d, state e " +
                          " WHERE e.id = ? AND a.state_id = e.id AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id AND d.id = ? "
                  );

                  pstmt2.setInt(1, rs1.getInt("id"));
                  pstmt2.setInt(2, productID.get(index));
                  pstmt2.execute();
                  con.commit();
                  con.setAutoCommit(true);
                  rs2 = pstmt2.getResultSet();
              }

              if(rs2!= null && rs2.next()){ %>
                <td> $<%=rs2.getInt("totalSales")%> </td>
      <% }

              else { %>
                <td> $0 </td>
      <%     }
          index += 1;
      }

      }

          productID.clear();
          }

        else if (CustomerState.equals("Customer") && ListOrder.equals("Top 20")) {
          //get top 20 products all categories
          pstmt1 = null;
          rs1 = null;
          if(Category != null && (Category.equals("All Categories"))) {
            con.setAutoCommit(false);
            pstmt1 = con.prepareStatement("SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY totalSales DESC) NUM,  * " +
						"FROM  (SELECT a.product_id, c.product_name, SUM(a.price * a.quantity) as totalSales " +
						"FROM products_in_cart a, shopping_cart b, product c " +
						"WHERE a.cart_id = b.id AND b.is_purchased = true AND c.id = a.product_id " +
						"GROUP BY c.product_name, a.product_id ) as S  " +
						") as topProducts " +
						"WHERE NUM >? AND NUM <= ? " +
						"ORDER BY totalSales DESC ");

            int first = Integer.parseInt((String)session.getAttribute("beginrow"));
            int second = Integer.parseInt((String)session.getAttribute("endrow"));
            pstmt1.setInt(1,first*10);
            pstmt1.setInt(2, second*10);
            pstmt1.execute();
            rs1 = pstmt1.getResultSet();
            con.commit();
            con.setAutoCommit(true);

          }

          else if (Category != null && !(Category.equals("All Categories"))) {
            con.setAutoCommit(false);
            pstmt1 = con.prepareStatement(" SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY totalSales DESC) NUM,  " +
		         "* FROM (SELECT a.product_id, c.product_name, d.category_name, SUM(a.price * a.quantity) as totalSales " +
		         "FROM products_in_cart a, shopping_cart b, product c, category d " +
		         "WHERE a.cart_id = b.id AND b.is_purchased = true AND c.id = a.product_id AND c.category_id = d.id AND d.category_name = ? " +
		         "GROUP BY a.product_id, c.product_name, d.category_name  " +
		         ") as S ) as topProducts WHERE NUM >? AND NUM <=? " +
		         "ORDER BY totalSales DESC ");

             pstmt1.setString(1,Category.toUpperCase());
             int first = Integer.parseInt((String)session.getAttribute("beginrow"));
             int second = Integer.parseInt((String)session.getAttribute("endrow"));
             pstmt1.setInt(2, first*10 );
             pstmt1.setInt(3, second *10);
             pstmt1.execute();
             rs1 = pstmt1.getResultSet();
             con.setAutoCommit(true);
          }

        %>
    <tr>
        <td>****</td>
        <%
            while(rs1!= null && rs1.next())
              {
        %>
          <td> <b><%= rs1.getString("product_name")%></b> ($<%= rs1.getString("totalsales")%>)</td>
          <%productID.add(rs1.getInt("product_id")); %>
        <%
             }

        %>
    </tr>
     <%

          //get top customers
          if(Category != null && Category.equals("All Categories")) {
              pstmt1 = null;
              rs1 = null;
              con.setAutoCommit(false);
              pstmt1 = con.prepareStatement(" SELECT * FROM ( " +
                      "SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *  FROM ( SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name, c.id  " +
                      "FROM products_in_cart a, shopping_cart b, person c, state s " +
                      " WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id  " +
                      "GROUP BY c.person_name, c.id  )  as s ORDER BY s.TOTALS DESC  ) a  WHERE NUM >=? AND NUM <=? ");

              int third = Integer.parseInt((String) session.getAttribute("begincolumn"));
              int fourth = Integer.parseInt((String) session.getAttribute("endcolumn"));
              pstmt1.setInt(1, third * 20);
              pstmt1.setInt(2, fourth * 20);
              pstmt1.execute();
              rs1 = pstmt1.getResultSet();
              con.commit();
              con.setAutoCommit(true);
          }

          else if(Category != null && !(Category.equals("All Categories")))
          {
              con.setAutoCommit(false);
              pstmt1 = con.prepareStatement(" SELECT * FROM ( " +
                      "SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *  FROM ( SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name, c.id  " +
                      "FROM products_in_cart a, shopping_cart b, person c, state s, category d, product e " +
                      " WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id AND d.category_name = ? " +
                      " AND d.id = e.category_id AND e.id = a.product_id " +
                      " GROUP BY c.person_name, c.id  )  as s ORDER BY s.TOTALS DESC  ) a  WHERE NUM >=? AND NUM <=? ");

              int third = Integer.parseInt((String) session.getAttribute("begincolumn"));
              int fourth = Integer.parseInt((String) session.getAttribute("endcolumn"));
              pstmt1.setString(1, Category);
              pstmt1.setInt(2, third * 20);
              pstmt1.setInt(3, fourth * 20);
              pstmt1.execute();
              rs1 = pstmt1.getResultSet();
              con.commit();
              con.setAutoCommit(true);
          }

             while(rs1!= null && rs1.next()) {
         %>
         <tr>
             <td><b><%=rs1.getString("person_name")%></b>  ($<%=rs1.getString("totals")%>)</td>
             <%
                 int index = 0;
                 PreparedStatement pstmt2 = null;
                 ResultSet rs2 = null;
                 while(index < productID.size()) {
                     if(!Category.equals("All Categories")) {
                         con.setAutoCommit(false);
                         pstmt2 = con.prepareStatement(
                                 " SELECT SUM(c.price * c.quantity) as totalSales" +
                                         " FROM person a, shopping_cart b, products_in_cart c, product d, category e "+
                                         " WHERE a.person_name = ? AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id" +
                                         " AND d.id = ? AND e.category_name = ? AND d.category_id = e.id "
                         );

                         pstmt2.setString(1, rs1.getString("person_name"));
                         pstmt2.setInt(2, productID.get(index));
                         pstmt2.setString(3, Category);
                         pstmt2.execute();
                         con.commit();
                         con.setAutoCommit(true);
                         rs2 = pstmt2.getResultSet();
                     }

                     else {
                         con.setAutoCommit(false);
                         pstmt2 = con.prepareStatement(
                                 " SELECT SUM(c.price * c.quantity) AS totalSales "+
                                         " FROM person a, shopping_cart b, products_in_cart c, product d" +
                                         " WHERE a.person_name = ? AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id AND d.id = ? "

                         );

                         pstmt2.setString(1, rs1.getString("person_name"));
                         pstmt2.setInt(2, productID.get(index));
                         pstmt2.execute();
                         con.commit();
                         con.setAutoCommit(true);
                         rs2 = pstmt2.getResultSet();
                     }

                     if(rs2.next()){ %>
             <td> $<%=rs2.getInt("totalSales")%> </td>
             <% }

             else { %>
             <td> $0 </td>
             <%     }
                 index += 1;
             }

             }

             %>
         <%
               productID.clear();
           }
/***************************************************************************************
*/

           else if (CustomerState.equals("State") && ListOrder.equals("Top 20")) {
               if(Category != null && (Category.equals("All Categories"))) {
                 pstmt1 = null;
                 rs1 = null;
                 con.setAutoCommit(false);
                 pstmt1 = con.prepareStatement("SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY totalSales DESC) NUM,  * " +
                           "FROM  (SELECT a.product_id, c.product_name, SUM(a.price * a.quantity) as totalSales " +
                           "FROM products_in_cart a, shopping_cart b, product c " +
                           "WHERE a.cart_id = b.id AND b.is_purchased = true AND c.id = a.product_id " +
                           "GROUP BY c.product_name, a.product_id ) as S  " +
                           ") as topProducts " +
                           "WHERE NUM >=? AND NUM <= ? " +
                           "ORDER BY totalSales DESC ");

                 int first = Integer.parseInt((String)session.getAttribute("beginrow"));
                 int second = Integer.parseInt((String)session.getAttribute("endrow"));
                 pstmt1.setInt(1,first*10);
                 pstmt1.setInt(2, second*10);
                 pstmt1.execute();
                 rs1 = pstmt1.getResultSet();
                 con.commit();
                 con.setAutoCommit(true);

               }

               else if (Category != null && !(Category.equals("All Categories"))) {
                 con.setAutoCommit(false);
                 pstmt1 = con.prepareStatement(" SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY totalSales DESC) NUM,  " +
                    "* FROM (SELECT a.product_id, c.product_name, d.category_name, SUM(a.price * a.quantity) as totalSales " +
                    "FROM products_in_cart a, shopping_cart b, product c, category d " +
                    "WHERE a.cart_id = b.id AND b.is_purchased = true AND c.id = a.product_id AND c.category_id = d.id AND d.category_name = ? " +
                    "GROUP BY a.product_id, c.product_name, d.category_name  " +
                    ") as S ) as topProducts WHERE NUM >=? AND NUM <=? " +
                    "ORDER BY totalSales DESC ");

                  pstmt1.setString(1,Category.toUpperCase());
                  int first = Integer.parseInt((String)session.getAttribute("beginrow"));
                  int second = Integer.parseInt((String)session.getAttribute("endrow"));
                  pstmt1.setInt(2, first*10 );
                  pstmt1.setInt(3, second *10);
                  pstmt1.execute();
                  rs1 = pstmt1.getResultSet();
                  con.setAutoCommit(true);
               }

             %>
         <tr>
             <td>****</td>
             <%
                 while(rs1!= null && rs1.next())
                   {
             %>
               <td> <b><%= rs1.getString("product_name")%></b> ($<%= rs1.getString("totalsales")%>)</td>
               <%productID.add(rs1.getInt("product_id")); %>
             <%
                  }

             %>
         </tr>
         <%

         if(Category != null && (Category.equals("All Categories"))) {
           pstmt1 = null;
           rs1 = null;
           con.setAutoCommit(false);
           pstmt1 = con.prepareStatement(
                   " SELECT * FROM (" +
                          " SELECT ROW_NUMBER() OVER(ORDER BY (totalSales) DESC ) NUM, *  FROM (" +
                          " SELECT SUM(a.price * a.quantity) as totalSales, s.id, s.state_name" +
                          " FROM products_in_cart a, shopping_cart b, person c, state s" +
                          " WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id" +
                          " GROUP BY s.state_name, s.id" +
                          " ORDER BY totalSales DESC" +
                  " ) as s" +
          " )A" +
             " WHERE NUM > ? AND NUM < ?"
           );

           int first = Integer.parseInt((String)session.getAttribute("beginrow"));
           int second = Integer.parseInt((String)session.getAttribute("endrow"));
           int third = Integer.parseInt((String)session.getAttribute("begincolumn"));
           int fourth = Integer.parseInt((String)session.getAttribute("endcolumn"));
           pstmt1.setInt(1,third *20);
           pstmt1.setInt(2, fourth *20);
           pstmt1.execute();
           rs1 = pstmt1.getResultSet();
           con.commit();
           con.setAutoCommit(true);

         }

         else if (Category != null && !(Category.equals("All Categories"))) {
           con.setAutoCommit(false);
           pstmt1 = con.prepareStatement(
                   "SELECT * FROM( " +
                           "SELECT ROW_NUMBER() OVER(ORDER BY (totalSales) DESC ) NUM, *  FROM ( " +
                           "SELECT SUM(a.price * a.quantity) as totalSales, s.state_name, s.id " +
                           "FROM products_in_cart a, shopping_cart b, person c, state s, category d, product e " +
                           "WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id AND d.category_name = ? AND e.category_id = d.id AND a.product_id = e.id " +
                           "GROUP BY s.state_name, s.id " +
                           "ORDER BY totalSales DESC" +
                           ") as s" +
           ") a"+
             " WHERE NUM > ? AND NUM <= ?"
           );

            int first = Integer.parseInt((String)session.getAttribute("beginrow"));
            int second = Integer.parseInt((String)session.getAttribute("endrow"));
            int third = Integer.parseInt((String)session.getAttribute("begincolumn"));
            int fourth = Integer.parseInt((String)session.getAttribute("endcolumn"));
            pstmt1.setString(1,Category.toUpperCase());
            pstmt1.setInt(2, third*20 );
            pstmt1.setInt(3, fourth *20);
            pstmt1.execute();
            rs1 = pstmt1.getResultSet();
            con.setAutoCommit(true);
         }

       %>
   <tr>
       <%
           while(rs1!= null && rs1.next())
             {
       %>
       <tr>
           <td> <b><%= rs1.getString("state_name")%></b> ($<%= rs1.getString("totalsales")%>)</td>
           <%
               int index = 0;
               PreparedStatement pstmt2 = null;
               ResultSet rs2 = null;
               while(index < productID.size()) {
                   if(!Category.equals("All Categories")) {
                       con.setAutoCommit(false);
                       pstmt2 = con.prepareStatement(
                               " SELECT SUM(c.price * c.quantity) as totalSales" +
                               " FROM person a, shopping_cart b, products_in_cart c, product d, category e, state f" +
                               " WHERE f.id = ? AND a.state_id = f.id AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id "+
                               " AND d.id = ? AND e.category_name = ? AND d.category_id = e.id"
                       );

                       pstmt2.setInt(1, rs1.getInt("id"));
                       pstmt2.setInt(2, productID.get(index));
                       pstmt2.setString(3, Category);
                       pstmt2.execute();
                       con.commit();
                       con.setAutoCommit(true);
                       rs2 = pstmt2.getResultSet();
                   }

                   else {
                       con.setAutoCommit(false);
                       pstmt2 = con.prepareStatement(
                               " SELECT SUM(c.price * c.quantity) AS totalSales " +
                               " FROM person a, shopping_cart b, products_in_cart c, product d, state e " +
                               " WHERE e.id = ? AND a.state_id = e.id AND b.person_id = a.id AND c.cart_id = b.id AND c.product_id = d.id AND d.id = ? "
                       );

                       pstmt2.setInt(1, rs1.getInt("id"));
                       pstmt2.setInt(2, productID.get(index));
                       pstmt2.execute();
                       con.commit();
                       con.setAutoCommit(true);
                       rs2 = pstmt2.getResultSet();
                   }

                   if(rs2!= null && rs2.next()){ %>
                     <td> $<%=rs2.getInt("totalSales")%> </td>
           <% }

                   else { %>
                     <td> $0 </td>
           <%     }
               index += 1;
           }

           }

           %>
       </tr>
       <%
            }
						long endTime = System.currentTimeMillis();
       %>
			 time;<%= endTime - startTime %>

   </tr>
      </tr>
  </table>
	</body>
</html>
