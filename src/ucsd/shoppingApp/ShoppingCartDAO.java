package ucsd.shoppingApp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import ucsd.shoppingApp.models.CategoryModel;
import ucsd.shoppingApp.models.ProductModel;
import ucsd.shoppingApp.models.ShoppingCartModel;

public class ShoppingCartDAO {
	private static final String GET_PERSON_CART = "SELECT P.*, C.quantity, G.category_name FROM SHOPPING_CART S,"
			+ "PRODUCTS_IN_CART C, PRODUCT P, PERSON U, CATEGORY G where U.person_name = ? and S.person_id = U.id and S.id = C.cart_id and C.product_id = P.id and S.is_purchased=false and G.id = p.category_id";
	private static final String CREATE_CART_SQL = "INSERT INTO SHOPPING_CART(person_id, is_purchased) "
			+ " VALUES(?, false) ";
	private static final String GET_CART_ID = "SELECT id FROM shopping_cart WHERE person_id = ?";
	private static final String INSERT_PRODUCT_CART_SQL = "INSERT INTO PRODUCTS_IN_CART(cart_id, product_id, quantity, price) "
			+ " VALUES(?, ?, ?, ?) ";
	private static final String BUY_CART_SQL = "UPDATE shopping_cart SET is_purchased = true FROM shopping_cart S, person P "
			+ "WHERE S.person_id = P.id and P.person_name = ?";
	private Connection con;
	
	public ShoppingCartDAO(Connection con) {
		this.con = con;
	}
	
	public List<ShoppingCartModel> getPersonCart(String username) {
		List<ShoppingCartModel> shoppingCart = new ArrayList<ShoppingCartModel>();
		PreparedStatement ptst = null;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(GET_PERSON_CART);
			ptst.setString(1, username);
			rs = ptst.executeQuery();
			while(rs.next()) {
				ShoppingCartModel sc = new ShoppingCartModel();
				sc.setProductName(rs.getString("product_name"));
				sc.setPrice(rs.getFloat("price"));
				sc.setQuantity(rs.getInt("quantity"));
				shoppingCart.add(sc);
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
		return shoppingCart;
	}
	
	public int insertCart(int personid) {
		ResultSet rs = null;
		PreparedStatement ptst = null;
		int cart_id = -1;
		try {
			ptst = con.prepareStatement(CREATE_CART_SQL, Statement.RETURN_GENERATED_KEYS);
			ptst.setInt(1, personid);
			ptst.executeUpdate();
			con.commit();
			rs = ptst.getGeneratedKeys();
			while (rs.next()) {
				cart_id = rs.getInt(1);
			}
			return cart_id;
		} catch(Exception e) {
			e.printStackTrace();
			try {
				con.rollback();
			} catch (SQLException e1) {
				e1.printStackTrace();
			}
		} finally {
			try {
				if(ptst != null) {
					ptst.close();
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		return cart_id;
	}
	
	public int addProductToCart(int cartid, int productid, int quantity, float price) {
		ResultSet rs = null;
		PreparedStatement ptst = null;
		int pc_id = -1;
		try {
			ptst = con.prepareStatement(INSERT_PRODUCT_CART_SQL, Statement.RETURN_GENERATED_KEYS);
			ptst.setInt(1, cartid);
			ptst.setInt(2, productid);
			ptst.setInt(3, quantity);
			ptst.setFloat(4, price);
			ptst.executeUpdate();
			con.commit();
			rs = ptst.getGeneratedKeys();
			while (rs.next()) {
				pc_id = rs.getInt(1);
			}
			return pc_id;
		} catch(Exception e) {
			e.printStackTrace();
			try {
				con.rollback();
			} catch (SQLException e1) {
				e1.printStackTrace();
			}
		} finally {
			try {
				if(ptst != null) {
					ptst.close();
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		return pc_id;
	}
	
	public int getCartId(int personid) {
		int cart_id = -1;
		PreparedStatement ptst = null;
		ResultSet rs = null;
		try {
			ptst = con.prepareStatement(GET_CART_ID);
			ptst.setInt(1, personid);
			rs = ptst.executeQuery();
			while(rs.next()) {
				cart_id = rs.getInt("id");
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
		return cart_id;
	}
	
	public int buyPersonCart(String username) {
		PreparedStatement ptst = null;
		int done = -1;
		try {
			ptst = con.prepareStatement(BUY_CART_SQL);
			ptst.setString(1, username);
			ptst.executeUpdate();
			con.commit();
		} catch(Exception e) {
			e.printStackTrace();
			try {
				con.rollback();
			} catch (SQLException e1) {
				e1.printStackTrace();
			}
		} finally {
			try {
				if(ptst != null) {
					ptst.close();
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		return done;
	}
}
