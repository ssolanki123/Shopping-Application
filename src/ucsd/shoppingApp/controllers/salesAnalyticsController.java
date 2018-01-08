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
import ucsd.shoppingApp.*;

import ucsd.shoppingApp.CategoryDAO;
import ucsd.shoppingApp.ConnectionManager;
import ucsd.shoppingApp.PersonDAO;
import ucsd.shoppingApp.ProductDAO;
import ucsd.shoppingApp.ShoppingCartDAO;
import ucsd.shoppingApp.models.CategoryModel;
import ucsd.shoppingApp.models.ProductModel;
import ucsd.shoppingApp.models.ShoppingCartModel;

public class salesAnalyticsController extends HttpServlet {

     //ArrayList<String>
    /**
     *
     */
    private static final long serialVersionUID = 1L;
    private Connection con = null;

    public salesAnalyticsController() {
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

    public ArrayList <String> getUserNameList ()
    {
        PersonDAO pQuery = new PersonDAO(con);
        ArrayList<String> userList = pQuery.getUserNameList();
        return userList;
    }

    public ArrayList <String> filterAlphabetical(ArrayList<String>)


    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      doPost(request,response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String forward = "./salesAnalytics.jsp";

        try {
            HttpSession session = request.getSession();
            String customerState = request.getParameter("curstomerstate");
            String listorder = request.getParameter("listorder");


            if(customerState.equals("Customer"))
            {

               if(listorder.equals("Alphabetical"))
               {

               }

            }


            else if(customerState.equals("State"))
            {

            }

            else
            {
                throw new Exception(e);
            }
        }

        catch(Exception e) {
            request.setAttribute("message", e);
            request.setAttribute("error", true);
        } finally {
            RequestDispatcher view = request.getRequestDispatcher(forward);
            view.forward(request, response);
        }
    }