package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;

public class StateDAO {
	private static final String STATES_SQL = "SELECT id, state_name FROM STATE ORDER BY state_name";
	
	public static HashMap<Integer, String> getStates(Connection con) {
		HashMap<Integer, String> states = new HashMap<Integer, String>();
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = con.createStatement();
			rs = stmt.executeQuery(STATES_SQL);
			while(rs.next()) {
				states.put(rs.getInt("id"), rs.getString("state_name"));
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs != null) {
					rs.close();
				}
				if(stmt != null) {
					stmt.close();
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		return states;
	}
}
