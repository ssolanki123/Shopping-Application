package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import ucsd.shoppingApp.models.ProductModel;
import ucsd.shoppingApp.models.ProductModelExtended;

public class ProductDAO {
	private static final String SELECT_ALL_PRODUCT_SQL = "SELECT * FROM PRODUCT";

	private static final String ADD_PRODUCT_SQL = "INSERT INTO PRODUCT "
			+ "(sku_id, product_name, price, category_id, created_by) " + "VALUES (?, ?, ?, ?, ?)";

	private static final String SELECT_PRODUCT_BY_ID = "SELECT product.*, category.category_name FROM "
			+ "product, category WHERE " + "product.category_id = category.id AND " + "product.id = ?";

	private static final String UPDATE_PRODUCT_BY_ID = "UPDATE product "
			+ "SET sku_id=?, product_name=?, price=?, category_id=?, " + "modified_by=?" + "WHERE id = ?";

	private static final String FILTER_PRODUCT = "SELECT product.*, category.category_name FROM "
			+ "product, category WHERE " + "product.category_id = category.id";

	private static final String FILTER_PRODUCT_ADMIN = "SELECT product.*, category.category_name, count(products_in_cart.product_id)"
			+ " FROM product INNER JOIN category ON(product.category_id = category.id)"
			+ " LEFT JOIN products_in_cart on (product.id = products_in_cart.product_id)";

	private static final String DELETE_PRODUCT_BY_ID = "DELETE FROM product WHERE id=?";
	private Connection con;

	public ProductDAO(Connection con) {
		this.con = con;
	}

