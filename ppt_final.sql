USE magist;

-- Exporting order delivery status information to a CSV file
SELECT order_status, COUNT(*), COUNT(*)*100/(SELECT COUNT(*) FROM orders) 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_delivery_status.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM orders
GROUP BY order_status;


-- Exporting monthly revenue for the company
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(oi.price * oi.order_item_id) AS monthly_revenue
FROM 
    order_items AS oi
LEFT JOIN 
    orders AS o ON oi.order_id = o.order_id
WHERE 
    o.order_status = "delivered"
    AND NOT
    ((MONTH(order_purchase_timestamp) IN (09, 10, 12) AND YEAR(order_purchase_timestamp) = 2016)
    OR (MONTH(order_purchase_timestamp) IN (09, 10) AND YEAR(order_purchase_timestamp) = 2018))
GROUP BY 
    month
ORDER BY 
    month;


-- Exporting monthly order counts with specific exclusions to a CSV file
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS Month, COUNT(order_id) AS Num_orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders_by_month.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM orders
WHERE 
	order_status = 'Delivered' and
	NOT
    ((MONTH(order_purchase_timestamp) IN (09, 10, 12) AND YEAR(order_purchase_timestamp) = 2016)
    OR (MONTH(order_purchase_timestamp) IN (09, 10) AND YEAR(order_purchase_timestamp) = 2018))
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m');

-- Exporting num of tech orders for each month to a CSV file
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS Month,
    SUM(CASE WHEN p.product_category_name IN ('telefonia', 'tablets_impressao_imagem', 'pcs', 'informatica_acessorios') THEN 1 ELSE 0 END) AS Num_tech_orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Num_tech_orders.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM
    orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
WHERE
    o.order_status = 'Delivered'
    AND NOT (
        (MONTH(o.order_purchase_timestamp) IN (09, 10, 12) AND YEAR(o.order_purchase_timestamp) = 2016)
        OR (MONTH(o.order_purchase_timestamp) IN (09, 10) AND YEAR(o.order_purchase_timestamp) = 2018)
    )
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m');


-- Exporting share of tech orders for each month to a CSV file
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS Month,
    SUM(CASE WHEN p.product_category_name IN ('telefonia', 'tablets_impressao_imagem', 'pcs', 'informatica_acessorios') THEN 1 ELSE 0 END) * 100 / COUNT(*) AS Share_tech_orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Share_tech_orders.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM
    orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
WHERE
    o.order_status = 'Delivered'
    AND NOT (
        (MONTH(o.order_purchase_timestamp) IN (09, 10, 12) AND YEAR(o.order_purchase_timestamp) = 2016)
        OR (MONTH(o.order_purchase_timestamp) IN (09, 10) AND YEAR(o.order_purchase_timestamp) = 2018)
    )
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m');

-- Exporting product category name translations for specific tech categories
SELECT * FROM product_category_name_translation
WHERE product_category_name IN ('telefonia', 'tablets_impressao_imagem', 'pcs', 'informatica_acessorios');

-- Exporting all orders counts for each month to a CSV file
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS Month, COUNT(order_id) AS Num_orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/All_orders_by_month.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM orders
WHERE order_status = 'Delivered'
    AND NOT 
	((MONTH(order_purchase_timestamp) IN (09, 10, 12) AND YEAR(order_purchase_timestamp) = 2016)
    OR (MONTH(order_purchase_timestamp) IN (09, 10) AND YEAR(order_purchase_timestamp) = 2018) )
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m');

-- Exporting count of tech products to a CSV file
SELECT COUNT(oi.product_id) AS Num_tech_products
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Num_tech_products.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM order_items oi
WHERE 
    oi.product_id IN (
        SELECT product_id
        FROM products
        WHERE product_category_name IN ('telefonia', 'tablets_impressao_imagem', 'pcs', 'informatica_acessorios')
    )
    AND oi.order_id NOT IN (
        SELECT order_id
        FROM orders
        WHERE (MONTH(order_purchase_timestamp) IN (09, 10, 12) AND YEAR(order_purchase_timestamp) = 2016)
            OR (MONTH(order_purchase_timestamp) IN (09, 10) AND YEAR(order_purchase_timestamp) = 2018)
    )
     AND oi.order_id IN (SELECT o.order_id FROM orders o WHERE o.order_status="Delivered");

