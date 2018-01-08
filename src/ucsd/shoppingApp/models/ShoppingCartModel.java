package ucsd.shoppingApp.models;

public class ShoppingCartModel {
	private int id;
	private String productName;
	private float price;
	private int quantity;
	public ShoppingCartModel() {
		
	}
	public String getProductName() {
		return this.productName;
	}
	public void setProductName(String pname) {
		this.productName = pname;
	}
	public float getPrice() {
		return this.price;
	}
	public void setPrice(float val) {
		this.price = val;
	}
	public int getQuantity() {
		return this.quantity;
	}
	public void setQuantity(int val) {
		this.quantity = val;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
}
