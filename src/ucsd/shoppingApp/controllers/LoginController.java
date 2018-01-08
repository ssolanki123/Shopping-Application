package ucsd.shoppingApp.controllers;

import java.io.*;
import java.sql.*;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ucsd.shoppingApp.ConnectionManager;
import ucsd.shoppingApp.PersonDAO;
import ucsd.shoppingApp.ProductDAO;

/**
 * Servlet implementation class loginController
 */

public class LoginController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Connection con = null;
	
	public void init() {
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

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String uname=request.getParameter("username");
		PrintWriter out = response.getWriter();
		try {
			HttpSession session = request.getSession();
			session.setAttribute("personName", uname);
			PersonDAO personDao = new PersonDAO(con);
			if(personDao.personExists(uname)) {
				session.setAttribute("roleName", personDao.getPersonRole(uname));
		        //session.setAttribute("validUser", "Yes");
		        response.sendRedirect("home.jsp");
			}
			else {
				//session.setAttribute("validUser", "No");
		        //response.sendRedirect("login.jsp");
				RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
				out.println("<font color=red>The provided name " + session.getAttribute( "personName" ) + " is not known</font>");
				rd.include(request, response);
			}
		}
		catch (Exception e2) {
			System.out.println(e2);
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