-- Exporting count of non-tech products to a CSV file
SELECT COUNT(oi.product_id) AS Num_nontech_products
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Num_nontech_products.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM order_items oi
WHERE 
    oi.product_id IN (
        SELECT product_id
        FROM products
        WHERE NOT product_category_name IN ('telefonia', 'tablets_impressao_imagem', 'pcs', 'informatica_acessorios')
    )
    AND oi.order_id IN (SELECT o.order_id FROM orders o WHERE o.order_status="Delivered")
    AND oi.order_id NOT IN (
        SELECT order_id
        FROM orders
        WHERE (MONTH(order_purchase_timestamp) IN (09, 10, 12) AND YEAR(order_purchase_timestamp) = 2016)
            OR (MONTH(order_purchase_timestamp) IN (09, 10) AND YEAR(order_purchase_timestamp) = 2018)
    );

-- Exporting average basket value of all products to a CSV file
SELECT AVG(total_price) AS Avg_basket_value
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Avg_basket_value.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM (
    SELECT SUM(oi.price) AS total_price
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE 
		oi.order_id IN (SELECT o.order_id FROM orders o WHERE o.order_status="Delivered") AND 
        NOT (
            (MONTH(o.order_purchase_timestamp) IN (09, 10, 12) AND YEAR(o.order_purchase_timestamp) = 2016)
            OR (MONTH(o.order_purchase_timestamp) IN (09, 10) AND YEAR(o.order_purchase_timestamp) = 2018)
        )
    GROUP BY oi.order_id
) AS Subquery;

-- Exporting average basket value of non-tech products to a CSV file
SELECT AVG(total_price) AS Avg_non_tech_basket_value
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Avg_basket_nontech.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM (
    SELECT SUM(oi.price) AS total_price
    FROM order_items AS oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE 
		oi.order_id IN (SELECT o.order_id FROM orders o WHERE o.order_status="Delivered") AND
        NOT (
            (MONTH(o.order_purchase_timestamp) IN (09, 10, 12) AND YEAR(o.order_purchase_timestamp) = 2016)
            OR (MONTH(o.order_purchase_timestamp) IN (09, 10) AND YEAR(o.order_purchase_timestamp) = 2018)
        )
        AND NOT oi.product_id IN (SELECT product_id FROM products WHERE product_category_name IN ('telefonia' , 'tablets_impressao_imagem', 'pcs','informatica_acessorios'))
    GROUP BY oi.order_id
) AS Subquery;

-- Exporting average basket value of tech products to a CSV file
SELECT AVG(total_price) AS Avg_tech_basket_value
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Avg_basket_value_tech.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM (
    SELECT SUM(oi.price) AS total_price
    FROM order_items AS oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE 
		oi.order_id IN (SELECT o.order_id FROM orders o WHERE o.order_status="Delivered") AND
        NOT (
            (MONTH(o.order_purchase_timestamp) IN (09, 10, 12) AND YEAR(o.order_purchase_timestamp) = 2016)
            OR (MONTH(o.order_purchase_timestamp) IN (09, 10) AND YEAR(o.order_purchase_timestamp) = 2018)
        )
        AND oi.product_id IN (SELECT product_id FROM products WHERE product_category_name IN ('telefonia' , 'tablets_impressao_imagem', 'pcs','informatica_acessorios'))
    GROUP BY oi.order_id
) AS Subquery;

