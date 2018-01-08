package ucsd.shoppingApp.models;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class ProductModel {
	private int product_id;
	private String sku_id;
	private String product_name;
	private int category_id;
	private String category_name;
	private Timestamp created_date;
	private String created_by;
	private Double price;

	public int getProduct_id() {
		return product_id;
	}

	public void setProduct_id(int product_id) {
		this.product_id = product_id;
	}

	public String getSku_id() {
		return sku_id;
	}

	public void setSku_id(String sku_id) {
		this.sku_id = sku_id;
	}

	public String getProduct_name() {
		return product_name;
	}

	public void setProduct_name(String product_name) {
		this.product_name = product_name;
	}

	public int getCategory_id() {
		return category_id;
	}

	public void setCategory_id(int category_id) {
		this.category_id = category_id;
	}

	public String getCategory_name() {
		return category_name;
	}

	public void setCategory_name(String category_name) {
		this.category_name = category_name;
	}

	public Timestamp getCreated_date() {
		return created_date;
	}

	public void setCreated_date(Timestamp created_date) {
		this.created_date = created_date;
	}

	public String getCreated_by() {
		return created_by;
	}

	public void setCreated_by(String created_by) {
		this.created_by = created_by;
	}

	public Double getPrice() {
		return price;
	}

	public void setPrice(Double price) {
		this.price = price;
	}

	public ProductModel(ResultSet rs) throws SQLException {
		try {
			this.category_id = rs.getInt("category_id");
			this.category_name = rs.getString("category_name");
			this.created_by = rs.getString("created_by");
			this.created_date = rs.getTimestamp("created_date");
			this.product_id = rs.getInt("id");
			this.product_name = rs.getString("product_name");
			this.sku_id = rs.getString("sku_id");
			this.price = rs.getDouble("price");
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		}
	}

}
