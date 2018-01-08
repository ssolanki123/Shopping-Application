CREATE TABLE role (
	id SERIAL PRIMARY KEY,
	role_name TEXT NOT NULL UNIQUE,
	description TEXT
);

CREATE TABLE state (
	id SERIAL PRIMARY KEY,
	state_name TEXT NOT NULL,
	state_code TEXT NOT NULL UNIQUE
);

CREATE TABLE person (
	id SERIAL PRIMARY KEY,
	person_name TEXT NOT NULL UNIQUE,
	role_id INTEGER REFERENCES role (id) NOT NULL,
	state_id INTEGER REFERENCES state (id) NOT NULL,
	age INTEGER NOT NULL CHECK(age > 0),
	created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE category (
	id SERIAL PRIMARY KEY,
	category_name TEXT UNIQUE NOT NULL,
	description TEXT,
	created_by TEXT NOT NULL,
	created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC'),
	modified_by TEXT,
	modified_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE product(
	id SERIAL PRIMARY KEY,
	sku_id TEXT NOT NULL UNIQUE,
	product_name TEXT NOT NULL,
	price REAL NOT NULL CHECK(price >= 0.0),
	category_id INTEGER REFERENCES category(id) NOT NULL,
	created_by TEXT NOT NULL,
	created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC'),
	modified_by TEXT,
	modified_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE shopping_cart(
	id SERIAL PRIMARY KEY,
	person_id INTEGER REFERENCES person(id) NOT NULL,
	is_purchased BOOLEAN NOT NULL,
	purchase_info TEXT,
	created_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC'),
	purchased_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'UTC')
);

CREATE TABLE products_in_cart(
	id SERIAL PRIMARY KEY,
	cart_id INTEGER REFERENCES shopping_cart(id) NOT NULL,
	product_id INTEGER REFERENCES product(id) NOT NULL,
	price REAL NOT NULL CHECK (price >= 0.0),
	quantity INTEGER NOT NULL CHECK (quantity > 0)
);
