//Top 20 products in each state sorted by highest sales
SELECT a.id, (a.price * a.quantity) as totalSales, s.state_name
FROM products_in_cart a, shopping_cart b, person c, state s
WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
GROUP BY s.state_name,a.id
ORDER BY (a.price * a.quantity) DESC

//get top selling products overall
SELECT a.id, (a.price * a.quantity) as totalSales
FROM products_in_cart a, shopping_cart b
WHERE a.cart_id = b.id AND b.is_purchased = true
GROUP BY a.id
ORDER BY (a.price * a.quantity) DESC


SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER BY (totalSales) DESC ) NUM, * FROM (
    SELECT a.id, (a.price * a.quantity) as totalSales, s.state_name
    FROM products_in_cart a, shopping_cart b, person c, state s
    WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
    GROUP BY s.state_name,a.id
    ORDER BY (a.price * a.quantity) DESC
  ) a
) as s
WHERE NUM > 0 AND NUM < 19


//Top 20 states by total sales
SELECT SUM(a.price * a.quantity) AS TOTALS, s.state_name
FROM products_in_cart a, shopping_cart b, person c, state s
WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
GROUP BY s.state_name
ORDER BY TOTALS DESC
LIMIT 20

//Top 20 customers by purchases
SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name
FROM products_in_cart a, shopping_cart b, person c, state s
WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
GROUP BY c.person_name
ORDER BY TOTALS DESC
LIMIT 20

//Order customers alphabetically
SELECT c.person_name
FROM person c
Order By substring(c.person_name, '^[0-9]+')::int, substring(c.person_name, '[^0-9]*$')
Limit 20

//Order states Alphabetically
SELECT s.state_name
FROM state s
ORDER BY s.state_name ASC
Limit 20

//Order products Alphabetically for ALL CATEGORIES
SELECT p.product_name
FROM product p
Order By substring(p.product_name, '^[0-9]+')::int, substring(p.product_name, '[^0-9]*$')
Limit 10



//sort by top spending customer by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *
  FROM (
    SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name
    FROM products_in_cart a, shopping_cart b, person c, state s
    WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
    GROUP BY c.person_name
  )  as s ORDER BY s.TOTALS DESC
) a
WHERE NUM >=0 AND NUM <=20



//select by top total spending states by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, * FROM (
    SELECT SUM(a.price * a.quantity) AS TOTALS, s.state_name
    FROM products_in_cart a, shopping_cart b, person c, state s
    WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
    GROUP BY s.state_name
    ORDER BY TOTALS DESC
  ) as s
) a
WHERE NUM > 0 AND NUM < 19


//select by top selling products in each state by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER BY (totalSales) DESC ) NUM, * FROM (
    SELECT a.id, (a.price * a.quantity) as totalSales, s.state_name
    FROM products_in_cart a, shopping_cart b, person c, state s
    WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
    GROUP BY s.state_name,a.id
    ORDER BY (a.price * a.quantity) DESC

  ) as s
) a
WHERE NUM > 0 AND NUM < 19
-----------------------------------------------------------------------------
--------------------------------------------------------------------------------
Solutions:

//get top customers
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER BY s.TOTALS DESC) NUM, *
  FROM (
    SELECT SUM(a.price * a.quantity) AS TOTALS, c.person_name, c.id
    FROM products_in_cart a, shopping_cart b, person c, state s
    WHERE a.cart_id = b.id AND b.is_purchased = true AND b.person_id = c.id AND c.state_id = s.id
    GROUP BY c.person_name, c.id
  )  as s ORDER BY s.TOTALS DESC
) a
WHERE NUM >=0 AND NUM <=20

//get each row
//need id of category
//person name 1
// product id 2
// category id 3
SELECT (a.price * a.quantity) as totalSales
FROM products_in_cart a, shopping_cart b, person c, product d
WHERE c.person_name = ? AND a.product_id = ?  AND b.id = a.product_id
b.ispurchased = true AND d.category_id = ?
GROUP BY c.person_name

//sort product alphabetically by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER By substring(product_name, '^[0-9]+')::int, substring(product_name, '[^0-9]*$')) NUM, * FROM
  (
    SELECT c.product_name
    FROM product c
  ) AS p
) a
WHERE NUM > 0 AND NUM < 19


//Sort customers alphabetically by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER By substring(person_name, '^[0-9]+')::int, substring(person_name, '[^0-9]*$')) NUM, * FROM
  (
    SELECT c.person_name
    FROM person c
  ) AS p
) a
WHERE NUM > 0 AND NUM < 19

//sort states alphabetically by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER(ORDER By substring(state_name, '^[0-9]+')::int, substring(state_name, '[^0-9]*$')) NUM, * FROM
  (
    SELECT c.state_name
    FROM state c
  ) AS p
) a
WHERE NUM > 0 AND NUM < 19

