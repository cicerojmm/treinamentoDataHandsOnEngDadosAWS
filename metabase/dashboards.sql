
--Avaliação média por categoria
SELECT 
    p.category,
    AVG(f.avg_rating) AS avg_rating
FROM datawarehouse.fact_product_rating f
JOIN datawarehouse.dim_product p 
    ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_rating DESC
LIMIT 10

--Correlação entre vendas e avaliações
SELECT 
    p.category,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    SUM(COALESCE(s.sales_amount, 10)) AS total_sales
FROM datawarehouse.dim_product p
LEFT JOIN datawarehouse.dim_rating r 
    ON p.product_id = r.product_id
LEFT JOIN datawarehouse.fact_sales_category s 
    ON p.category = s.category
GROUP BY p.category
ORDER BY avg_rating,total_sales DESC
LIMIT 10

--Média de avaliação por produto
SELECT 
    p.product_id,
    p.product_name,
    f.avg_rating
FROM datawarehouse.fact_product_rating f
JOIN datawarehouse.dim_product p 
    ON f.product_id = p.product_id
ORDER BY f.avg_rating DESC;

--Top N categorias mais vendidas
SELECT 
    p.category,
    SUM(COALESCE(s.sales_amount, 10)) AS total_sales
FROM datawarehouse.fact_sales_category s
JOIN datawarehouse.dim_product p 
    ON s.category = p.category
GROUP BY p.category, p.product_name
ORDER BY p.category, total_sales DESC
LIMIT 10;

-- Total de Vendas ($)
SELECT 
    SUM(COALESCE(sales_amount, 10))
FROM datawarehouse.fact_sales_category;


--Total de Vendas Geral
SELECT 
    count(*) AS total_sales
FROM datawarehouse.fact_sales_category;
