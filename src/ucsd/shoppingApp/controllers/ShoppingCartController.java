package ucsd.shoppingApp.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ucsd.shoppingApp.CategoryDAO;
import ucsd.shoppingApp.ConnectionManager;
import ucsd.shoppingApp.PersonDAO;
import ucsd.shoppingApp.ProductDAO;
import ucsd.shoppingApp.ShoppingCartDAO;
import ucsd.shoppingApp.models.CategoryModel;
import ucsd.shoppingApp.models.ProductModel;
import ucsd.shoppingApp.models.ShoppingCartModel;

public class ShoppingCartController extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Connection con = null;
	
	public ShoppingCartController() {
		con = ConnectionManager.getConnection();
	}
	
	public void destroy() {
		if (con != null) {
			try {
				con.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String forward = "./productOrder.jsp";
		ShoppingCartDAO shoppingcartDao = new ShoppingCartDAO(con);
		ProductDAO productDao = new ProductDAO(con);
		try {
			HttpSession session = request.getSession();
			ArrayList<ProductModel> result = productDao.getProductById(Integer.parseInt(request.getParameter("pid")));
	        request.setAttribute("shoppingCart", shoppingcartDao.getPersonCart(session.getAttribute( "personName" ).toString()));
	        request.setAttribute("pname", result.get(0).getProduct_name());
	        request.setAttribute("pid", result.get(0).getProduct_id());
	        request.setAttribute("pprice", result.get(0).getPrice());
		} catch(Exception e) {
			request.setAttribute("message", e);
			request.setAttribute("error", true);	
		} finally {
			RequestDispatcher view = request.getRequestDispatcher(forward);
			view.forward(request, response);
		}
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//doGet(request, response);
		String forward = "./productsearch.jsp";
		try {
			HttpSession session = request.getSession();
			ProductDAO productDao = new ProductDAO(con);
			PersonDAO personDao = new PersonDAO(con);
			ShoppingCartDAO shoppingcartDao = new ShoppingCartDAO(con);
			String username = session.getAttribute("personName").toString();
			int productid = Integer.parseInt(request.getParameter("pid"));
			int quantity = Integer.parseInt(request.getParameter("quantity"));
			int cart_id = -1;
			int pc_id = -1;
			float price = Float.parseFloat(request.getParameter("pprice"));
			// get id of person
			int person_id = personDao.getIdfromName(username);
			// check if cart exists for person
			ArrayList<ShoppingCartModel> result = (ArrayList<ShoppingCartModel>) shoppingcartDao.getPersonCart(username);
			if(result.isEmpty()) {
				// create cart
				cart_id = shoppingcartDao.insertCart(person_id);
			}
			else {
				// get its id
				cart_id = shoppingcartDao.getCartId(person_id);
			}
			// add product to cart
			pc_id = shoppingcartDao.addProductToCart(cart_id,productid,quantity,price);
		} catch(Exception e) {
			request.setAttribute("message", e);
			request.setAttribute("error", true);
		} finally {
			RequestDispatcher view = request.getRequestDispatcher(forward);
			view.forward(request, response);
		}
	}
}