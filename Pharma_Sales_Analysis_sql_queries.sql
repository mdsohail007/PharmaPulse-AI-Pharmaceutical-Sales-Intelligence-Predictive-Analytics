
-- Check the first 20 rows
SELECT *
FROM customer
LIMIT 20;

-- Count total rows
SELECT COUNT(*) AS total_rows
FROM customer;

-- Q1. What is the total revenue generated?
SELECT
    ROUND(SUM(net_sales)::numeric, 2) AS total_revenue
FROM customer;

-- Q2. Which products generate the highest revenue?
SELECT
    product_name,
    ROUND(SUM(net_sales)::numeric, 2) AS total_revenue
FROM customer
GROUP BY product_name
ORDER BY SUM(net_sales) DESC
LIMIT 10;

-- Q3. Which are the top 5 therapeutic categories by revenue?
SELECT
    therapeutic_category,
    ROUND(SUM(net_sales)::numeric, 2) AS total_revenue
FROM customer
GROUP BY therapeutic_category
ORDER BY SUM(net_sales) DESC
LIMIT 5;

-- Q4. Which regions generate the most revenue?
SELECT
    region,
    ROUND(SUM(net_sales)::numeric, 2) AS total_revenue
FROM customer
GROUP BY region
ORDER BY SUM(net_sales) DESC;

-- Q5. Which sales channel performs best?
SELECT
    sales_channel,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(net_sales)::numeric, 2) AS total_revenue_usd,
    ROUND(AVG(net_sales)::numeric, 2) AS avg_transaction_revenue
FROM customer
GROUP BY sales_channel
ORDER BY SUM(net_sales) DESC;

-- Q6. Which 5 products receive discounts most frequently?
SELECT
    product_name,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (WHERE discount_rate > 0)
        AS discounted_transactions,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE discount_rate > 0)
        / NULLIF(COUNT(*), 0),
        2
    ) AS discount_percentage
FROM customer
GROUP BY product_name
ORDER BY discount_percentage DESC,
         discounted_transactions DESC
LIMIT 5;

-- Q7. How do monthly sales change over time?
SELECT
    DATE_TRUNC('month', sales_date::date)::date AS sales_month,
    ROUND(SUM(net_sales)::numeric, 2) AS monthly_revenue,
    SUM(units_sold) AS monthly_units_sold
FROM customer
GROUP BY DATE_TRUNC('month', sales_date::date)
ORDER BY sales_month;

-- Q8. What are the top 3 products by revenue
-- within each therapeutic category?
WITH product_revenue AS (
    SELECT
        therapeutic_category,
        product_name,
        SUM(net_sales) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY therapeutic_category
            ORDER BY SUM(net_sales) DESC
        ) AS product_rank
    FROM customer
    GROUP BY therapeutic_category, product_name
)
SELECT
    therapeutic_category,
    product_name,
    ROUND(total_revenue::numeric, 2) AS total_revenue,
    product_rank
FROM product_revenue
WHERE product_rank <= 3
ORDER BY therapeutic_category, product_rank;

-- Q9. Which products have the highest average discount rate?
SELECT
    product_name,
    ROUND((AVG(discount_rate) * 100)::numeric, 2)
        AS avg_discount_percentage,
    ROUND(SUM(net_sales)::numeric, 2) AS total_revenue,
    SUM(units_sold) AS total_units_sold
FROM customer
GROUP BY product_name
ORDER BY AVG(discount_rate) DESC
LIMIT 10;

-- Q10. What is each region's percentage contribution
-- to total revenue?
SELECT
    region,
    ROUND(SUM(net_sales)::numeric, 2) AS regional_revenue,
    ROUND(
        (
            100.0 * SUM(net_sales)
            / NULLIF(SUM(SUM(net_sales)) OVER (), 0)
        )::numeric,
        2
    ) AS revenue_contribution_percentage
FROM customer
GROUP BY region
ORDER BY SUM(net_sales) DESC;

