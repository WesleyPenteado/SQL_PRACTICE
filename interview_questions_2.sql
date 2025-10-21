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









