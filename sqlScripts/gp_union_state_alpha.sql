with overall_table as 
(select pc.product_id, p.product_name, c.state_id, s.state_name, sum(pc.price*pc.quantity) as amount  
 	from products_in_cart pc  
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	inner join product p on (pc.product_id = p.id) -- add category filter if any
 	inner join person c on (sc.person_id = c.id)
 	inner join state s on (c.state_id = s.id)
 	group by pc.product_id, c.state_id, p.product_name, s.state_name
),
top_state as
(
select state_id, state_name, sum(amount) as dollar from (
	select state_id, state_name, amount from overall_table 
	UNION ALL
	select id as state_id, state_name, 0.0 as amount from state
	) as state_union
group by state_id, state_name order by state_name asc limit 20  --offset 20
),
top_n_state as 
(select row_number() over(order by state_name asc) as state_order, state_id, state_name, dollar from top_state
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
select ts.state_id, ts.state_name, tp.product_id, tp.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum
	from top_n_prod tp CROSS JOIN top_n_state ts
	LEFT OUTER JOIN overall_table ot 
	ON ( tp.product_id = ot.product_id and ts.state_id = ot.state_id)
	order by ts.state_order, tp.product_order