//top products all categories by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER (ORDER BY totalSales DESC) NUM,
  * FROM
  (
    SELECT a.product_id, c.product_name, SUM(a.price * a.quantity) as totalSales
    FROM products_in_cart a, shopping_cart b, product c
    WHERE a.cart_id = b.id AND b.is_purchased = true AND c.id = a.product_id
    GROUP BY c.product_name, a.product_id
  ) as S
) as topProducts
WHERE NUM >=1 AND NUM <=10
ORDER BY totalSales DESC


Top products in ONE category by range
SELECT * FROM
(
  SELECT ROW_NUMBER() OVER (ORDER BY totalSales DESC) NUM,
  * FROM
  (
    SELECT a.product_id, c.product_name, d.category_name, SUM(a.price * a.quantity) as totalSales
    FROM products_in_cart a, shopping_cart b, product c, category d
    WHERE a.cart_id = b.id AND b.is_purchased = true AND c.id = a.product_id AND c.category_id = d.id AND d.category_name = 'CAT_2'
    GROUP BY a.product_id, c.product_name, d.category_name
  ) as S
) as topProducts
WHERE NUM >=1 AND NUM <=10
ORDER BY totalSales DESC

//Get sales for state and product
SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY totalSales DESC) NUM,  *
                           FROM  (SELECT a.product_id, c.product_name, SUM(a.price * a.quantity) as totalSales
                           FROM products_in_cart a, shopping_cart b, product c
                           WHERE a.cart_id = b.id AND b.is_purchased = true AND c.id = a.product_id
                           GROUP BY c.product_name, a.product_id ) as S
                           ) as topProducts
                           WHERE NUM >=? AND NUM <= ?
                           ORDER BY totalSales DESC

//================Project 3 Queries================================================================
//Top States for All Categories
SELECT f.id AS state_id, f.state_name AS stateName, coalesce(SUM(e.price * e.quantity),0) as totalSales
FROM state f LEFT OUTER JOIN person c ON f.id = c.state_id LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id
LEFT OUTER JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true
GROUP BY f.state_name, f.id
ORDER BY totalSales DESC NULLS LAST
LIMIT 50


//Top States for Specific Category
SELECT f.id AS state_id, f.state_name AS stateName , coalesce(SUM(e.price * e.quantity),0) AS totalSales
FROM state f LEFT OUTER JOIN person c ON f.id = c.state_id LEFT OUTER JOIN shopping_cart d ON c.id = d.person_id
LEFT OUTER JOIN products_in_cart e ON d.id = e.cart_id AND d.is_purchased = true LEFT OUTER JOIN  Category g ON g.category_name = ?
LEFT OUTER JOIN product h ON h.category_id = g.id AND h.id = e.product_id
GROUP BY f.state_name, f.id
ORDER BY totalSales DESC NULLS LAST
LIMIT 50

//Top Products for Specific Category
SELECT c.id AS id, c.product_name AS productName, coalesce(SUM(d.price * d.quantity),0) as totalSales, e.category_name AS category_name
FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id JOIN category e ON e.category_name = ? AND e.id = c.category_id
GROUP BY c.product_name, c.id, e.id, e.category_name
Order BY totalSales DESC NULLS LAST
Limit 50

//Top Products for All Categories
SELECT c.id AS id, c.product_name AS productName, coalesce(SUM(d.price * d.quantity),0) as totalSales, f.category_name
FROM product c LEFT OUTER JOIN products_in_cart d ON c.id = d.product_id LEFT OUTER JOIN category f ON f.id = c.category_id
GROUP BY c.product_name, c.id, f.category_name
ORDER BY totalSales DESC NULLS LAST
Limit 50

//Top Products + Top States for All Categories
with overall_table as
(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount
 	from products_in_cart pc
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	inner join product p on (pc.product_id = p.id) -- add category filter if any
 	inner join person c on (sc.person_id = c.id)
 	group by pc.product_id,c.state_id
),
top_state as
(select state_id, sum(amount) as dollar from (
	select state_id, amount from overall_table
	UNION ALL
	select id as state_id, 0.0 as amount from state
	) as state_union
 group by state_id order by dollar desc limit 50  --offset 20
),
top_n_state as
(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state
),
top_prod as
(select product_id, sum(amount) as dollar from (
	select product_id, amount from overall_table
	UNION ALL
	select id as product_id, 0.0 as amount from product
	) as product_union
group by product_id order by dollar desc limit 50 --offset 20
),
top_n_prod as
(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod
)
select ts.state_id, s.state_name, tp.product_id, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum
	from top_n_prod tp CROSS JOIN top_n_state ts
	LEFT OUTER JOIN overall_table ot
	ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id)
	inner join state s ON ts.state_id = s.id
	inner join product pr ON tp.product_id = pr.id
	order by ts.state_order, tp.product_order