	public int addProduct(String sku_id, String product_name, Double price, Integer category_id, String created_by)
			throws SQLException {

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int product_id = -1;
		try {
			pstmt = con.prepareStatement(ADD_PRODUCT_SQL, Statement.RETURN_GENERATED_KEYS);
			pstmt.setString(1, sku_id);
			pstmt.setString(2, product_name);
			pstmt.setDouble(3, price);
			pstmt.setInt(4, category_id);
			pstmt.setString(5, created_by);
			int done = pstmt.executeUpdate();
			con.commit();
			rs = pstmt.getGeneratedKeys();
			while (rs.next()) {
				product_id = rs.getInt(1);
			}
			return product_id;

		} catch (SQLException e) {
			e.printStackTrace();
			con.rollback();
			throw e;

		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public int updateProductById(Integer prod_id, String sku_id, String prod_name, Double price, Integer category_id,
			String modified_by) throws SQLException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			pstmt = con.prepareStatement(UPDATE_PRODUCT_BY_ID);
			pstmt.setString(1, sku_id);
			pstmt.setString(2, prod_name);
			pstmt.setDouble(3, price);
			pstmt.setInt(4, category_id);
			pstmt.setString(5, modified_by);
			pstmt.setInt(6, prod_id);
			int done = pstmt.executeUpdate();
			if (done == 1) {
				con.commit();
				return prod_id;
			} else {
				con.rollback();
				return 0;
			}
		} catch (SQLException e) {
			e.printStackTrace();
			con.rollback();
			throw e;

		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public ArrayList<ProductModel> getProductById(Integer id) throws SQLException {

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList<ProductModel> result = new ArrayList<ProductModel>();
		try {
			pstmt = con.prepareStatement(SELECT_PRODUCT_BY_ID);
			pstmt.setInt(1, id);
			rs = pstmt.executeQuery();
			// collect the result in class and send to controller.
			while (rs.next()) {
				result.add(new ProductModel(rs));
			}
			return result;
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public boolean deleteProductById(Integer id) throws SQLException {
		PreparedStatement pstmt = null;
		try {
			pstmt = con.prepareStatement(DELETE_PRODUCT_BY_ID);
			pstmt.setInt(1, id);
			int done = pstmt.executeUpdate();
			if (done == 1) {
				con.commit();
				return true;
			} else {
				con.rollback();
				return false;
			}
		} catch (SQLException e) {
			e.printStackTrace();
			con.rollback();
			throw e;
		} finally {
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public ArrayList<ProductModel> filterProduct(String product_name, Integer category_id) throws SQLException {
		StringBuilder sb = new StringBuilder(FILTER_PRODUCT);
		String prod_name_filter = " AND product.product_name LIKE ?";
		String cat_id_filter = " AND product.category_id = ?";
		sb = sb.append(prod_name_filter);
		sb = sb.append(cat_id_filter);
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList<ProductModel> result = new ArrayList<ProductModel>();
		try {
			pstmt = con.prepareStatement(sb.toString());
			pstmt.setString(1, "%" + product_name + "%");
			pstmt.setInt(2, category_id);
			rs = pstmt.executeQuery();
			// collect the result in class and send to controller.
			while (rs.next()) {
				result.add(new ProductModel(rs));
			}
			return result;
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public ArrayList<ProductModelExtended> filterProductAdmin(String product_name, Integer category_id)
			throws SQLException {
		StringBuilder sb = new StringBuilder(FILTER_PRODUCT_ADMIN);
		String prod_name_filter = " WHERE product.product_name LIKE ?";
		String cat_id_filter = " AND product.category_id = ?";
		String group_and_order = " GROUP BY product.id, category.id ORDER BY product.id";
		sb = sb.append(prod_name_filter);
		sb = sb.append(cat_id_filter);
		sb = sb.append(group_and_order);

		PreparedStatement pstmt = null;
		ResultSet rs = null;

		ArrayList<ProductModelExtended> result = new ArrayList<ProductModelExtended>();
		try {
			pstmt = con.prepareStatement(sb.toString());
			pstmt.setString(1, "%" + product_name + "%");
			pstmt.setInt(2, category_id);
			rs = pstmt.executeQuery();
			// collect the result in class and send to controller.
			while (rs.next()) {
				result.add(new ProductModelExtended(rs));
			}
			return result;
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public ArrayList<ProductModel> filterProduct(String product_name) throws SQLException {
		StringBuilder sb = new StringBuilder(FILTER_PRODUCT);
		String prod_name_filter = " AND product.product_name LIKE ?";
		sb = sb.append(prod_name_filter);

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList<ProductModel> result = new ArrayList<ProductModel>();
		try {
			pstmt = con.prepareStatement(sb.toString());
			pstmt.setString(1, "%" + product_name + "%");
			rs = pstmt.executeQuery();
			// collect the result in class and send to controller.
			while (rs.next()) {
				result.add(new ProductModel(rs));
			}
			return result;
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public ArrayList<ProductModelExtended> filterProductAdmin(String product_name) throws SQLException {
		StringBuilder sb = new StringBuilder(FILTER_PRODUCT_ADMIN);
		String prod_name_filter = " WHERE product.product_name LIKE ?";
		String group_and_order = " GROUP BY product.id, category.id ORDER BY product.id";
		sb = sb.append(prod_name_filter);
		sb = sb.append(group_and_order);

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList<ProductModelExtended> result = new ArrayList<ProductModelExtended>();
		try {
			pstmt = con.prepareStatement(sb.toString());
			pstmt.setString(1, "%" + product_name + "%");
			rs = pstmt.executeQuery();
			// collect the result in class and send to controller.
			while (rs.next()) {
				result.add(new ProductModelExtended(rs));
			}
			return result;
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public ArrayList<ProductModel> filterProduct(Integer category_id) throws SQLException {
		StringBuilder sb = new StringBuilder(FILTER_PRODUCT);
		String cat_id_filter = " AND product.category_id = ?";
		sb = sb.append(cat_id_filter);

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList<ProductModel> result = new ArrayList<ProductModel>();
		try {
			pstmt = con.prepareStatement(sb.toString());
			pstmt.setInt(1, category_id);
			rs = pstmt.executeQuery();
			// collect the result in class and send to controller.
			while (rs.next()) {
				result.add(new ProductModel(rs));
			}
			return result;
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public ArrayList<ProductModelExtended> filterProductAdmin(Integer category_id) throws SQLException {
		StringBuilder sb = new StringBuilder(FILTER_PRODUCT_ADMIN);
		String cat_id_filter = " WHERE product.category_id = ?";
		String group_and_order = " GROUP BY product.id, category.id ORDER BY product.id";
		sb = sb.append(cat_id_filter);
		sb = sb.append(group_and_order);

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList<ProductModelExtended> result = new ArrayList<ProductModelExtended>();
		try {
			pstmt = con.prepareStatement(sb.toString());
			pstmt.setInt(1, category_id);
			rs = pstmt.executeQuery();
			// collect the result in class and send to controller.
			while (rs.next()) {
				result.add(new ProductModelExtended(rs));
			}
			return result;
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}
}