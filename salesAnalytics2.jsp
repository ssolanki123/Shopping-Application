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
                <button id = "topRight" onClick = "update_table()" >Refresh</button>
                <p>
                    Changed Products
                </p>

                <ul id = "changedProducts">

                </ul>
                <%
                String Category = ((String) session.getAttribute("category"));
                Connection con = ConnectionManager.getConnection();
                Connection con2 = ConnectionManager.getConnection();
                CategoryDAO categoryDao = new CategoryDAO(con);
                ResultSet rs1 =  null;
                PreparedStatement pstmt1 = null;
                PreparedStatement pstmt2 = null;
                ResultSet rs2 = null;
                ResultSet rs3 = null;

                %>
                <%= session.getAttribute("category")%>
                <%


                //check if sesssion category selection attribute is null
                if(Category==null) {
                    session.setAttribute("category", "All Categories");
                    Category = "All Categories";
                }

                //update session categoryselection if user hit submit button
                if(Category!= null && request.getParameter("action") != null &&((request.getParameter("action")).equals("dropdown"))) {

                    String s = request.getParameter("salesFiltering");
                    if(s != null)  {
                        session.setAttribute("category", s);
                        Category = s;
                    }

                    else   {
                        session.setAttribute("category", "All Categories");
                        Category = "All Categories";
                    }
                }



                /*
                INSERT INTO topProductSales (
                SELECT c.id AS id, c.product_name AS productName, coalesce(SUM(d.price * d.quantity),0) as totalSales, f.category_name
                FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id LEFT OUTER JOIN category f ON f.id = c.category_id
                GROUP BY c.product_name, c.id, f.category_name
                ORDER BY totalSales DESC NULLS LAST
                Limit 50
                )
                */

                con.setAutoCommit(false);
                pstmt1 = con.prepareStatement(" DELETE FROM topProductSales ");
                pstmt1.execute();
                con.commit();

                /*pstmt1 = con.prepareStatement( " CREATE TABLE topProductSales  " +
                " ID INTEGER NOT NULL UNIQUE, " +
                " productName TEXT NOT NULL, " +
                " totalSales INTEGER DEFAULT 0, " +
                " category_name TEXT NOT NULL ");
                con.commit();*/

                if(Category.equals("All Categories") && Category!= null) {

                    pstmt1 = con.prepareStatement(" INSERT INTO topProductSales (SELECT c.id AS id, c.product_name AS productName, coalesce(SUM(d.price * d.quantity),0) as totalSales, f.category_name " +
                    " FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id LEFT OUTER JOIN category f ON f.id = c.category_id " +
                    " GROUP BY c.product_name, c.id, f.category_name " +
                    " ORDER BY totalSales DESC NULLS LAST " +
                    " Limit 50 ) ");

                }


                else if(Category!= null) {

                    pstmt1 = con.prepareStatement(" INSERT INTO topProductSales ( SELECT c.id AS id, c.product_name AS productName, coalesce(SUM(d.price * d.quantity),0) as totalSales, e.category_name AS category_name " +
                    " FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id JOIN category e ON e.category_name = ? AND e.id = c.category_id" +
                    " GROUP BY c.product_name, c.id, e.id, e.category_name " +
                    " Order BY totalSales DESC NULLS LAST  " +
                    " Limit 50) ");
                    pstmt1.setString(1, Category);

                    %>
                    <%=Category%>

                    <%
                }

                pstmt1.execute();
                con.commit();

                pstmt1 = con.prepareStatement(" SELECT * FROM topProductSales ");
                pstmt1.execute();
                con.setAutoCommit(true);

                rs1 = pstmt1.getResultSet();

                /**********************************************************************************/


                con.setAutoCommit(false);
                pstmt1 = con.prepareStatement(" DELETE FROM topStateSales ");
                pstmt1.execute();
                con.commit();
                pstmt1 = con.prepareStatement(" DELETE FROM topProduct_states ");
                pstmt1.execute();
                con.commit();
                /*pstmt1 = con.prepareStatement( " CREATE TABLE topProductSales  " +
                " ID INTEGER NOT NULL UNIQUE, " +
                " productName TEXT NOT NULL, " +
                " totalSales INTEGER DEFAULT 0, " +
                " category_name TEXT NOT NULL ");
                con.commit();*/

                if(Category.equals("All Categories") && Category!= null) {
                    %>
                    HERE at all categories
                    <%

                    pstmt1 = con.prepareStatement(" INSERT INTO topStateSales( SELECT f.id AS state_id, f.state_name AS stateName, coalesce(SUM(e.price * e.quantity),0) as totalSales " +
                    " FROM state f LEFT OUTER JOIN person c ON f.id = c.state_id LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id " +
                    " LEFT OUTER JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true " +
                    " GROUP BY f.state_name, f.id " +
                    " ORDER BY totalSales DESC NULLS LAST " +
                    " LIMIT 50 )");
                    pstmt1.execute();
                    con.commit();

                    pstmt2 = con.prepareStatement(" INSERT INTO topProduct_states ( with overall_table as " +
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
                    " order by ts.state_order, tp.product_order )");

                    pstmt2.execute();
                    con.commit();


                }

                else if(Category!= null) {
                    %>
                    HERE at not all categories
                    <%

                    pstmt1 = con.prepareStatement(" INSERT INTO topStateSales( (SELECT f.id AS state_id, f.state_name AS stateName , coalesce(SUM(e.price * e.quantity),0) AS totalSales " +
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
                    " ) )");

                    pstmt1.setString(1, Category);
                    pstmt1.setString(2, Category);
                    pstmt1.execute();
                    con.commit();

                    pstmt2 = con.prepareStatement(" SELECT id FROM category c WHERE c.category_name = ? ");
                    pstmt2.setString(1, Category);
                    pstmt2.execute();
                    con.commit();
                    rs3 = pstmt2.getResultSet();
                    int temp = 0;
                    if(rs3.next()) {
                        temp = rs3.getInt("id");
                    }

                    pstmt2 = con.prepareStatement(" INSERT INTO topProduct_states ( with overall_table as " +
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
                    " order by ts.state_order, tp.product_order ) ");

                    pstmt2.setInt(1, temp);

                    pstmt2.execute();
                    con.commit();



                    %>
                    <%=Category%>

                    <%

                } //end if else



                pstmt1 = con.prepareStatement(" SELECT * FROM topStateSales ");
                pstmt1.execute();


                rs2 = pstmt1.getResultSet();

                pstmt1 = con. prepareStatement(" SELECT * FROM topProduct_states ");
                pstmt1.execute();
                rs3 = pstmt1.getResultSet();

                con.setAutoCommit(true);


                List<CategoryModel> categories = categoryDao.getCategories();

                %>
                <form name = "filterResult" action = "salesAnalytics2.jsp" method = "POST">
                    <input type = "hidden" name = "action" value  = "dropdown"/>

                    <select name="salesFiltering">


                        <option value = "All Categories">All Categories</option>
                        <%
                        for (CategoryModel category : categories) {
                            %>
                            <option value=<%=category.getCategoryName()%>><%=category.getCategoryName()%></option>
                            <%
                        }
                        %>

                        <input type = "submit" value = "search"  />
                    </select>
                </form>

                <table border = "1" >
                    <tr>
                        <th> State </th>
                        <th> Top 50 </th>
                    </tr>
                    <%
                    con = ConnectionManager.getConnection();


                    // GET TOP PRODUCTS ALL FROM ALL CATEGORIES
                    if(Category != null && (Category.equals("All Categories"))) {
                        pstmt1 = null;
                        rs1 = null;
                        con.setAutoCommit(false);
                        pstmt1 = con.prepareStatement("SELECT * FROM topProductSales");

                        pstmt1.execute();
                        rs1 = pstmt1.getResultSet();
                        con.commit();
                        con.setAutoCommit(true);
                    }

                    //GET TOP PRODUCTS FROM SELECTED CATEGORIES
                    else if(Category != null && !(Category.equals("All Categories"))) {
                        con.setAutoCommit(false);
                        pstmt1 = con.prepareStatement("SELECT * FROM topProductSales s WHERE s.category_name = ?");

                        try {
                            pstmt1.setString(1,Category);
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        pstmt1.execute();
                        rs1 = pstmt1.getResultSet();
                        con.setAutoCommit(true);
                    }
                    %>
                    <tr>
                        <td>****</td>
                        <%
                        int productCount = 0;
                        while(rs1!= null && rs1.next()) {
                            %>
                            <td id = "product_<%=productCount%>">
                            <b id = "productName_<%=productCount%>"><%= rs1.getString("productName")%></b>

                            <b id = "product_count_<%=productCount%>"><%=rs1.getString("totalSales")%> </b>
                        </td>
                        <%
                        productCount++;
                    }
                    %>
                </tr>

                <%
                boolean x = false;
                int value = 0;
                int state_counter = 0;
                int count = 0;

                int cell_id_counter = 0;
                int cell_class_counter = 0;
                //output cells

                while(state_counter < 50 && rs2!= null && rs2.next()) { %>
                <tr>
                    <td >
                        <%= rs2.getString("stateName")%>
                        <div id = "state_id_<%= state_counter%>">
                            <%= rs2.getInt("totalSales")%>
                        </div>
                    </td>
                <%

                while(count < productCount) {
                    if(cell_class_counter == 50) {
                        cell_class_counter = 0;
                    }
                    if(rs3.next()) {
                        %> <td id = "cell_<%=cell_id_counter%>" class = "column_<%=cell_class_counter%>"> <%= rs3.getInt("cell_sum")%></td>
                        <%}

                        cell_id_counter++;
                        cell_class_counter++;
                        count++;
                    }
                    count = 0;
                    state_counter++;
                }
                %>
            </tr>
        </table>
    </body>

    <script type="text/javascript">

    function update_table() {
        console.log("enter func");``
        var xmlHttp;
        xmlHttp=new XMLHttpRequest();

        var responseHandler = function() {
            if(xmlHttp.readyState==4) {
                if (xmlHttp.status === 200) {
                    var data = JSON.parse(xmlHttp.responseText);
                    console.log(data);
                    compare_cells(data);
                }
            }
        }

        xmlHttp.onreadystatechange = responseHandler ;
        <% Category = (String)session.getAttribute("category"); %>
        xmlHttp.open("POST","Update.jsp",true);
        xmlHttp.send(null);
    }
    //1st, products
    //2nd states
    //3rd cells
		//4th updated products
		//5th updated states
		//6th updated cells
    function compare_cells(data) {

        var test1 =Number(data[2][0]["cell_sum"])
        var test2 = Number(document.getElementById("cell_" + 0).innerHTML);
        console.log(test1);
        console.log(test2);

        if (test1 == test2) {
          console.log("equal");
        }

		for(var x = 0; x<data[3].length; x ++) {
			document.getElementById("product_count_" + x).innerHTML = data[3][x]["totalsales"];
		}
        for(var y = 0; y<data[4].length; y++) {
			document.getElementById("state_id_" + y).innerHTML = data[4][y]["totalsales"];
		}
        for(var  z = 0; z <data[5].length; z++) {
			document.getElementById("cell_" + z).innerHTML = data[5][z]["cell_sum"];
		}


        var oldProductList = [];
        var newProductList = [];
        var noLongerInTop50 = [];



        for(var i = 0; i<data[0].length; i++) {
            //see if product name is not in same position
            if(data[0][i]["productname"] != (document.getElementById("productName_" + i).innerHTML)) {
                newProductList.push(data[0][i]["productname"]);
                oldProductList.push(document.getElementById("productName_" + i).innerHTML);

                //see if product is not in top 50 anymore, if not, add to list
                var found = false;
                for(var x = 0; x<data[0].length; x++) {
                    if(data[0][i]["productname"] == (document.getElementById("productName_" + i)).innerHTML) {
                        found = true;
                    }
                }
                //if not found in products anymore add to top 50 list
                if(!found) {
                    document.getElementById("product_" + i).style.color='purple';
                    var makepurple = document.getElementsByClassName("column_" + i);
                    for (let p = 0; p<makepurple.length; p ++) {
                        makepurple[p].style.color = 'purple';
                    }
                    noLongerInTop50.push(data[0][i]["productname"]);
                }
            } //end check if product names are in the same position

        }

        for(var j = 0; j<data[2].length; j++ ) {
            //check the cells, and color red if they are no longer  in the same position
            if(Number(data[2][j]["cell_sum"]) != Number(document.getElementById("cell_" + j).innerHTML)) {
                document.getElementById("cell_" + j).style.color ='red';
            }

            document.getElementById("cell_" + j).innerHTML = Number(data[2][j]["cell_sum"]);
        }
        //noLongerInTop50 = [];


        for(let n = 0; n<newProductList.length ; n++) {
            let found = false;
            for(let m = 0; n<oldProductList.length; m++) {
                if(found) {
                    break;
                }
                else {
                    if(newProductList[n] == oldProductList[m]) {
                        found = true;
                    }
                }
            }
            if(found == false) {
                noLongerInTop50.push(newProductList[n]);

            }

        }
        var ul = document.getElementById("changedProducts");
        while(ul.firstChild)
        {
            ul.removeChild(ul.firstChild);
        }
        console.log(noLongerInTop50.length)
        for(let n = 0; n<noLongerInTop50.length; n++) {
            console.log(noLongerInTop50[n]);
            var li = document.createElement("li");
            li.appendChild(document.createTextNode(noLongerInTop50[n]));
            ul.appendChild(li);


        }


    }
    </script>
</html>