-- Exporting product information including quantities sold, average prices, freight values, and review scores to a CSV file
SELECT 
    'product_id' AS product_id,
    'product_category_name' AS product_category_name,
    'product_category_name_english' AS product_category_name_english,
    'quantities_sold' AS quantities_sold,
    'avg_price' AS avg_price,
    'avg_freight_value' AS avg_freight_value,
    'avg_review' AS avg_review,
    'avg_delivery_delay' AS avg_delivery_delay,
    'avg_processing_delay' AS avg_processing_delay,
    'avg_in_post_delay' AS avg_in_post_delay,
    'avg_delivery_vs_exp_delay' AS avg_delivery_vs_exp_delay
UNION
SELECT 
    oi.product_id,
    p.product_category_name,
    pn.product_category_name_english,
    COUNT(oi.order_id) AS quantities_sold,
    AVG(oi.price) AS avg_price,
    AVG(oi.freight_value) AS avg_freight_value,
    AVG(ord_r.review_score) AS avg_review,
    AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_delay,
    AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_carrier_date)) AS avg_processing_delay,
    AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) - TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_carrier_date)) AS avg_in_post_delay,
    AVG(TIMESTAMPDIFF(DAY, o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delivery_vs_exp_delay
FROM
    order_items oi
        LEFT JOIN
    orders o ON oi.order_id = o.order_id
        LEFT JOIN
    order_reviews AS ord_r ON oi.order_id = ord_r.order_id
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
		LEFT JOIN 
	product_category_name_translation AS pn ON p.product_category_name=pn.product_category_name
WHERE
    o.order_status = 'delivered'
    AND NOT (
        (MONTH(o.order_purchase_timestamp) IN (09, 10, 12) AND YEAR(o.order_purchase_timestamp) = 2016)
        OR (MONTH(o.order_purchase_timestamp) IN (09, 10) AND YEAR(o.order_purchase_timestamp) = 2018)
    )
GROUP BY product_id, product_category_name
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products_info.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Exporting information about tech products to a CSV file
SELECT 
    'product_id' AS product_id,
    'product_category_name' AS product_category_name,
    'product_category_name_english' AS product_category_name_english,
    'quantities_sold' AS quantities_sold,
    'avg_price' AS avg_price,
    'avg_freight_value' AS avg_freight_value,
    'avg_review' AS avg_review,
    'avg_delivery_delay' AS avg_delivery_delay,
    'avg_processing_delay' AS avg_processing_delay,
    'avg_in_post_delay' AS avg_in_post_delay,
    'avg_delivery_vs_exp_delay' AS avg_delivery_vs_exp_delay
UNION
SELECT 
    oi.product_id,
    p.product_category_name,
    pn.product_category_name_english,
    COUNT(oi.order_id) AS quantities_sold,
    AVG(oi.price) AS avg_price,
    AVG(oi.freight_value) AS avg_freight_value,
    AVG(ord_r.review_score) AS avg_review,
    AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_delay,
    AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_carrier_date)) AS avg_processing_delay,
    AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) - TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_carrier_date)) AS avg_in_post_delay,
    AVG(TIMESTAMPDIFF(DAY, o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delivery_vs_exp_delay
FROM
    order_items oi
        LEFT JOIN
    orders o ON oi.order_id = o.order_id
        LEFT JOIN
    order_reviews AS ord_r ON oi.order_id = ord_r.order_id
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
		LEFT JOIN 
	product_category_name_translation AS pn ON p.product_category_name=pn.product_category_name
WHERE
    o.order_status = 'delivered' 
    AND p.product_category_name IN ('telefonia' , 'tablets_impressao_imagem', 'pcs', 'informatica_acessorios')
    AND NOT (
        (MONTH(o.order_purchase_timestamp) IN (09, 10, 12) AND YEAR(o.order_purchase_timestamp) = 2016)
        OR (MONTH(o.order_purchase_timestamp) IN (09, 10) AND YEAR(o.order_purchase_timestamp) = 2018)
    )
GROUP BY product_id, product_category_name
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tech_products_info.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';