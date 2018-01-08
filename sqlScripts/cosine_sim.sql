WITH SALES AS (select pc.product_id,sc.person_id,sum(pc.price*pc.quantity) as amount  
 	from products_in_cart pc 
 	inner join shopping_cart sc on (sc.id = pc.cart_id and sc.is_purchased = true)
 	group by pc.product_id,sc.person_id),
 DENOM AS (
	SELECT product_id, SUM(amount) as denom_sums
	FROM SALES
	GROUP BY product_id)
SELECT s1.product_id, s2.product_id, (SUM (s1.amount*s2.amount)/(d1.denom_sums * d2.denom_sums)) as val
FROM SALES s1 JOIN SALES s2 ON (s1.product_id < s2.product_id), DENOM d1, DENOM d2
WHERE s1.person_id = s2.person_id AND d1.product_id = s1.product_id AND d2.product_id = s2.product_id
GROUP BY (s1.product_id, s2.product_id,d1.denom_sums, d2.denom_sums)
ORDER BY val desc LIMIT 100;