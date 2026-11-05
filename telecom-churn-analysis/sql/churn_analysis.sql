CREATE DATABASE telecom_churn;
USE telecom_churn;

SELECT COUNT(*) AS total_customers
FROM `telco-customer-churn`;


-- Check the table's column names and data types
DESCRIBE `telco-customer-churn`;

-- Check churn counts
SELECT Churn, COUNT(*) AS customer_count
FROM `telco-customer-churn`
GROUP BY Churn;

-- Check total rows versus unique customers
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customerID) AS unique_customers
FROM `telco-customer-churn`;


SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM `telco-customer-churn`;


SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM `telco-customer-churn`
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


SELECT
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM `telco-customer-churn`
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

SELECT
    `TenureGroup`,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM `telco-customer-churn`
GROUP BY `TenureGroup`
ORDER BY churn_rate_pct DESC;


SELECT
    HighValueCustomer,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM `telco-customer-churn`
GROUP BY HighValueCustomer
ORDER BY churn_rate_pct DESC;


SELECT
    Contract,
    HighValueCustomer,
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_pct
FROM `telco-customer-churn`
GROUP BY
    Contract,
    HighValueCustomer,
    PaymentMethod
HAVING COUNT(*) >= 100
ORDER BY churn_rate_pct DESC;


WITH contract_churn AS (
    SELECT
        Contract,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            AS churned_customers,
        ROUND(
            100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            / COUNT(*),
            2
        ) AS churn_rate_pct
    FROM `telco-customer-churn`
    GROUP BY Contract
)
SELECT
    Contract,
    total_customers,
    churned_customers,
    churn_rate_pct,
    RANK() OVER (ORDER BY churn_rate_pct DESC) AS churn_rank
FROM contract_churn;


WITH overall AS (
    SELECT
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) AS overall_churn_rate
    FROM `telco-customer-churn`
),


SELECT
    c.Contract,
    c.total_customers,
    ROUND(c.contract_churn_rate, 2) AS contract_churn_pct,
    ROUND(o.overall_churn_rate, 2) AS overall_churn_pct,
    ROUND(
        c.contract_churn_rate - o.overall_churn_rate,
        2
    ) AS difference_percentage_points
FROM
(
    SELECT
        Contract,
        COUNT(*) AS total_customers,
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            / COUNT(*) AS contract_churn_rate
    FROM `telco-customer-churn`
    GROUP BY Contract
) AS c
CROSS JOIN
(
    SELECT
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
            / COUNT(*) AS overall_churn_rate
    FROM `telco-customer-churn`
) AS o
ORDER BY difference_percentage_points DESC;

