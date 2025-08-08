/*
Interview Questions Practice

Source:
https://www.linkedin.com/posts/tajamulkhann_maang-sql-interview-questions-ugcPost-7328977269735981056-cx2W/?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAACZDmecB_a04XxO9WjU9021EUv9lvNeHvRw
*/


-- 1) Daily count of active customers (bought at least twice)

SELECT
    customerkey,
    COUNT(distinct orderkey) AS total_orders
FROM sales
GROUP BY
    customerkey
HAVING
    COUNT(distinct orderkey) >= 2
ORDER BY
    total_orders DESC;

-- 2.1) Find the 2nd highest order without using LIMIT or TOP

WITH dense_rank AS (
    SELECT
        orderkey,
        SUM(netprice * quantity / exchangerate) AS net_price,
        DENSE_RANK() OVER(
            ORDER BY SUM(netprice * quantity / exchangerate) DESC
        ) AS order_rank
    FROM sales
    GROUP BY
        orderkey
)
SELECT
    orderkey,
    net_price,
    order_rank
FROM dense_rank
WHERE order_rank = 2;

-- 2.2) Find the 5nd highest quantity order without using LIMIT or TOP

with rank_table AS (
SELECT
    orderkey,
    SUM(quantity) as qtd_order,
    DENSE_RANK() OVER(
        ORDER BY SUM(quantity) DESC
    ) AS qtd_rank
FROM sales
GROUP BY
    orderkey
)
SELECT 
    orderkey,
    qtd_order,
    qtd_rank
FROM rank_table
WHERE
    qtd_rank = 5

-- 3) Identify sales gaps in time_series (anomaly in month sales)

SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS order_year,
    ROUND(SUM(netprice * quantity / exchangerate)::NUMERIC,2) AS net_price
FROM sales
GROUP BY
    order_year
ORDER BY
    order_year


-- 4) Fetch first purchase date per user and calculate days since then

WITH first_purchase_table AS (
    SELECT
        customerkey,
        orderkey,
        orderdate,
        DENSE_RANK() OVER(
            PARTITION BY customerkey
            ORDER BY orderdate
        ) AS dense_rank
    FROM sales
)
SELECT
    customerkey,
    orderdate AS first_purchase_date,
    orderdate - CURRENT_DATE AS interval
FROM first_purchase_table
WHERE dense_rank = 1
ORDER BY
    interval

-- 5) Join product and transaction tables and filter out null keys safely

SELECT
    s.productkey,
    s.netprice,
    p.*
FROM sales s
JOIN product p ON s.productkey = p.productkey
LIMIT 10;

/*
-> Inner Join or JOIN only show rows where the join was successful.
-> Often  safer than a LEFT JOIN
*/


-- 6) Get second-time customers within 7 days of the first purchase

WITH ranked_orders AS (
    SELECT
        customerkey,
        orderdate,
        ROW_NUMBER() OVER(
            PARTITION BY customerkey
            ORDER BY orderdate
            ) AS rn
    FROM sales
    GROUP BY
        customerkey,
        orderdate
), 
orders_sorted AS (
    SELECT
        customerkey,
        MIN(CASE WHEN rn = 1 THEN orderdate END) AS first_order_date,
        MIN(CASE WHEN rn = 2 THEN orderdate END) AS second_order_date
    FROM ranked_orders
    GROUP BY
        customerkey
),
first_second_interval AS (
    SELECT
        customerkey,
        first_order_date,
        second_order_date,
        second_order_date - first_order_date AS second_interval_days
    FROM orders_sorted
)
SELECT
    customerkey,
    first_order_date,
    second_order_date,
    second_interval_days
FROM first_second_interval
WHERE second_interval_days <= 7



-- 7) Calculate cumulative distinct product purchases per customer

-- If wants cumulative overtime

WITH distinct_purchases AS (
    SELECT
        customerkey,
        orderdate,
        productkey,
        ROW_NUMBER() OVER (PARTITION BY customerkey, productkey ORDER BY orderdate) AS rn
    FROM sales
),
first_purchases AS (
    -- Pega apenas a primeira vez que o cliente comprou cada produto
    SELECT
        customerkey,
        orderdate
    FROM distinct_purchases
    WHERE rn = 1
),
cumulative_counts AS (
    SELECT
        customerkey,
        orderdate,
        COUNT(*) OVER (
            PARTITION BY customerkey
            ORDER BY orderdate
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_distinct_products
    FROM first_purchases
)
SELECT *
FROM cumulative_counts
ORDER BY cumulative_distinct_products DESC, customerkey, orderdate;




-- If want just distinct products per customer
SELECT
    customerkey,
    COUNT(DISTINCT productkey) AS total_distinct_products
FROM sales
GROUP BY
    customerkey
ORDER BY
    total_distinct_products DESC



-- 8) Retrieve customers who spent above average in their region (Country)

