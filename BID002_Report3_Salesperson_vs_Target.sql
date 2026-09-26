-- ============================================================
-- BID-002 REPORT 3: Salesperson Performance vs Target
-- Nexus Financial Services (Pty) Ltd
-- Prepared by: Thabo Khoali (BI Developer)
-- Requested by: Nomsa Khumalo (BI Development Manager)
-- Delivered to: Yolanda Van der Berg (CFO)
-- Period: August 2024
-- ============================================================
-- TABLES USED:
-- MonthlyRevenueTarget  — target amounts per salesperson
-- Employees             — salesperson names
-- SalesTransactions     — actual revenue achieved
-- JOIN TYPE: 3-table INNER JOIN
-- ============================================================

SELECT
    e.FirstName + ' ' + e.LastName     AS SalespersonName,
    mrt.TargetAmount                    AS Target,
    SUM(st.NetAmount)                   AS ActualRevenue,
    mrt.TargetAmount - SUM(st.NetAmount) AS Variance
FROM MonthlyRevenueTarget mrt
INNER JOIN Employees e
    ON mrt.SalespersonID = e.EmployeeID
INNER JOIN SalesTransactions st
    ON mrt.SalespersonID = st.SalespersonID
WHERE mrt.TargetYear     = 2024
  AND mrt.TargetMonth    = 8
  AND MONTH(st.SaleDate) = 8
  AND YEAR(st.SaleDate)  = 2024
  AND st.Status          = 'Completed'
GROUP BY
    e.FirstName,
    e.LastName,
    mrt.TargetAmount;

-- ============================================================
-- RESULT SUMMARY
-- Salesperson:    Nhlanhla Ndlovu
-- Target:         R600,000
-- Actual Revenue: R110,000
-- Variance:       -R490,000 (below target)
-- ACTION:         Flagged for Sales Manager review
-- ============================================================
