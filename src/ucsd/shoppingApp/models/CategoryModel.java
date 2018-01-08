package ucsd.shoppingApp.models;

public class CategoryModel {
	private int id;
	private String categoryName;
	private String description;
	private int productCount;
	
	public CategoryModel(){
		
	}
	
	public CategoryModel(int id, String categoryName, String description) {
		this.id = id;
		this.categoryName = categoryName;
		this.description = description;
	}
	
	public CategoryModel(int id, String categoryName, String description, int productCount) {
		this.id = id;
		this.categoryName = categoryName;
		this.description = description;
		this.productCount = productCount;
	}
	
	public CategoryModel(String categoryName, String description, int productCount) {
		this.categoryName = categoryName;
		this.description = description;
		this.productCount = productCount;
	}
	
	public int getProductCount() {
		return productCount;
	}

	public void setProductCount(int productCount) {
		this.productCount = productCount;
	}

	public String getCategoryName() {
		return categoryName;
	}
	
	public void setCategoryName(String categoryName) {
		this.categoryName = categoryName;
	}
	
	public String getDescription() {
		return description;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}	
}