//Top State + Top Products for Specified Category
with overall_table as
(select pc.product_id,c.state_id,sum(pc.price*pc.quantity) as amount
 	from products_in_cart pc
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	inner join product p on (pc.product_id = p.id AND p.category_id = ? AND sc.id = pc.cart_id ) -- add category filter if any
 	inner join person c on (sc.person_id = c.id)
 	group by pc.product_id,c.state_id
),
top_state as
(select state_id, sum(amount) as dollar from (
	select state_id, amount from overall_table
	UNION ALL
	select id as state_id, 0.0 as amount from state
	) as state_union
 group by state_id order by dollar desc limit 50  --offset 20
),
top_n_state as
(select row_number() over(order by dollar desc) as state_order, state_id, dollar from top_state
),
top_prod as
(select product_id, sum(amount) as dollar from (
	select product_id, amount from overall_table
	) as product_union
group by product_id order by dollar desc limit 50 --offset 20
),
top_n_prod as
(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod
)
select ts.state_id, s.state_name, tp.product_id, pr.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum
	from top_n_prod tp CROSS JOIN top_n_state ts
	LEFT OUTER JOIN overall_table ot
	ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id)
	inner join state s ON ts.state_id = s.id
	inner join product pr ON tp.product_id = pr.id
	order by ts.state_order, tp.product_order

CREATE TABLE topStateSales (
  ID INTEGER NOT NULL,
  stateName TEXT NOT NULL,
  totalSales INTEGER DEFAULT 0,
  serial_id SERIAL PRIMARY KEY,
)

CREATE TABLE topProductSales (
  ID INTEGER NOT NULL,
  productName TEXT NOT NULL,
  totalSales INTEGER DEFAULT 0,
  category_name TEXT NOT NULL,
  serial_id SERIAL PRIMARY KEY
)

CREATE TABLE topProduct_states (
  stateID INTEGER NOT NULL,
  stateName TEXT NOT NULL,
  productID INTEGER NOT NULL,
  productName TEXT NOT NULL,
  cell_sum INTEGER  DEFAULT 0,
  state_sum INTEGER  DEFAULT 0,
  product_sum INTEGER  DEFAULT 0,
  serial_id SERIAL PRIMARY KEY
)


create TABLE newPurchases (
product_id INTEGER NOT NULL,
cart_id INTEGER NOT NULL,
price REAL NOT NULL CHECK (price >= 0.0),
quantity INTEGER NOT NULL CHECK (quantity > 0)
)

CREATE FUNCTION putInCopy() RETURNS trigger AS $putInCopy$
BEGIN
INSERT INTO newPurchases(product_id,cart_id, price, quantity) VALUES (NEW.product_id,NEW.cart_id, NEW.price, NEW.quantity);
RETURN NULL ;
END;
$putInCopy$ LANGUAGE plpgsql;

//Update topstatesales precomputed table
UPDATE topStateSales
SET totalSales = totalSales + (
    SELECT SUM(a.price * a.quantity)
    FROM newPurchases a, shopping_cart b, person c, state d
    WHERE a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id
    AND d.state_name = topStateSales.stateName
)

WHERE topStateSales.stateName IN (
    SELECT d.state_name
    FROM newPurchases a, shopping_cart b, person c, state d
    WHERE a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id
)

//Update topProductSales precomputed table
UPDATE topProductSales
SET totalSales = totalSales + (
    SELECT SUM(a.price * a.quantity)
    FROM newPurchases a
    WHERE a.product_id = topProductSales.id
)

WHERE topProductSales.ID IN (
    SELECT b.product_ID
    FROM newPurchases b
 )

//Update topProduct_states precomputed table
UPDATE topProduct_states
SET cell_sum = cell_sum + (
    SELECT SUM(a.price * a.quantity)
    FROM newPurchases a, shopping_cart b, person c, state d
    WHERE  a.product_id = topProduct_states.productID AND
    a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id
    AND d.id = topProduct_states.stateID
)

WHERE topProduct_states.productID IN (
    SELECT product_id
    FROM newPurchases
    )
AND topProduct_states.stateName IN (
    SELECT d.state_name
    FROM newPurchases a, shopping_cart b, person c, state d
    WHERE a.cart_id = b.id AND b.person_id = c.id AND c.state_id = d.id
    )


//Select sales for top products
SELECT *
FROM topProductSales
ORDER BY serial_id ASC

//Select sales for top states
SELECT *
FROM topStateSales
ORDER BY serial_id ASC

//Select cells for cells
SELECT *
FROM topProduct_states
ORDER BY serial_id ASC


//***********************Indices*************************************
CREATE INDEX person_state_id ON person(state_id)
CREATE INDEX shopping_cart_person_id ON shopping_cart(person_id)
CREATE INDEX product_category_id on product(category_id)
 


