package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import ucsd.shoppingApp.models.CategoryModel;
import ucsd.shoppingApp.models.ShoppingCartModel;

public class PersonDAO {

	private static final String PERSON_EXISTS_SQL = "SELECT ID FROM PERSON WHERE PERSON_NAME = ?";
	private static final String INSERT_PERSON_SQL = "INSERT INTO PERSON(person_name, age, role_id, state_id) "
			+ " VALUES(?, ?, ?, ?) ";
	private static final String GET_PERSON_ROLE = "SELECT role_name FROM ROLE R, PERSON P WHERE P.person_name = ? AND P.role_id = R.id";
	public static final String GET_ALL_USERS_Alphabetical = "SELECT * FROM person p ORDER BY ASC";
	public static final String GET_ALL_USERS = "SELECT * FROM person";
	public static final String GET_ALL_STATES = "SELECT"
	private Connection con = null;

	public PersonDAO(Connection con) {
		this.con = con;
	}

	public boolean personExists(String username) {
		boolean isExists = false;
		PreparedStatement ptst = null;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(PERSON_EXISTS_SQL);
			ptst.setString(1, username);
			rs = ptst.executeQuery();
			if(rs.next()) {
				isExists = true;
			} else {
				isExists = false;
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs != null) {
					rs.close();
				}
				if(ptst != null) {
					ptst.close();
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		return isExists;
	}

	public int insertPerson(String username, int age, int role_id, int state_id) throws Exception {
		int rows = 0;
		PreparedStatement ptst = null;
		try {
			ptst = con.prepareStatement(INSERT_PERSON_SQL);
			ptst.setString(1, username);
			ptst.setInt(2, age);
			ptst.setInt(3, role_id);
			ptst.setInt(4, state_id);
			rows = ptst.executeUpdate();
			con.commit();
		} catch(Exception e) {
			con.rollback();
			throw e;
		} finally {
			try {
				if(ptst != null) {
					ptst.close();
				}
			} catch(Exception e) {
				throw e;
			}
		}
		return rows;
	}

	public ArrayList<String> getUserNameList()
	{

		PreparedStatement ptst = null;
		ResultSet rs = null;
		ptst = con.prepareStatement(GET_ALL_USERS);
		rs = ptst.executeQuery();
		ArrayList <String> userNameList = new ArrayList<String>();
		while(rs.next())
		{
			userNameList.add(rs.getString("person_name"));
		}

		return userNameList;
	}

	public ArrayList<String> getUserNameListAlphabetical() {

		PreparedStatement ptst = null;
		ResultSet rs = null;
		ptst = con.prepareStatement(GET_ALL_USERS_Alphabetical);
		rs = ptst.executeQuery();
		ArrayList<String> userNameList = new ArrayList<String>();
		while (rs.next()) {
			userNameList.add(rs.getString("person_name"));
		}

		return userNameList;
	}


	public String getPersonRole(String username) {
		String role = null;
		PreparedStatement ptst = null;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(GET_PERSON_ROLE);
			ptst.setString(1, username);
			rs = ptst.executeQuery();
			if(rs.next()) {
				role = rs.getString(1);
			}
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		finally {
			try {
				if(rs != null) {
					rs.close();
				}
				if(ptst != null) {
					ptst.close();
				}
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}
		return role;
	}

	public int getIdfromName(String username) {
		int id = -1;
		PreparedStatement ptst = null;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(PERSON_EXISTS_SQL);
			ptst.setString(1, username);
			rs = ptst.executeQuery();
			if(rs.next()) {
				id = rs.getInt(1);
			} else {
				id = -1;
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs != null) {
					rs.close();
				}
				if(ptst != null) {
					ptst.close();
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		return id;
	}
}

String x = "with overall_table as " +
		"(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount " +
		"  from products_in_cart pc " +
		"  inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true) " +
		"  inner join product p on (pc.product_id = p.id) -- add category filter if any " +
		"  inner join person c on (sc.person_id = c.id) " +
		"  group by pc.product_id,c.state_id " +
		"), " +
		"top_state as " +
		"(select state_id, sum(amount) as dollar from ( " +
		" select state_id, amount from overall_table " +
		" UNION ALL " +
		" select id as state_id, 0.0 as amount from state " +
		" ) as state_union " +
		" group by state_id order by dollar desc limit 50  --offset 20 " +
		"), " +
		"top_n_state as " +
		"(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state " +
		"), " +
		"top_prod as " +
		"(select product_id, sum(amount) as dollar from ( " +
		" select product_id, amount from overall_table " +
		" UNION ALL " +
		" select id as product_id, 0.0 as amount from product " +
		" ) as product_union " +
		"group by product_id order by dollar desc limit 50 --offset 20 " +
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
		" order by ts.state_order, tp.product_order";