<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
<%@page import ="ucsd.shoppingApp.models.*" %>
<%@page import ="ucsd.shoppingApp.controllers.*" %>
<%@page import="org.json.*, java.lang.*"%>

<% response.setContentType("application/json") ; %>
<%@page contentType="text/html; charset=UTF-8"%>


<%
  String Category = ((String) session.getAttribute("category"));
  Connection con = ConnectionManager.getConnection();
  PreparedStatement pstmt1 = null;
  PreparedStatement pstmt2 = null;
  PreparedStatement pstmt3 = null;
  PreparedStatement pstmt4 = null;
  PreparedStatement pstmt5 = null;
  PreparedStatement pstmt6 = null;
  PreparedStatement pstmt7 = null;
  PreparedStatement pstmt8 = null;
  PreparedStatement pstmt9 = null;
  PreparedStatement pstmt10 = null;

  ResultSet rs1 =  null;
  ResultSet rs2 = null;
  ResultSet rs3 = null;
  ResultSet rs4 = null;
  ResultSet rs5 = null;
  ResultSet rs6 = null;


  con.setAutoCommit(false);

  if(Category != null && Category.equals("All Categories")) {

    //cell all category
    pstmt1 = con.prepareStatement(" with overall_table as " +
    "(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount " +
    "  from products_in_cart pc " +
    "  inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true) " +
    "  inner join product p on (pc.product_id = p.id)  " +
    "  inner join person c on (sc.person_id = c.id) " +
    "  group by pc.product_id,c.state_id " +
    "), " +
    "top_state as " +
    "(select state_id, sum(amount) as dollar from ( " +
    " select state_id, amount from overall_table " +
    " UNION ALL " +
    " select id as state_id, 0.0 as amount from state " +
    " ) as state_union " +
    " group by state_id order by dollar desc limit 50 " +
    "), " +
    "top_n_state as " +
    "(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state " +
    "), " +
    "top_prod as " +
    "(select product_id, sum(amount) as dollar from ( " +
    " select product_id, amount from overall_table " +
    " UNION ALL " +
    "select id as product_id, 0.0 as amount from product " +
    " ) as product_union " +
    "group by product_id order by dollar desc limit 50 " +
    "), " +
    "top_n_prod as " +
    "(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod " +
    ") " +
    "select ts.state_id, s.state_name, tp.product_id, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum " +
    " from top_n_prod tp CROSS JOIN top_n_state ts " +
    " LEFT OUTER JOIN overall_table ot " +
    " ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id) " +
    " inner join state s ON ts.state_id = s.id " +
    " inner join product pr ON tp.product_id = pr.id " +
    " order by ts.state_order, tp.product_order ");

    //state all category
    pstmt2 = con.prepareStatement("  SELECT f.id AS state_id, f.state_name AS stateName, coalesce(SUM(e.price * e.quantity),0) as totalSales " +
		" FROM state f LEFT OUTER JOIN person c ON f.id = c.state_id LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id " +
		" LEFT OUTER JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true " +
		" GROUP BY f.state_name, f.id " +
		" ORDER BY totalSales DESC NULLS LAST " +
		" LIMIT 50 ");

    //top products all category
    pstmt3 = con.prepareStatement(" SELECT c.id AS id, c.product_name AS productName, coalesce(SUM(d.price * d.quantity),0) as totalSales, f.category_name " +
		" FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id LEFT OUTER JOIN category f ON f.id = c.category_id " +
		" GROUP BY c.product_name, c.id, f.category_name " +
		" ORDER BY totalSales DESC NULLS LAST " +
		" Limit 50  ");
  }

  else if(Category != null) {
    pstmt2 = con.prepareStatement(" SELECT id FROM category c WHERE c.category_name = ? ");
    pstmt2.setString(1, Category);
       pstmt2.execute();
       con.commit();
       rs2 = null;
       rs2 = pstmt2.getResultSet();
       int temp = 0;
       if(rs2.next()) {
         temp = rs2.getInt("id");
       }
    // cell specificied category
    pstmt1 = con.prepareStatement(" with overall_table as " +
 		" (select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount " +
 		"  from products_in_cart pc " +
 		"  inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true) " +
 		"  inner join product p on (pc.product_id = p.id AND p.category_id = ? AND sc.id = pc.cart_id ) " +
 		"  inner join person c on (sc.person_id = c.id) " +
 		"  group by pc.product_id,c.state_id " +
 		"), " +
 		"top_state as " +
 		"(select state_id, sum(amount) as dollar from ( " +
 		" select state_id, amount from overall_table " +
 		" UNION ALL " +
 		" select id as state_id, 0.0 as amount from state " +
 		" ) as state_union " +
 		" group by state_id order by dollar desc limit 50  " +
 		"), " +
 		"top_n_state as " +
 		"(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state " +
 		"), " +
 		"top_prod as " +
 		"(select product_id, sum(amount) as dollar from ( " +
 		" select product_id, amount from overall_table " +
 		" ) as product_union " +
 		"group by product_id order by dollar desc limit 50  " +
 		"), " +
 		"top_n_prod as " +
 		"(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod " +
 		") " +
 		"select ts.state_id, s.state_name, tp.product_id, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum " +
 		" from top_n_prod tp CROSS JOIN top_n_state ts " +
 		" LEFT OUTER JOIN overall_table ot " +
 		" ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id) " +
 		" inner join state s ON ts.state_id = s.id " +
 		" inner join product pr ON tp.product_id = pr.id " +
 		" order by ts.state_order, tp.product_order ");

    pstmt1.setInt(1,temp);

    //get top state specify category
    pstmt2 = con.prepareStatement("  (SELECT f.id AS state_id, f.state_name AS stateName , coalesce(SUM(e.price * e.quantity),0) AS totalSales " +
                " FROM state f INNER JOIN person c ON f.id = c.state_id INNER JOIN shopping_cart d ON c.id = d.person_id " +
                " INNER JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true INNER JOIN  Category g ON g.category_name = ?" +
                " INNER JOIN product h ON h.category_id = g.id AND h.id = e.product_id " +
                " GROUP BY f.state_name, f.id " +
                " ORDER BY totalSales DESC NULLS LAST  " +
                " LIMIT 50 " +
                ") " +
                "" +
                "UNION ALL" +
                "(SELECT a.id AS state_id, a.state_name AS stateName, 0 as totalSales " +
                " FROM state a " +
                " WHERE a.id NOT IN ( " +
                "     SELECT f.id AS state_id " +
                " FROM state f INNER JOIN person c ON f.id = c.state_id INNER JOIN shopping_cart d ON c.id = d.person_id " +
                " INNER JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true INNER JOIN  Category g ON g.category_name = ? " +
                " INNER JOIN product h ON h.category_id = g.id AND h.id = e.product_id " +
                " GROUP BY f.id " +
                " LIMIT 50 " +
                "     )" +
                " ) ");

    pstmt2.setString(1, Category);
    pstmt2.setString(2, Category);



    pstmt3 = con.prepareStatement(" SELECT c.id AS id, c.product_name AS productName, coalesce(SUM(d.price * d.quantity),0) as totalSales, e.category_name AS category_name " +
" FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id JOIN category e ON e.category_name = ? AND e.id = c.category_id" +
" GROUP BY c.product_name, c.id, e.id, e.category_name " +
" Order BY totalSales DESC NULLS LAST  " +
" Limit 50 ");


    pstmt3.setString(1, Category);


  }

  //Update topstatesales precomputed table

  pstmt4 = con.prepareStatement("UPDATE topStateSales " +
        " SET totalSales = totalSales + (" +
        "  SELECT SUM(a.price * a.quantity)" +
        "    FROM newPurchases a, shopping_cart b, person c, state d" +
        "    WHERE a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id" +
        "    AND d.state_name = topStateSales.stateName" +
        ")" +
        "" +
        " WHERE topStateSales.stateName IN (" +
        "    SELECT d.state_name" +
        "    FROM newPurchases a, shopping_cart b, person c, state d" +
        "    WHERE a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id" +
        ")");


  pstmt5 =  con.prepareStatement(" UPDATE topProductSales " +
        " SET totalSales = totalSales + ( " +
        "    SELECT SUM(a.price * a.quantity) " +
        "    FROM newPurchases a " +
        "    WHERE a.product_id = topProductSales.id " +
        " )" +
        " WHERE topProductSales.ID IN ( " +
        "    SELECT b.product_ID " +
        "    FROM newPurchases b " +
        " ) ");

  pstmt6 = con.prepareStatement(" UPDATE topProduct_states " +
        " SET cell_sum = cell_sum + ( " +
        "    SELECT SUM(a.price * a.quantity) " +
        "    FROM newPurchases a, shopping_cart b, person c, state d " +
        "    WHERE  a.product_id = topProduct_states.productID AND " +
        "    a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id " +
        "    AND d.id = topProduct_states.stateID " +
        " )" +
        " WHERE topProduct_states.productID IN (" +
        "    SELECT product_id" +
        "    FROM newPurchases" +
        "    )" +
        " AND topProduct_states.stateName IN (" +
        "    SELECT d.state_name" +
        "    FROM newPurchases a, shopping_cart b, person c, state d" +
        "    WHERE a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id" +
        "    )");

  pstmt7 = con.prepareStatement(" SELECT * FROM topProductSales ORDER BY serial_id ASC ");

  pstmt8 = con.prepareStatement(" SELECT * FROM topStateSales ORDER BY serial_id ASC ");

  pstmt9 = con.prepareStatement(" SELECT * FROM topProduct_states ORDER BY serial_id ASC ");


  pstmt1.execute();
  con.commit();
  pstmt2.execute();
  con.commit();
  pstmt3.execute();
  con.commit();
  pstmt4.execute();
  con.commit();
  pstmt5.execute();
  con.commit();
  pstmt6.execute();
  con.commit();
  pstmt7.execute();
  con.commit();
  pstmt8.execute();
  con.commit();
  pstmt9.execute();
  con.commit();
  con.setAutoCommit(true);

  rs1 = pstmt1.getResultSet();
  rs2 = pstmt2.getResultSet();
  rs3 = pstmt3.getResultSet();

  rs4 = pstmt7.getResultSet();
  rs5 = pstmt8.getResultSet();
  rs6 = pstmt9.getResultSet();

  JSONArray jCellArray = new JSONArray();
  JSONArray jStateArray = new JSONArray();
  JSONArray jProductArray = new JSONArray();

  JSONArray jUpdateProductArray = new JSONArray();
  JSONArray jUpdateStateArray = new JSONArray();
  JSONArray jUpdateCellArray = new JSONArray();


  JSONArray jGlobalArray = new JSONArray();

  try {
    if(Category != null && Category.equals("All Categories")) {

      //load cell array JSON object array
      while(rs1 != null && rs1.next()) {
        JSONObject cell = new JSONObject();
        cell.put("state_id", rs1.getInt("state_id"));
        cell.put("state_name", rs1.getString("state_name"));
        cell.put("product_id", rs1.getInt("product_id"));
        cell.put("product_name", rs1.getString("product_name"));
        cell.put("cell_sum", rs1.getInt("cell_sum"));
        cell.put("state_sum", rs1.getInt("state_sum"));
        cell.put("product_sum", rs1.getInt("product_sum"));
        jCellArray.put(cell);
      }


      //load state JSON object array

      for (int i = 0; i<50 && rs2 != null && rs2.next(); i++) {
        JSONObject cell = new JSONObject();
        cell.put("state_id", rs2.getInt("state_id"));
        cell.put("statename", rs2.getString("statename"));
        cell.put("totalsales", rs2.getInt("totalsales"));
        jStateArray.put(cell);
      }


      for (int i = 0; i<50 && rs3 != null && rs3.next(); i++) {
        JSONObject cell = new JSONObject();
        cell.put("id", rs3.getInt("id"));
        cell.put("productname", rs3.getString("productname"));
        cell.put("totalsales", rs3.getString("totalsales"));
        cell.put("category_name", rs3.getString("category_name"));
        jProductArray.put(cell);
      }
    }

    //specific category
    else {
      //load cells
      while(rs1 != null && rs1.next()) {
        JSONObject cell = new JSONObject();
        cell.put("state_id", rs1.getInt("state_id"));
        cell.put("state_name", rs1.getString("state_name"));
        cell.put("product_id", rs1.getInt("product_id"));
        cell.put("product_name", rs1.getString("product_name"));
        cell.put("cell_sum", rs1.getInt("cell_sum"));
        cell.put("state_sum", rs1.getInt("state_sum"));
        cell.put("product_sum", rs1.getInt("product_sum"));
        jCellArray.put(cell);

      }

      for (int i = 0; i<50 && rs2 != null && rs2.next(); i++) {
        JSONObject cell = new JSONObject();
        cell.put("state_id", rs2.getInt("state_id"));
        cell.put("statename", rs2.getString("statename"));
        cell.put("totalsales", rs2.getInt("totalsales"));


        jStateArray.put(cell);
      }

      for (int i = 0; i<50 && rs3 != null && rs3.next(); i++) {
        JSONObject cell = new JSONObject();
        cell.put("id", rs3.getInt("id"));
        cell.put("productname", rs3.getString("productname"));
        cell.put("totalsales", rs3.getInt("totalsales"));
        cell.put("category_name", rs3.getString("category_name"));
        jProductArray.put(cell);
      }

    }

    for (int i = 0; i<50 && rs4!= null && rs4.next(); i++) {
      JSONObject cell = new JSONObject();
      cell.put("id", rs4.getInt("id"));
      cell.put("productname", rs4.getString("productname"));
      cell.put("totalsales", rs4.getInt("totalsales"));
      cell.put("category_name", rs4.getString("category_name"));
      jUpdateProductArray.put(cell);
    }

    for (int i = 0; i<50 && rs5!= null && rs5.next(); i++) {
      JSONObject cell = new JSONObject();
      cell.put("id", rs5.getInt("id"));
      cell.put("statename", rs5.getString("statename"));
      cell.put("totalsales", rs5.getInt("totalsales"));
      jUpdateStateArray.put(cell);
    }


    for (int i = 0; i<2500 && rs6!= null && rs6.next(); i++) {
      JSONObject cell = new JSONObject();
      cell.put("state_id", rs6.getInt("stateid"));
      cell.put("state_name", rs6.getString("statename"));
      cell.put("product_id", rs6.getInt("productid"));
      cell.put("product_name", rs6.getString("productname"));
      cell.put("cell_sum", rs6.getInt("cell_sum"));
      cell.put("state_sum", rs6.getInt("state_sum"));
      cell.put("product_sum", rs6.getInt("product_sum"));
      jUpdateCellArray.put(cell);
    }



    jGlobalArray.put(jProductArray);
    jGlobalArray.put(jStateArray);
    jGlobalArray.put(jCellArray);
    jGlobalArray.put(jUpdateProductArray);
    jGlobalArray.put(jUpdateStateArray);
    jGlobalArray.put(jUpdateCellArray);

    pstmt10 = con.prepareStatement(" DELETE FROM newPurchases ");
    pstmt10.execute();
    con.commit();


  }



  catch(Exception jsc) {
    jsc.printStackTrace();
  }

  response.getWriter().print(jGlobalArray);


%>
