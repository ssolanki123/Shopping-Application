with overall_table as 
(select pc.product_id, p.product_name, sc.person_id, c.person_name, sum(pc.price*pc.quantity) as amount  
 	from products_in_cart pc  
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	inner join product p on (pc.product_id = p.id) -- add category filter if any
 	inner join person c on (sc.person_id = c.id)
 	group by pc.product_id, sc.person_id, p.product_name, c.person_name
),
top_cust as
(
select person_id, person_name, sum(amount) as dollar from (
	select person_id, person_name, amount from overall_table 
	UNION ALL
	select id as person_id, person_name, 0.0 as amount from person
	) as person_union
group by person_id,person_name order by COALESCE(SUBSTRING(person_name FROM '([\d]+)$')::INTEGER, 0) asc ,person_name desc limit 20  --offset 20
),
top_n_cust as 
(select row_number() over(order by COALESCE(SUBSTRING(person_name FROM '([\d]+)$')::INTEGER, 0) asc ,person_name desc) as person_order, person_id, person_name, dollar from top_cust
),
top_prod as 
(
select product_id, product_name, sum(amount) as dollar from (
	select product_id, product_name, amount from overall_table
	UNION ALL
	select id as product_id, product_name, 0.0 as amount from product
	) as product_union
group by product_id,product_name order by COALESCE(SUBSTRING(product_name FROM '([\d]+)$')::INTEGER, 0) asc ,product_name desc limit 10 --offset 20
),
top_n_prod as 
(select row_number() over(order by COALESCE(SUBSTRING(product_name FROM '([\d]+)$')::INTEGER, 0) asc ,product_name desc) as product_order, product_id, product_name, dollar from top_prod
)
select tc.person_id, tc.person_name, tp.product_id, tp.product_name, COALESCE(ot.amount, 0.0) as cell_sum, tc.dollar as cust_sum, tp.dollar as product_sum
	from top_n_prod tp CROSS JOIN top_n_cust tc 
	LEFT OUTER JOIN overall_table ot 
	ON ( tp.product_id = ot.product_id and tc.person_id = ot.person_id)
	order by tc.person_order, tp.product_order
