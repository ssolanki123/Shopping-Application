with overall_table as 
(select pc.product_id,sc.person_id,sum(pc.price*pc.quantity) as amount  
 	from products_in_cart pc  
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	inner join product p on (pc.product_id = p.id) -- add category filter if any
 	group by pc.product_id,sc.person_id
),
top_cust as
(
select person_id, sum(amount) as dollar from (
	select person_id, amount from overall_table 
	UNION ALL
	select id as person_id, 0 as amount from person
	) as person_union
group by person_id order by dollar desc limit 20  --offset 20
),
top_n_cust as 
(select row_number() over(order by dollar desc) as person_order, person_id, dollar from top_cust
),
top_prod as 
(
select product_id, sum(amount) as dollar from (
	select product_id, amount from overall_table
	UNION ALL
	select id as product_id, 0 as amount from product
	) as product_union
group by product_id order by dollar desc limit 10 --offset 20
),
top_n_prod as 
(select row_number() over(order by dollar desc) as product_order, product_id, dollar from top_prod
)
select tc.person_id, c.person_name, tp.product_id, pr.product_name, pr.category_id, COALESCE(ot.amount, 0.0) as cell_sum, tc.dollar as cust_sum, tp.dollar as product_sum
	from top_n_prod tp CROSS JOIN top_n_cust tc 
	LEFT OUTER JOIN overall_table ot 
	ON ( tp.product_id = ot.product_id and tc.person_id = ot.person_id)
	inner join person c ON tc.person_id = c.id
	inner join product pr ON tp.product_id = pr.id
	order by tc.person_order, tp.product_order
	
