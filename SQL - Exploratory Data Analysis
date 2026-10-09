WITH month_numbertoword AS (
	SELECT 
		order_number,
		CASE WHEN EXTRACT(MONTH FROM date) = 6 THEN 'June'
			WHEN EXTRACT(MONTH FROM date) = 7 THEN 'July'
			WHEN EXTRACT(MONTH FROM date) = 8 THEN 'August'
			ELSE 'Other' END AS month
	FROM sales),
--create another CTE for the sum of paymentfee and total (because paymentfree is percentage of the total) since aggregates functions cannot be aggregated
	paymentfeeCTE AS (
	SELECT order_number,
	SUM(payment_fee*total) AS paymentfee
	FROM sales
	GROUP BY order_number
	)

SELECT s.product_line, m.month, s.warehouse, SUM(total) - SUM(payment_fee) AS net_revenue
FROM sales AS s
INNER JOIN month_numbertoword AS m
ON s.order_number = m.order_number
INNER JOIN paymentfeeCTE AS p
ON s.order_number = p.order_number
WHERE client_type = 'Wholesale'
GROUP BY s.product_line, m.month, s.warehouse
ORDER BY s.product_line, m.month, net_revenue DESC;
