SELECT ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name) FullName, cus.city, cus.state, ord.order_date, 
       SUM(ite.quantity) AS TotalUnits, SUM(ite.quantity * ite.list_price) AS Revenue, pro.product_name,
       cat.category_name, sto.store_name,
	   staff.first_name + ' ' + staff.last_name as SalesRep
FROM sales.orders ord
JOIN sales.customers cus
     ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite
     ON ord.order_id = ite.order_id
JOIN production.products pro
     ON ite.product_id = pro.product_id
JOIN production.categories cat
     ON pro.category_id = cat.category_id
JOIN sales.stores sto
     ON ord.store_id = sto.store_id 
JOIN sales.staffs staff
     ON ord.staff_id = staff.staff_id
GROUP BY ord.order_id, CONCAT(cus.first_name, ' ', cus.last_name), cus.city, cus.state, ord.order_date, pro.product_name,
         cat.category_name, sto.store_name, staff.first_name + ' ' + staff.last_name