WITH all_orders AS (
    SELECT
        c.countryfull,
        c.customerkey,
        SUM(netprice * quantity / exchangerate) AS net_revenue
    FROM sales s 
    LEFT JOIN customer c ON s.customerkey = c.customerkey
    GROUP BY
        c.countryfull,
        c.customerkey
), kpi_country AS (
    SELECT
        countryfull,
        AVG(net_revenue) AS avg_revenue_country
    FROM all_orders
    GROUP BY
        countryfull
), customer_filter AS (
    SELECT
        a.customerkey,
        a.countryfull,
        a.net_revenue,
        k.avg_revenue_country,
        CASE
            WHEN a.net_revenue < k.avg_revenue_country THEN 'Under'
            ELSE 'Above'
        END AS customer_status
    FROM all_orders a
    LEFT JOIN kpi_country k ON a.countryfull = k.countryfull  
)
SELECT
        customerkey,
        countryfull,
        net_revenue,
        avg_revenue_country,
        customer_status
FROM customer_filter
WHERE customer_status = 'Above'
ORDER BY
    net_revenue DESC


-- Versão mais compacta e otimizada

WITH customer_revenue AS (
    SELECT
        c.customerkey,
        c.countryfull,
        SUM(s.netprice * s.quantity / s.exchangerate) AS net_revenue
    FROM sales s
    LEFT JOIN customer c ON s.customerkey = c.customerkey
    GROUP BY c.countryfull, c.customerkey
),
customer_revenue_with_avg AS (
    SELECT
        *,
        AVG(net_revenue) OVER (PARTITION BY countryfull) AS avg_revenue_country
    FROM customer_revenue
)
SELECT
    customerkey,
    countryfull,
    net_revenue,
    avg_revenue_country,
    CASE
        WHEN net_revenue < avg_revenue_country THEN 'Under'
        ELSE 'Above'
    END AS customer_status
FROM customer_revenue_with_avg
WHERE net_revenue > avg_revenue_country
ORDER BY net_revenue DESC
LIMIT 10;

-- 9) Find duplicate rows in an ingestion table (based on all columns)

SELECT
    orderkey,
    linenumber,
    orderdate,
    deliverydate,
    customerkey,
    storekey,
    productkey,
    quantity,
    unitprice,
    netprice,
    unitcost,
    currencycode,
    exchangerate,
    count(orderkey) AS total_orders
FROM sales
GROUP BY
    orderkey,
    linenumber,
    orderdate,
    deliverydate,
    customerkey,
    storekey,
    productkey,
    quantity,
    unitprice,
    netprice,
    unitcost,
    currencycode,
    exchangerate
HAVING
    count(*) > 1
LIMIT 10;

-- 10) Compute daily revenue growth % using lag window function

WITH daily_revenue AS (
    SELECT
        orderdate,
        ROUND(SUM(netprice * quantity / exchangerate)::NUMERIC, 2) AS net_revenue
    FROM sales
    GROUP BY orderdate
),
revenue_with_lag AS (
    SELECT
        orderdate,
        net_revenue,
        LAG(net_revenue) OVER (ORDER BY orderdate) AS last_day_revenue
    FROM daily_revenue
)
SELECT
    *,
    ROUND(((net_revenue - last_day_revenue) / last_day_revenue) * 100, 2) AS daily_growth_rate
FROM revenue_with_lag
LIMIT 10;


-- 12) Identify products with declining sales 3 months in a row


WITH orders_table AS (
    SELECT
        TO_CHAR(orderdate, 'YYYY-MM') AS order_month,
        productkey,
        ROUND(SUM(netprice * quantity / exchangerate)::NUMERIC, 2) AS net_revenue
    FROM sales
    WHERE
        orderdate > '31.12.2022'
    GROUP BY 
        TO_CHAR(orderdate, 'YYYY-MM'), 
        productkey
), revenue_lags AS (
    SELECT
        order_month,
        productkey,        
        net_revenue,

        LAG(net_revenue) OVER(
            PARTITION BY productkey
            ORDER BY order_month
        ) AS prev_1,


        LAG(net_revenue, 2) OVER(
            PARTITION BY productkey
            ORDER BY order_month
        ) AS prev_2

    FROM orders_table
)
SELECT *
FROM revenue_lags
WHERE
    prev_1 > net_revenue AND
    prev_2 > prev_1 AND
    order_month >= '2024-04'















