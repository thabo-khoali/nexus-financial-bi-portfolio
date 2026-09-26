-- ============================================================
-- BID-002 REPORT 2: Top 5 Clients by Revenue
-- Nexus Financial Services (Pty) Ltd
-- Prepared by: Thabo Khoali (BI Developer)
-- Requested by: Nomsa Khumalo (BI Development Manager)
-- Delivered to: Yolanda Van der Berg (CFO)
-- Period: August 2024
-- ============================================================

SELECT TOP 5
    c.ClientName,
    c.IndustryType,
    SUM(st.NetAmount)           AS TotalRevenue
FROM Clients c
INNER JOIN SalesTransactions st
    ON c.ClientID = st.ClientID
WHERE st.Status          = 'Completed'
  AND MONTH(st.SaleDate) = 8
  AND YEAR(st.SaleDate)  = 2024
GROUP BY c.ClientName, c.IndustryType
ORDER BY TotalRevenue DESC;

-- ============================================================
-- RESULT SUMMARY
-- 1. Absa Group Limited      — R40,000  (Banking & Finance)
-- 2. Sasol Limited           — R35,000  (Energy & Chemicals)
-- 3. Momentum Metropolitan   — R35,000  (Insurance & Finance)
-- 4. MiWay Insurance         — R28,000  (Insurance)
-- 5. Netcare Limited         — R18,000  (Healthcare)
-- ============================================================
