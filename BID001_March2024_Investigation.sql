-- ============================================================
-- BID-001: March 2024 Sales Data Quality Investigation
-- Nexus Financial Services (Pty) Ltd
-- Investigated by: Thabo Khoali (BI Developer)
-- Requested by: Priya Naidoo (Senior BI Developer)
-- Date: 2024-03-14
-- ============================================================

-- QUERY 1: Total Sales by Salesperson - March 2024
SELECT
    e.FirstName + ' ' + e.LastName AS SalespersonName,
    SUM(st.SaleAmount) AS TotalSales,
    COUNT(st.TransactionID) AS TotalTransactions
FROM dbo.SalesTransactions st
INNER JOIN dbo.Employees e
    ON st.SalespersonID = e.EmployeeID
WHERE st.SaleDate >= '2024-03-01'
  AND st.SaleDate < '2024-04-01'
GROUP BY e.FirstName, e.LastName
ORDER BY TotalSales DESC;

-- FINDING: Nhlanhla Ndlovu highest performer
-- R228,000 across 8 transactions

-- ============================================================

-- QUERY 2: NULL Check on SaleAmount - March 2024
SELECT
    TransactionID,
    SalespersonID,
    SaleDate,
    SaleAmount
FROM dbo.SalesTransactions
WHERE SaleAmount IS NULL
  AND SaleDate >= '2024-03-01'
  AND SaleDate < '2024-04-01';

-- FINDING: TransactionID 10027 has NULL SaleAmount
-- Date: 2024-03-14 | SalespersonID: 1013
-- IMPACT: Underreporting in SUM aggregations
-- ACTION: Escalated to Data Manager for correction approval

-- ============================================================

-- QUERY 3: Duplicate InvoiceNumber Check - March 2024
SELECT
    InvoiceNumber,
    COUNT(*) AS AppearanceCount
FROM dbo.SalesTransactions
WHERE SaleDate >= '2024-03-01'
  AND SaleDate < '2024-04-01'
GROUP BY InvoiceNumber
HAVING COUNT(*) > 1;

-- FINDING: INV-2024-0031 appeared twice
-- IMPACT: Inflated totals in finance reconciliation
-- ACTION: Escalated to Data Manager - ETL deduplication fix required

-- ============================================================
-- RESOLUTION SUMMARY
-- Root causes identified: NULL SaleAmount + Duplicate InvoiceNumber
-- Data correction request submitted to Nomsa Khumalo
-- Written approval obtained before remediation applied
-- Data governance process followed
-- ============================================================
