package ucsd.shoppingApp.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ucsd.shoppingApp.CategoryDAO;
import ucsd.shoppingApp.ConnectionManager;
import ucsd.shoppingApp.ProductDAO;
import ucsd.shoppingApp.models.CategoryModel;
import ucsd.shoppingApp.models.ProductModel;

/**
 * Servlet implementation class ProductSearchResultsController
 */
@WebServlet("/ProductSearchResultsController")
public class ProductSearchResultsController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Connection con = null;
	private ProductDAO productDAO = null;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ProductSearchResultsController() {
		super();
		// TODO Auto-generated constructor stub
	}

	public void init() {
		con = ConnectionManager.getConnection();
		productDAO = new ProductDAO(con);
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
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */

	private ArrayList<ProductModel> FilterProduct(int category_id, String productname) throws SQLException {
		ArrayList<ProductModel> products = new ArrayList<ProductModel>();
		if (category_id == -1 && productname != "") {

			products = productDAO.filterProduct(productname);
		} else if (category_id != -1 && (productname == null || productname == "")) {
			products = productDAO.filterProduct(category_id);
		} else if (category_id != -1 && productname != null && productname != "") {

			products = productDAO.filterProduct(productname, category_id);
		} else if (category_id == -1) {
			products = productDAO.filterProduct("");
		}
		return products;
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		String productname = request.getParameter("browseproductname");
		String categoryname = request.getParameter("browsecategory");
		boolean zeroresults = false; // no results found (different message)
		boolean emptysearch = false; // if an empty search was tried, page
										// should refresh

		PreparedStatement ptst = null;
		ResultSet rst = null;

		ArrayList<ProductModel> products = new ArrayList<ProductModel>();
		try {
			HttpSession session = request.getSession();

			if (categoryname.equals("") && productname.equals("")) {
				emptysearch = true;
			} else {
				int category_id = -1;
				if (!categoryname.equals("") && !categoryname.equals("All products")) {

					CategoryDAO cddao = new CategoryDAO(con);

					CategoryModel cd = cddao.getCategoriesbyName(categoryname);
					// should return only one result
					category_id = cd.getId();
				}

				products = this.FilterProduct(category_id, productname);

				if (products.size() == 0) {
					zeroresults = true;
				}

			}
			if (emptysearch == false && zeroresults == false) {
				request.setAttribute("pres", 1);
			}
			if (zeroresults == true) {
				request.setAttribute("zeroresults", 1);
			}
			request.setAttribute("productname", productname);
			request.setAttribute("products", products);
			RequestDispatcher rd = request.getRequestDispatcher("productsearch.jsp");
			rd.forward(request, response);
		} catch (

		Exception e) {

			System.out.println(e.getMessage());
		} finally {
			try {
				if (rst != null)
					rst.close();

				if (ptst != null)
					ptst.close();
			} catch (Exception e) {
				System.out.println(e.getMessage());
			}

		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
