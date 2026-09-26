# Nexus Financial Services — BI Developer Portfolio
### SQL Data Investigation & CFO Reporting Project
**Author:** Thabo Khoali | BI Developer  
**Location:** Midrand, Gauteng, South Africa  
**Tools:** SQL Server 2019 | SSMS | T-SQL | SSIS | Power BI  
**LinkedIn:** [linkedin.com/in/thabo-khoali-a5908857](https://linkedin.com/in/thabo-khoali-a5908857)

---

## 📌 Project Overview

This portfolio documents my work as a BI Developer at **Nexus Financial Services (Pty) Ltd** — a Johannesburg-based IT and financial services company. The project simulates real-world BI development tasks including data quality investigation, ETL monitoring, and CFO-level financial reporting.

The database was built on **SQL Server 2019** and mirrors the Microsoft BI stack used in enterprise environments — including SSIS pipelines, SSRS reporting infrastructure, and Power BI dashboards.

---

## 🏢 Company Background

**Nexus Financial Services** serves 24 corporate clients including Absa, Sasol, Nedbank, Standard Bank, Eskom and Discovery. The BI team supports:
- Monthly CFO revenue reporting packs
- ETL pipeline monitoring and data quality validation
- Salesperson performance vs target reporting
- Client support ticket SLA compliance reporting
- Finance and MI team data warehouse integrity

---

## 🗄️ Database Schema

The `NexusFinancialDB` database contains 15 tables across 7 business domains:

| Domain | Tables |
|--------|--------|
| Human Resources | Departments, Employees, LeaveRequests |
| Clients & Accounts | ClientSegments, Clients, ClientContacts |
| Products & Services | ProductCategories, Products |
| Sales & Revenue | SalesTransactions, MonthlyRevenueTarget, Invoices |
| IT Support | IncidentCategories, SupportTickets |
| ETL Monitoring | ETLJobs, ETLRunLog, DataQualityLog |
| Finance & MI | FinancialPeriods, GeneralLedger, BudgetAllocation |

---

## 📁 Project Tasks

---

### ✅ BID-001 — Data Quality Investigation
**Requested by:** Priya Naidoo (Senior BI Developer)  
**Business Problem:** The finance team flagged incorrect totals in the March 2024 sales report. Investigate and identify root causes.

**Investigation Findings:**

| Issue | Detail | Impact |
|-------|--------|--------|
| NULL SaleAmount | TransactionID 10027 — 2024-03-14 | Underreporting in SUM aggregations |
| Duplicate InvoiceNumber | INV-2024-0031 appeared twice | Inflated totals in finance reconciliation |
| Cancelled transaction | INV-2024-0028 included in totals | Overstated completed revenue |

**Query 1 — Total Sales by Salesperson, March 2024:**
```sql
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
```

**Result:** Nhlanhla Ndlovu — R228,000 across 8 transactions (top performer)

---

**Query 2 — NULL Check on SaleAmount:**
```sql
SELECT
    TransactionID,
    SalespersonID,
    SaleDate,
    SaleAmount
FROM dbo.SalesTransactions
WHERE SaleAmount IS NULL
  AND SaleDate >= '2024-03-01'
  AND SaleDate < '2024-04-01';
```

**Result:** 1 record found — TransactionID 10027, SalespersonID 1013, dated 2024-03-14

---

**Query 3 — Duplicate InvoiceNumber Check:**
```sql
SELECT
    InvoiceNumber,
    COUNT(*) AS AppearanceCount
FROM dbo.SalesTransactions
WHERE SaleDate >= '2024-03-01'
  AND SaleDate < '2024-04-01'
GROUP BY InvoiceNumber
HAVING COUNT(*) > 1;
```

**Result:** INV-2024-0031 appeared twice — duplicate identified and escalated to Data Manager

---

**Resolution:** Findings documented and submitted to Data Development Manager (Nomsa Khumalo) for written approval before any data correction was applied. Data governance process followed.

---

### ✅ BID-002 — CFO Month-End Revenue Pack (August 2024)
**Requested by:** Nomsa Khumalo (BI Development Manager)  
**Business Problem:** Produce the August 2024 month-end revenue pack for CFO Yolanda Van der Berg.

---

**Report 1 — Monthly Revenue by Region:**
```sql
SELECT
    Region,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(NetAmount) AS TotalRevenue
FROM SalesTransactions
WHERE YEAR(SaleDate) = 2024
  AND MONTH(SaleDate) = 8
  AND Status = 'Completed'
GROUP BY Region;
```

**Result:** Gauteng — 5 completed transactions, R156,000 total revenue

---

**Report 2 — Top 5 Clients by Revenue:**
```sql
SELECT TOP 5
    c.ClientName,
    c.IndustryType,
    SUM(st.NetAmount) AS Revenue
FROM Clients c
INNER JOIN SalesTransactions st
    ON c.ClientID = st.ClientID
WHERE st.Status = 'Completed'
  AND MONTH(st.SaleDate) = 8
  AND YEAR(st.SaleDate) = 2024
GROUP BY c.ClientName, c.IndustryType
ORDER BY Revenue DESC;
```

**Result:** Absa Group (R40,000), Sasol (R35,000), Momentum Metropolitan (R35,000), MiWay Insurance (R28,000), Netcare (R18,000)

---

**Report 3 — Salesperson Performance vs Target:**
```sql
SELECT
    e.FirstName + ' ' + e.LastName AS SalespersonName,
    mrt.TargetAmount,
    SUM(st.NetAmount) AS ActualRevenue,
    mrt.TargetAmount - SUM(st.NetAmount) AS Variance
FROM MonthlyRevenueTarget mrt
INNER JOIN Employees e
    ON mrt.SalespersonID = e.EmployeeID
INNER JOIN SalesTransactions st
    ON mrt.SalespersonID = st.SalespersonID
WHERE mrt.TargetYear = 2024
  AND mrt.TargetMonth = 8
  AND MONTH(st.SaleDate) = 8
  AND YEAR(st.SaleDate) = 2024
  AND st.Status = 'Completed'
GROUP BY e.FirstName, e.LastName, mrt.TargetAmount;
```

**Result:** Nhlanhla Ndlovu — Target R600,000 | Actual R110,000 | Variance -R490,000

---

**Report 4 — Product Category Performance:**
```sql
SELECT
    pc.CategoryName,
    SUM(st.NetAmount) AS TotalRevenue,
    COUNT(st.TransactionID) AS TotalTransactions
FROM ProductCategories pc
INNER JOIN Products p
    ON pc.CategoryID = p.CategoryID
INNER JOIN SalesTransactions st
    ON st.ProductID = p.ProductID
WHERE YEAR(st.SaleDate) = 2024
  AND MONTH(st.SaleDate) = 8
  AND st.Status = 'Completed'
GROUP BY pc.CategoryName
ORDER BY TotalRevenue DESC;
```

**Result:** Managed IT Services (R70,000) | Data & Analytics (R40,000) | Financial Software (R28,000) | Cybersecurity (R18,000)

---

## 🛠️ Technical Skills Demonstrated

| Skill | Application |
|-------|-------------|
| T-SQL Querying | SELECT, WHERE, GROUP BY, ORDER BY, HAVING |
| Aggregation Functions | SUM(), COUNT() for revenue and transaction reporting |
| INNER JOIN | 2 and 3 table joins across fact and dimension tables |
| Data Quality Investigation | NULL checks, duplicate detection, status validation |
| Date Filtering | YEAR(), MONTH() functions and date range filtering |
| Calculated Columns | Variance = Target minus Actual Revenue |
| ETL Awareness | SSIS pipeline monitoring, row count validation |
| Data Governance | Escalation process before executing data corrections |
| SQL Execution Order | FROM → WHERE → GROUP BY → SELECT → ORDER BY |

---

## 🏗️ Enterprise Tools & Environment

| Tool | Purpose |
|------|---------|
| SQL Server 2019 | Database engine |
| SSMS | Query writing and database management |
| SSIS | ETL pipeline data movement (Innovation Group experience) |
| SSRS | Reporting server support (Innovation Group experience) |
| Power BI | Dashboard and report support |
| Tableau | Business reporting support |
| FreshDesk / JIRA | Incident and development tracking |
| Visual Studio 2019 | SSIS package development environment |

---

## 💼 Professional Background

Before transitioning into BI Development I spent **8+ years as a Senior ICT Support Specialist at Innovation Group (Midrand)**, where from February 2023 I was embedded with the Data Development team:

- Executed daily SQL queries in SSMS alongside SQL Developers
- Supported SSIS ETL data movement from production to data warehouse
- Maintained data warehouse integrity for the MI reporting team
- Supported SSRS, Power BI and Tableau environments
- Supported finance BI applications including Ability Software, CIMS and CaseWare
- Confirmed by the Data Development Manager for a permanent BI Developer role

This portfolio represents the formal deepening of those skills through structured daily practice and real-world BI task simulation.

---

## 📂 Repository Structure

```
nexus-financial-bi-portfolio/
│
├── README.md                          — Project overview (this file)
│
├── database-setup/
│   └── NexusFinancialServices.sql     — Full database creation script
│
├── BID-001-data-quality/
│   └── BID001_March2024_Investigation.sql
│
├── BID-002-cfo-reporting/
│   ├── Report1_Revenue_by_Region.sql
│   ├── Report2_Top5_Clients.sql
│   ├── Report3_Salesperson_vs_Target.sql
│   └── Report4_Product_Category_Performance.sql
│
└── views/
    ├── vw_MonthlySalesSummary.sql
    ├── vw_SalespersonPerformance.sql
    ├── vw_ClientRevenueSummary.sql
    └── vw_DataQualityDashboard.sql
```

---

## 📬 Contact

**Thabo Khoali**  
BI Developer | SQL | Power BI | SSIS | Data Analytics  
📧 thaboboikei@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/thabo-khoali-a5908857)  
📍 Midrand, Gauteng, South Africa

---

*This portfolio is actively updated as new BI tasks and projects are completed.*
