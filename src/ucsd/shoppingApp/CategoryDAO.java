package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import ucsd.shoppingApp.models.CategoryModel;

public class CategoryDAO {
	//private static String GET_CATEGORIES_SQL = "SELECT id, category_name, description FROM category ORDER BY modified_date DESC";
	private static String GET_CATEGORIES_SQL = "SELECT c.id, c.category_name, c.description, count(p.id) count FROM category c LEFT JOIN product p ON p.category_id = c.id "
			+ " GROUP BY c.id, c.category_name, c.description "
			+ " ORDER BY c.modified_date DESC";
	private static String ADD_CATEGORIES_SQL = "INSERT INTO category(category_name, description, created_by, modified_by) "
			+ " VALUES(?, ?, ?, ?)";
	private static String UPDATE_CATEGORIES_SQL = "UPDATE category SET category_name = ?, description = ?, modified_by = ? WHERE id = ?";
	private static String DELETE_CATEGORIES_SQL = "DELETE FROM category WHERE id = ?";
	private static String PRODUCT_EXISTS_SQL = "SELECT id FROM product WHERE category_id = ?";

	private static String GET_CATEGORIES_BY_NAME_SQL = "SELECT id,category_name, description FROM category WHERE category_name= ? ";

	private Connection con;

	public CategoryDAO(Connection con) {
		this.con = con;
	}

	public List<CategoryModel> getCategories() {
		List<CategoryModel> categories = new ArrayList<CategoryModel>();
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = con.createStatement();
			rs = stmt.executeQuery(GET_CATEGORIES_SQL);
			while (rs.next()) {
				CategoryModel c = new CategoryModel(rs.getInt("id"), rs.getString("category_name"),
						rs.getString("description"), rs.getInt("count"));
				categories.add(c);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (stmt != null) {
					stmt.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return categories;
	}

	public CategoryModel getCategoriesbyName(String category_name) {
		CategoryModel category = null;
		PreparedStatement ptst = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(GET_CATEGORIES_BY_NAME_SQL);
			ptst.setString(1, category_name);
			rs = ptst.executeQuery();
			while (rs.next()) {
				category = new CategoryModel(rs.getInt("id"), rs.getString("category_name"),
						rs.getString("description"));
				break; // should happen only once anyway.
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (ptst != null) {
					ptst.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return category;
	}

	public int addCategory(CategoryModel category, String user) throws SQLException {
		int categoryId = -1;
		PreparedStatement ptst = null;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(ADD_CATEGORIES_SQL, Statement.RETURN_GENERATED_KEYS);
			ptst.setString(1, category.getCategoryName());
			ptst.setString(2, category.getDescription());
			ptst.setString(3, user);
			ptst.setString(4, user);
			int inserted = ptst.executeUpdate();
			if (inserted != 0) {
				rs = ptst.getGeneratedKeys();
				while (rs.next()) {
					categoryId = rs.getInt(1);
				}
			}
			con.commit();
		} catch (SQLException e) {
			con.rollback();
			throw e;
		} catch (Exception e) {
			con.rollback();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (ptst != null) {
				try {
					ptst.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		return categoryId;
	}

	public void updateCategory(CategoryModel category, String user) throws SQLException {
		PreparedStatement ptst = null;
		try {
			ptst = con.prepareStatement(UPDATE_CATEGORIES_SQL);
			ptst.setString(1, category.getCategoryName());
			ptst.setString(2, category.getDescription());
			ptst.setString(3, user);
			ptst.setInt(4, category.getId());
			ptst.executeUpdate();
			con.commit();
		} catch (SQLException e) {
			con.rollback();
			throw e;
		} catch (Exception e) {
			con.rollback();
			throw e;
		} finally {
			if (ptst != null) {
				try {
					ptst.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public void deleteCategory(int categoryId) throws SQLException {
		PreparedStatement ptst = null;
		try {
			if (productExists(categoryId)) {

				SQLException e = new SQLException("Delete unsuccessful. There are products associated to the category");
				throw e;
			} else {
				ptst = con.prepareStatement(DELETE_CATEGORIES_SQL);
				ptst.setInt(1, categoryId);
				ptst.executeUpdate();
				con.commit();
			}
		} catch (SQLException e) {
			con.rollback();
			throw e;
		} catch (Exception e) {
			con.rollback();
			throw e;
		} finally {
			if (ptst != null) {
				try {
					ptst.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public boolean productExists(int categoryId) throws SQLException {
		PreparedStatement ptst = null;
		boolean productExists = false;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(PRODUCT_EXISTS_SQL);
			ptst.setInt(1, categoryId);
			rs = ptst.executeQuery();
			if (rs.next()) {
				productExists = true;
			} else {
				productExists = false;
			}
		} catch (SQLException e) {
			throw e;
		} catch (Exception e) {
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (ptst != null) {
				try {
					ptst.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		return productExists;
	}
}
