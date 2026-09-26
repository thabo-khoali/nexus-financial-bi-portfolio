-- ============================================================
-- BID-002 REPORT 1: Monthly Revenue by Region
-- Nexus Financial Services (Pty) Ltd
-- Prepared by: Thabo Khoali (BI Developer)
-- Requested by: Nomsa Khumalo (BI Development Manager)
-- Delivered to: Yolanda Van der Berg (CFO)
-- Period: August 2024
-- ============================================================

SELECT
    Region,
    COUNT(TransactionID)    AS TotalTransactions,
    SUM(NetAmount)          AS TotalRevenue
FROM SalesTransactions
WHERE YEAR(SaleDate)  = 2024
  AND MONTH(SaleDate) = 8
  AND Status          = 'Completed'
GROUP BY Region
ORDER BY TotalRevenue DESC;

-- ============================================================
-- RESULT SUMMARY
-- Region:       Gauteng
-- Transactions: 5 completed
-- Revenue:      R156,000
-- ============================================================
