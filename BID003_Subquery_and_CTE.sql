-- ============================================================
-- BID-003: Subqueries and CTEs
-- Nexus Financial Services (Pty) Ltd
-- Prepared by: Thabo Khoali (BI Developer)
-- Requested by: Nomsa Khumalo (BI Development Manager)
-- ============================================================

-- TASK 1: Salespersons above the August 2024 average revenue
-- Technique: nested subqueries (innermost runs first)
SELECT
    SalesPerson,
    TotalRevenue
FROM (
    SELECT
        e.FirstName + ' ' + e.LastName AS SalesPerson,
        SUM(st.NetAmount) AS TotalRevenue
    FROM SalesTransactions st
    INNER JOIN Employees e
        ON e.EmployeeID = st.SalespersonID
    WHERE YEAR(st.SaleDate) = 2024
    AND MONTH(st.SaleDate) = 8
    AND st.Status = 'Completed'
    GROUP BY e.FirstName, e.LastName
) AS SalesPersonRevenue
WHERE TotalRevenue > (
    SELECT AVG(TotalRevenue)
    FROM (
        SELECT SUM(st2.NetAmount) AS TotalRevenue
        FROM SalesTransactions st2
        WHERE YEAR(st2.SaleDate) = 2024
        AND MONTH(st2.SaleDate) = 8
        AND st2.Status = 'Completed'
        GROUP BY st2.SalespersonID
    ) AS AvgCalc
)
ORDER BY TotalRevenue DESC;

-- RESULT: Nhlanhla Ndlovu, R110,000 (average was R52,000)

-- ============================================================

-- TASK 2: Client value segmentation using a CTE
-- Technique: CTE + CASE statement
WITH ClientRevenue AS (
    SELECT
        c.ClientName,
        SUM(st.NetAmount) AS Total_Revenue
    FROM Clients c
    INNER JOIN SalesTransactions st
        ON c.ClientID = st.ClientID
    WHERE YEAR(st.SaleDate) = 2024
    AND st.Status = 'Completed'
    GROUP BY c.ClientName
)
SELECT
    ClientName,
    Total_Revenue,
    CASE
        WHEN Total_Revenue > 100000 THEN 'High Value'
        ELSE 'Standard'
    END AS ClientCategory
FROM ClientRevenue
ORDER BY Total_Revenue DESC;

-- RESULT: 23 clients. 14 High Value (above R100,000), 9 Standard
-- ============================================================
