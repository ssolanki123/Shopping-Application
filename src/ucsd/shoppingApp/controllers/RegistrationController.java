package ucsd.shoppingApp.controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import ucsd.shoppingApp.*;

public class RegistrationController extends HttpServlet{
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
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		PrintWriter out = response.getWriter();
		try {
			String name = request.getParameter("username");
			String age = request.getParameter("age");
			String role = request.getParameter("role");
			String state = request.getParameter("state");
			PersonDAO personDao = new PersonDAO(con);
			if(personDao.personExists(name)) {
				RequestDispatcher rd = request.getRequestDispatcher("signup.jsp");
				out.println("<font color=red>Your sign up failed</font></br>");
				out.println("<font color=red>Username already registered. Please choose another username or go to <a href = './login.jsp'>Login Screen</a></font>");
				rd.include(request, response);
			} else {
				int rowsInserted = personDao.insertPerson(name, Integer.parseInt(age), Integer.parseInt(role), Integer.parseInt(state));
				if(rowsInserted>0) {
//					request.setAttribute("user_role", role);
					request.setAttribute("registration_message","User "+name+" successfully registered!!" );
					RequestDispatcher view = request.getRequestDispatcher("login.jsp");
					view.forward(request, response);
				}
			}
		} catch(Exception e) {
			RequestDispatcher rd = request.getRequestDispatcher("signup.jsp");
			out.println("<font color=red>Your sign up failed</font></br>");
			out.println("<font color=red>"+e.getMessage()+"</font>");
			rd.include(request, response);
		} 
	}
}
