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

import ucsd.shoppingApp.ConnectionManager;
import ucsd.shoppingApp.ShoppingCartDAO;
import ucsd.shoppingApp.models.ShoppingCartModel;

public class BuyController extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Connection con = null;
	
	public BuyController() {
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
		String forward = "./buyPage.jsp";
		ShoppingCartDAO shoppingcartDao = new ShoppingCartDAO(con);
		try {
			HttpSession session = request.getSession();
			request.setAttribute("shoppingCart", shoppingcartDao.getPersonCart(session.getAttribute( "personName" ).toString()));
		} catch(Exception e) {
			request.setAttribute("message", e);
			request.setAttribute("error", true);	
		} finally {
			RequestDispatcher view = request.getRequestDispatcher(forward);
			view.forward(request, response);
		}
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// doGet(request, response);
		String forward = "./confirmation.jsp"; // to be written
		ShoppingCartDAO shoppingcartDao = new ShoppingCartDAO(con);
		try {
			HttpSession session = request.getSession();
			ArrayList<ShoppingCartModel> sc = (ArrayList<ShoppingCartModel>) shoppingcartDao.getPersonCart(session.getAttribute( "personName" ).toString());
			request.setAttribute("shoppingCart", sc);
			int done = shoppingcartDao.buyPersonCart(session.getAttribute( "personName" ).toString());
		} 
		catch(Exception e) {
			request.setAttribute("message", e);
			request.setAttribute("error", true);
		} 
		finally {
			RequestDispatcher view = request.getRequestDispatcher(forward);
			view.forward(request, response);
		}
	}
}