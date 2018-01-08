package ucsd.shoppingApp.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ucsd.shoppingApp.CategoryDAO;
import ucsd.shoppingApp.ConnectionManager;
import ucsd.shoppingApp.models.CategoryModel;

public class CategoryController extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Connection con = null;
	private CategoryModel category = null;
	
	public void destroy() {
		if (con != null) {
			try {
				con.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public CategoryController() {
		con = ConnectionManager.getConnection();
		category = new CategoryModel();
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String forward = "./category.jsp";
		String action = request.getParameter("action");
		CategoryDAO categoryDao = new CategoryDAO(con);
		try {
			if(action.equals("delete")) {
				int categoryId = Integer.parseInt(request.getParameter("id"));
				categoryDao.deleteCategory(categoryId);
	            request.setAttribute("message", "Data Delete successful");
	            request.setAttribute("error", false);
			} else if(action.equals("update")) {
				CategoryModel category = new CategoryModel(Integer.parseInt(request.getParameter("id")), request.getParameter("categoryName"), request.getParameter("description"));
				categoryDao.updateCategory(category, request.getSession().getAttribute("personName").toString());
				request.setAttribute("message", "Data Update successful");
				request.setAttribute("error", false);
			} else if(action.equals("insert")) {
				CategoryModel category = new CategoryModel(request.getParameter("categoryName"), request.getParameter("description"), 0);
				categoryDao.addCategory(category, request.getSession().getAttribute("personName").toString());
				request.setAttribute("message", "Data Insert successful");
				request.setAttribute("error", false);				
			} 
		} catch(Exception e) {
			request.setAttribute("message", e);
			request.setAttribute("error", true);	
		} finally {
			request.setAttribute("categories", categoryDao.getCategories());	
			RequestDispatcher view = request.getRequestDispatcher(forward);
			view.forward(request, response);
		}
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}