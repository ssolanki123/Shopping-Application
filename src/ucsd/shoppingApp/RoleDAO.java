package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;

public class RoleDAO {
	private static final String ROLES_SQL = "SELECT ID, ROLE_NAME FROM ROLE";
	
	public static HashMap<Integer, String> getRoles(Connection con) {
		HashMap<Integer, String> roles = new HashMap<Integer, String>();
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = con.createStatement();
			rs = stmt.executeQuery(ROLES_SQL);
			while(rs.next()) {
				roles.put(rs.getInt("id"), rs.getString("role_name"));
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
		return roles;
	}
}
