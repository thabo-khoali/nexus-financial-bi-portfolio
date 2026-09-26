-- ============================================================
-- BID-002 REPORT 4: Product Category Performance
-- Nexus Financial Services (Pty) Ltd
-- Prepared by: Thabo Khoali (BI Developer)
-- Requested by: Nomsa Khumalo (BI Development Manager)
-- Delivered to: Yolanda Van der Berg (CFO)
-- Period: August 2024
-- ============================================================
-- TABLES USED:
-- ProductCategories    — category names
-- Products             — links transactions to categories
-- SalesTransactions    — actual revenue per product
-- JOIN TYPE: 3-table INNER JOIN
-- ============================================================

SELECT
    pc.CategoryName,
    SUM(st.NetAmount)           AS TotalRevenue,
    COUNT(st.TransactionID)     AS TotalTransactions
FROM ProductCategories pc
INNER JOIN Products p
    ON pc.CategoryID = p.CategoryID
INNER JOIN SalesTransactions st
    ON st.ProductID = p.ProductID
WHERE YEAR(st.SaleDate)  = 2024
  AND MONTH(st.SaleDate) = 8
  AND st.Status          = 'Completed'
GROUP BY pc.CategoryName
ORDER BY TotalRevenue DESC;

-- ============================================================
-- RESULT SUMMARY
-- 1. Managed IT Services  — R70,000  | 2 transactions
-- 2. Data & Analytics     — R40,000  | 1 transaction
-- 3. Financial Software   — R28,000  | 1 transaction
-- 4. Cybersecurity        — R18,000  | 1 transaction
--
-- INSIGHT: Managed IT Services is top revenue category
-- for August 2024. Data & Analytics growing strongly.
-- ============================================================
