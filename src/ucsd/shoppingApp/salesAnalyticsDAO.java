package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import ucsd.shoppingApp.models.CategoryModel;
import ucsd.shoppingApp.models.ShoppingCartModel;

public class salesAnalyticsDAO {

	/*
	private static final String CUSTOMERS_ALPHABETICALLY_SQL_RANGE =
  "SELECT *
	FROM (SELECT ROW_NUMBER() OVER(ORDER BY person_name)
  NUM, * FROM PERSON)
	a WHERE NUM >= ? AND NUM <= ?";

	private static final String TOP_SPENDING_CUSTOMER_SQL_RANGE =
	"SELECT * FROM
	(
	  SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *
	  FROM (
	  SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name
	  FROM products_in_cart a, shopping_cart b, person c, state s
	  WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
	  GROUP BY c.person_name
	        )  as s ORDER BY s.TOTALS DESC
	) a
	WHERE NUM >=? ? AND NUM <= ?";

	private static final String TOP_SPENDING_STATES_SQL_RANGE =
	"SELECT * FROM
	(
	  SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *
	  FROM (
	  SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name
	  FROM products_in_cart a, shopping_cart b, person c, state s
	  WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
	  GROUP BY c.person_name
	        )  as s ORDER BY s.TOTALS DESC
	) a
	WHERE NUM >=? AND NUM <=?"

	*/

	private static final String TOP_CUSTOMERS_PRODUTS_RANGE_SQL =
	"SELECT topCustomers
	FROM (
	  SELECT * FROM
	  (
	    SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *
	    FROM (
	    SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name
	    FROM products_in_cart a, shopping_cart b, person c, state s
	    WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
	    GROUP BY c.person_name
	          )  as s ORDER BY s.TOTALS DESC
	  ) a
	  WHERE NUM >=? AND NUM <=?

	) AS topProducts, (
	  SELECT * FROM
	  (
	    SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *
	    FROM (
	    SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name
	    FROM products_in_cart a, shopping_cart b, person c, state s
	    WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
	    GROUP BY c.person_name
	          )  as s ORDER BY s.TOTALS DESC
	  ) a
	  WHERE NUM >=? AND NUM <=?

	) AS topCustomers";

  public salesAnalyticsDAO(Connection con) {
    this.con = con;
  }

  public ArrayList<String> getTopCustomerProductsinRANGE(int startcust, int endcust, int startprod, int endprod) {

		PreparedStatement ptst = null;
		ResultSet rs = null;
		ptst = con.prepareStatement(TOP_CUSTOMERS_PRODUTS_RANGE_SQL);
		rs = ptst.executeQuery();
		ArrayList<String> userNameList = new ArrayList<String>();
		while (rs.next()) {
			userNameList.add(rs.getString("person_name"));
		}
		return userNameList;
	}

}
