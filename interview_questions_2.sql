/* -----------------------------------------------------------------------
Questionário 2
    Adaptado para a realidade da base de dados que estamos utilizando.

Fonte:
https://www.linkedin.com/posts/saibysani18_if-youre-preparing-for-a-data-analystdata-activity-7384936241210810369-TyXn/?utm_source=share&utm_medium=member_desktop&rcm=ACoAACZDmecB_a04XxO9WjU9021EUv9lvNeHvRw

*/-----------------------------------------------------------------------



-- 1. SELF-JOIN -------------------------------------------------------------------------



-- a) Compare this month's sales to last month

WITH table_revenue AS (
    SELECT
        to_char(orderdate, 'YYYY-MM') as order_month,
        ROUND(SUM(netprice * quantity * exchangerate)::NUMERIC,2) as net_revenue
    FROM sales
    GROUP BY
        order_month
)
SELECT *,
    LAG(net_revenue) OVER(ORDER BY order_month) AS prev_month_revenue,
    net_revenue - LAG(net_revenue) OVER(ORDER BY order_month) AS month_diff
FROM table_revenue
ORDER BY
    order_month DESC


-- b) Master: joining a table to itself with different aliases
-- Pro tip: THing of it as creating two copies of the same table


-- Finding consecutive days of activity
SELECT 
    s1.customerkey,
    s1.orderdate AS current_date,
    s2.orderdate AS next_date
FROM sales s1
JOIN sales s2
    ON s1.customerkey = s2.customerkey
   AND s2.orderdate = s1.orderdate + INTERVAL '1 day'
GROuP BY 
    s1.customerkey,
    s1.orderdate,
    s2.orderdate;



-- 2. Running Total -------------------------------------------------------------------------


-- a) Calculate cumulative revenue by month

WITH table_orders AS (
SELECT
    to_char(orderdate, 'YYYY-MM') AS month,
    ROUND(SUM(unitprice * quantity * exchangerate)::numeric, 2) as net_revenue
FROM sales
GROUP BY month
)
SELECT
    month,
    net_revenue,
    SUM(net_revenue) OVER(
        ORDER BY month ROWS UNBOUNDED PRECEDING
    ) AS rolling_revenue
FROM table_orders
ORDER BY month DESC;


-- b) Calculate year to date calculations

WITH table_orders AS (
SELECT
    to_char(orderdate, 'YYYY-MM') AS month,
    extract(year from orderdate) AS year,
    ROUND(SUM(unitprice * quantity * exchangerate)::numeric, 2) as net_revenue
FROM sales
GROUP BY month, year
)
SELECT
    month,
    year,
    net_revenue,
    SUM(net_revenue) OVER(
        PARTITION BY year
        ORDER BY month ROWS UNBOUNDED PRECEDING
    ) AS rolling_revenue
FROM table_orders
ORDER BY month DESC;

-- c) Moving Averages (Two before + current) for projections

WITH table_orders AS (
SELECT
    to_char(orderdate, 'YYYY-MM') AS month,
    ROUND(SUM(unitprice * quantity * exchangerate)::numeric, 2) as net_revenue
FROM sales
GROUP BY month
)
SELECT
    month,
    net_revenue,
    AVG(net_revenue) OVER(
        ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_avg
FROM table_orders
ORDER BY month DESC;



-- 3. Top-N Per Group Pattern -------------------------------------------------------------------------

-- a) Find top 3 products in each category

WITH product_revenue AS (
    SELECT
        productname,
        categoryname,
        ROUND(SUM(unitprice * quantity * exchangerate)::NUMERIC, 2) AS net_revenue
    FROM sales s
    JOIN product p ON s.productkey = p.productkey
    GROUP BY
        productname,
        categoryname
), rank_table AS (
    SELECT
        *,
        RANK() OVER(
            PARTITION BY categoryname
            ORDER BY net_revenue DESC
        ) AS top_products --Used rank() to consider possibility of ties
    FROM product_revenue
)
SELECT
    *
FROM rank_table
WHERE top_products <= 3;




-- b) Get the top 3 revenue cities per country


WITH region_revenue AS (
    SELECT
        city,
        country,
        ROUND(SUM(unitprice * quantity * exchangerate)::NUMERIC, 2) AS net_revenue
    FROM sales s
    JOIN customer c ON s.customerkey = c.customerkey
    GROUP BY
        city,
        country
), rank_table AS (
    SELECT
        *,
        RANK() OVER(
            PARTITION BY country
            ORDER BY net_revenue DESC
        ) AS top_city --Used rank() to consider possibility of ties
    FROM region_revenue
)
SELECT
    *
FROM rank_table
WHERE top_city <= 3;



-- 4. The Gap & Island Pattern -------------------------------------------------------------------------

-- a) Find periods of no sales

WITH table_sales AS (
    SELECT
        orderdate,
        LAG(orderdate, 1) OVER(
                ORDER BY orderdate
        ) AS last_revenue_date,
        ROUND(sum(quantity * netprice * exchangerate)::NUMERIC,2) AS net_revenue
    FROM sales
    GROUP BY orderdate
)
SELECT
    orderdate AS gap_end,
    last_revenue_date AS gap_start,
    (orderdate - last_revenue_date)-1 AS GAP_days
FROM table_sales
WHERE (orderdate - last_revenue_date)-1 >= 1
ORDER BY orderdate




-- b) Identify consecutive days with sales > $180K

WITH table_sales AS (
    SELECT
        orderdate AS gap_end,
        ROUND(sum(quantity * netprice * exchangerate)::NUMERIC,2) AS start_revenue
    FROM sales
    GROUP BY gap_end
), table_lags AS (
    SELECT
        gap_end,
        LAG(gap_end, 1) OVER(
                ORDER BY gap_end
        ) AS gap_start,
        start_revenue,
        LAG(start_revenue, 1) OVER(
                ORDER BY gap_end
        ) AS end_revenue
    FROM table_sales
)
SELECT
    gap_start,
    gap_end,
    start_revenue,
    end_revenue
FROM table_lags
WHERE (gap_end - gap_start)-1 = 0
    AND start_revenue > 180000
    AND end_revenue > 180000
ORDER BY gap_end



