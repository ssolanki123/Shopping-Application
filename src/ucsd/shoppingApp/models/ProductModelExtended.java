package ucsd.shoppingApp.models;

import java.sql.ResultSet;
import java.sql.SQLException;

public class ProductModelExtended extends ProductModel {
	private int product_buy_count;

	public int getProduct_buy_count() {
		return product_buy_count;
	}

	public void setProduct_buy_count(int product_buy_count) {
		this.product_buy_count = product_buy_count;
	}

	public ProductModelExtended(ResultSet rs) throws SQLException {
		super(rs);
		try {
			this.product_buy_count = rs.getInt("count");
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		}
	}

}
