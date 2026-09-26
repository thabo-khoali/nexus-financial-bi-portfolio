-- ============================================================
-- NEXUS FINANCIAL SERVICES (PTY) LTD
-- Johannesburg, Gauteng | EST. 2005
-- BI Developer Practice Database
-- SQL Server 2019 | Created by: Thabo Khoali
-- ============================================================
-- HOW TO USE:
-- 1. Open SSMS and connect to your local SQL Server instance
-- 2. Click "New Query"
-- 3. Paste this entire script and press F5 (Execute)
-- 4. The database "NexusFinancialDB" will be created automatically
-- 5. Refresh your Object Explorer to see it appear
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NexusFinancialDB')
BEGIN
    ALTER DATABASE NexusFinancialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NexusFinancialDB;
END
GO

CREATE DATABASE NexusFinancialDB;
GO

USE NexusFinancialDB;
GO

-- ============================================================
-- SECTION 1: HUMAN RESOURCES (HR)
-- ============================================================

CREATE TABLE Departments (
    DepartmentID        INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName      VARCHAR(100) NOT NULL,
    DivisionName        VARCHAR(100),
    CostCentre          VARCHAR(20),
    HeadOfficeLocation  VARCHAR(50),
    IsActive            BIT DEFAULT 1
);

CREATE TABLE Employees (
    EmployeeID          INT PRIMARY KEY IDENTITY(1001,1),
    FirstName           VARCHAR(50) NOT NULL,
    LastName            VARCHAR(50) NOT NULL,
    IDNumber            VARCHAR(13),
    JobTitle            VARCHAR(100),
    DepartmentID        INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    ManagerID           INT,
    EmploymentType      VARCHAR(20),   -- Permanent, Contract, Intern
    StartDate           DATE,
    EndDate             DATE NULL,
    Salary              DECIMAL(10,2),
    Region              VARCHAR(50),
    Email               VARCHAR(100),
    IsActive            BIT DEFAULT 1
);

CREATE TABLE LeaveRequests (
    LeaveID             INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID          INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    LeaveType           VARCHAR(30),   -- Annual, Sick, Family
    StartDate           DATE,
    EndDate             DATE,
    DaysRequested       INT,
    Status              VARCHAR(20),   -- Approved, Pending, Rejected
    ApprovedByID        INT,
    RequestDate         DATE
);

-- ============================================================
-- SECTION 2: CLIENTS & ACCOUNTS
-- ============================================================

CREATE TABLE ClientSegments (
    SegmentID           INT PRIMARY KEY IDENTITY(1,1),
    SegmentName         VARCHAR(50),   -- Retail, Corporate, SME, Government
    Description         VARCHAR(200)
);

CREATE TABLE Clients (
    ClientID            INT PRIMARY KEY IDENTITY(2001,1),
    ClientName          VARCHAR(150) NOT NULL,
    RegistrationNumber  VARCHAR(30),
    SegmentID           INT FOREIGN KEY REFERENCES ClientSegments(SegmentID),
    IndustryType        VARCHAR(100),
    Region              VARCHAR(50),
    Province            VARCHAR(50),
    AccountManagerID    INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    OnboardingDate      DATE,
    ContractValue       DECIMAL(15,2),
    ContractEndDate     DATE,
    Status              VARCHAR(20),   -- Active, Churned, Suspended
    CreditRating        VARCHAR(5)
);

CREATE TABLE ClientContacts (
    ContactID           INT PRIMARY KEY IDENTITY(1,1),
    ClientID            INT FOREIGN KEY REFERENCES Clients(ClientID),
    ContactName         VARCHAR(100),
    ContactRole         VARCHAR(100),
    Email               VARCHAR(100),
    Phone               VARCHAR(20),
    IsPrimary           BIT DEFAULT 0
);

-- ============================================================
-- SECTION 3: PRODUCTS & SERVICES
-- ============================================================

CREATE TABLE ProductCategories (
    CategoryID          INT PRIMARY KEY IDENTITY(1,1),
    CategoryName        VARCHAR(100),
    Description         VARCHAR(200)
);

CREATE TABLE Products (
    ProductID           INT PRIMARY KEY IDENTITY(101,1),
    ProductName         VARCHAR(150),
    CategoryID          INT FOREIGN KEY REFERENCES ProductCategories(CategoryID),
    UnitPrice           DECIMAL(10,2),
    BillingType         VARCHAR(30),   -- Monthly, Annual, Once-off, Per Transaction
    IsActive            BIT DEFAULT 1,
    LaunchDate          DATE
);

-- ============================================================
-- SECTION 4: SALES & REVENUE (Core BI Tables)
-- ============================================================

CREATE TABLE SalesTransactions (
    TransactionID       INT PRIMARY KEY IDENTITY(10001,1),
    ClientID            INT FOREIGN KEY REFERENCES Clients(ClientID),
    ProductID           INT FOREIGN KEY REFERENCES Products(ProductID),
    SalespersonID       INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    SaleDate            DATE,
    SaleAmount          DECIMAL(12,2),
    DiscountPercentage  DECIMAL(5,2) DEFAULT 0,
    NetAmount           DECIMAL(12,2),
    Region              VARCHAR(50),
    Status              VARCHAR(20),   -- Completed, Cancelled, Pending, Reversed
    InvoiceNumber       VARCHAR(30),
    PaymentMethod       VARCHAR(30),   -- EFT, Credit Card, Debit Order
    FinancialYear       VARCHAR(10),
    FinancialQuarter    VARCHAR(5)
);

CREATE TABLE MonthlyRevenueTarget (
    TargetID            INT PRIMARY KEY IDENTITY(1,1),
    DepartmentID        INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    SalespersonID       INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    TargetYear          INT,
    TargetMonth         INT,
    TargetAmount        DECIMAL(12,2),
    Region              VARCHAR(50)
);

CREATE TABLE Invoices (
    InvoiceID           INT PRIMARY KEY IDENTITY(1,1),
    InvoiceNumber       VARCHAR(30) UNIQUE,
    ClientID            INT FOREIGN KEY REFERENCES Clients(ClientID),
    TransactionID       INT FOREIGN KEY REFERENCES SalesTransactions(TransactionID),
    InvoiceDate         DATE,
    DueDate             DATE,
    InvoiceAmount       DECIMAL(12,2),
    PaidAmount          DECIMAL(12,2) DEFAULT 0,
    OutstandingAmount   AS (InvoiceAmount - PaidAmount),
    PaymentDate         DATE NULL,
    Status              VARCHAR(20),   -- Paid, Overdue, Partial, Cancelled
    AgeingBucket        VARCHAR(20)    -- Current, 30 Days, 60 Days, 90+ Days
);

-- ============================================================
-- SECTION 5: IT SUPPORT & INCIDENTS (Your Specialist Area)
-- ============================================================

CREATE TABLE IncidentCategories (
    CategoryID          INT PRIMARY KEY IDENTITY(1,1),
    CategoryName        VARCHAR(100),
    SLAHours            INT            -- Response SLA in hours
);

CREATE TABLE SupportTickets (
    TicketID            INT PRIMARY KEY IDENTITY(20001,1),
    TicketReference     VARCHAR(20),
    ClientID            INT FOREIGN KEY REFERENCES Clients(ClientID),
    AssignedToID        INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    CategoryID          INT FOREIGN KEY REFERENCES IncidentCategories(CategoryID),
    Priority            VARCHAR(10),   -- Critical, High, Medium, Low
    Subject             VARCHAR(200),
    Description         VARCHAR(1000),
    Status              VARCHAR(20),   -- Open, In Progress, Resolved, Closed, Escalated
    LoggedDate          DATETIME,
    FirstResponseDate   DATETIME NULL,
    ResolvedDate        DATETIME NULL,
    ClosedDate          DATETIME NULL,
    SLABreached         BIT DEFAULT 0,
    ResolutionCode      VARCHAR(50),
    CustomerSatisfaction INT NULL       -- 1-5 rating
);

-- ============================================================
-- SECTION 6: DATA WAREHOUSE / ETL MONITORING
-- (Mirrors what you did at Innovation Group)
-- ============================================================

CREATE TABLE ETLJobs (
    JobID               INT PRIMARY KEY IDENTITY(1,1),
    JobName             VARCHAR(150),
    SourceSystem        VARCHAR(100),
    DestinationTable    VARCHAR(150),
    ScheduleType        VARCHAR(20),   -- Daily, Monthly, On-Demand
    IsActive            BIT DEFAULT 1
);

CREATE TABLE ETLRunLog (
    RunID               INT PRIMARY KEY IDENTITY(1,1),
    JobID               INT FOREIGN KEY REFERENCES ETLJobs(JobID),
    RunDate             DATETIME,
    StartTime           DATETIME,
    EndTime             DATETIME NULL,
    RowsExtracted       INT DEFAULT 0,
    RowsLoaded          INT DEFAULT 0,
    RowsRejected        INT DEFAULT 0,
    Status              VARCHAR(20),   -- Success, Failed, Running, Partial
    ErrorMessage        VARCHAR(500) NULL,
    RunByUserID         INT
);

CREATE TABLE DataQualityLog (
    QualityID           INT PRIMARY KEY IDENTITY(1,1),
    TableName           VARCHAR(150),
    CheckDate           DATE,
    CheckType           VARCHAR(100),  -- NULL Check, Duplicate Check, Range Check
    RecordsChecked      INT,
    RecordsFailed       INT,
    FailurePercentage   AS (CAST(RecordsFailed AS DECIMAL(10,2)) / NULLIF(RecordsChecked,0) * 100),
    Severity            VARCHAR(20),   -- Low, Medium, High, Critical
    ResolvedDate        DATE NULL,
    Notes               VARCHAR(500)
);

-- ============================================================
-- SECTION 7: FINANCE & MI REPORTING
-- (Mirrors the MI team you supported)
-- ============================================================

CREATE TABLE FinancialPeriods (
    PeriodID            INT PRIMARY KEY IDENTITY(1,1),
    PeriodName          VARCHAR(30),   -- e.g. 'March 2024'
    PeriodYear          INT,
    PeriodMonth         INT,
    StartDate           DATE,
    EndDate             DATE,
    IsMonthEnd          BIT DEFAULT 0,
    IsClosed            BIT DEFAULT 0
);

CREATE TABLE GeneralLedger (
    LedgerID            INT PRIMARY KEY IDENTITY(1,1),
    PeriodID            INT FOREIGN KEY REFERENCES FinancialPeriods(PeriodID),
    AccountCode         VARCHAR(20),
    AccountName         VARCHAR(150),
    AccountType         VARCHAR(30),   -- Revenue, Expense, Asset, Liability
    DepartmentID        INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    DebitAmount         DECIMAL(15,2) DEFAULT 0,
    CreditAmount        DECIMAL(15,2) DEFAULT 0,
    PostingDate         DATE,
    PostedByID          INT,
    Reference           VARCHAR(50),
    Description         VARCHAR(200)
);

CREATE TABLE BudgetAllocation (
    BudgetID            INT PRIMARY KEY IDENTITY(1,1),
    PeriodID            INT FOREIGN KEY REFERENCES FinancialPeriods(PeriodID),
    DepartmentID        INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    AccountCode         VARCHAR(20),
    BudgetAmount        DECIMAL(15,2),
    RevisedBudget       DECIMAL(15,2) NULL,
    ApprovedByID        INT,
    Notes               VARCHAR(300)
);

-- ============================================================
-- SECTION 8: INSERT REFERENCE DATA
-- ============================================================

INSERT INTO Departments (DepartmentName, DivisionName, CostCentre, HeadOfficeLocation) VALUES
('BI & Data Development',       'Technology',        'CC-001', 'Sandton'),
('IT Operations & Support',     'Technology',        'CC-002', 'Midrand'),
('Sales - Corporate',           'Revenue',           'CC-003', 'Sandton'),
('Sales - Retail & SME',        'Revenue',           'CC-004', 'Johannesburg CBD'),
('Finance & MI Reporting',      'Finance',           'CC-005', 'Sandton'),
('Risk & Compliance',           'Governance',        'CC-006', 'Sandton'),
('Human Resources',             'Support Services',  'CC-007', 'Midrand'),
('Client Services',             'Operations',        'CC-008', 'Johannesburg CBD'),
('Executive',                   'Group',             'CC-009', 'Sandton');

INSERT INTO ClientSegments (SegmentName, Description) VALUES
('Corporate',    'Large enterprises with revenue above R500m'),
('SME',          'Small and medium enterprises'),
('Retail',       'Individual and consumer clients'),
('Government',   'Public sector and SOEs'),
('International','Foreign-based clients operating in SA');

INSERT INTO ProductCategories (CategoryName, Description) VALUES
('Managed IT Services',     'End-to-end IT infrastructure management'),
('Business Intelligence',   'BI tools, dashboards and reporting solutions'),
('Cloud Solutions',         'Cloud hosting, migration and support'),
('Financial Software',      'Accounting, ERP and financial management tools'),
('Cybersecurity',           'Security monitoring, compliance and advisory'),
('Data & Analytics',        'Data warehousing, ETL and analytics services'),
('Professional Services',   'Consulting, training and implementation');

INSERT INTO Products (ProductName, CategoryID, UnitPrice, BillingType, LaunchDate) VALUES
('Managed IT Support - Basic',          1,  15000.00, 'Monthly',      '2010-01-01'),
('Managed IT Support - Premium',        1,  35000.00, 'Monthly',      '2010-01-01'),
('Power BI Implementation',             2,  80000.00, 'Once-off',     '2018-03-01'),
('Power BI Support & Licensing',        2,   8500.00, 'Monthly',      '2018-03-01'),
('Tableau Licensing & Support',         2,  12000.00, 'Monthly',      '2016-06-01'),
('Azure Cloud Hosting',                 3,  22000.00, 'Monthly',      '2019-01-01'),
('Cloud Migration Project',             3, 150000.00, 'Once-off',     '2019-01-01'),
('Ability Financial Software',          4,  45000.00, 'Annual',       '2012-05-01'),
('CaseWare Audit Solution',             4,  38000.00, 'Annual',       '2013-01-01'),
('CIMS Compliance Manager',             4,  28000.00, 'Annual',       '2014-03-01'),
('Cybersecurity Monitoring',            5,  18000.00, 'Monthly',      '2020-01-01'),
('Penetration Testing',                 5,  55000.00, 'Once-off',     '2020-01-01'),
('Data Warehouse Build',                6, 250000.00, 'Once-off',     '2015-01-01'),
('ETL Pipeline Development',            6,  90000.00, 'Once-off',     '2015-01-01'),
('SSRS Report Development',             6,  40000.00, 'Once-off',     '2015-01-01'),
('BI Consulting (Daily Rate)',          7,   8500.00, 'Per Transaction','2010-01-01'),
('SQL Training & Workshops',            7,  12000.00, 'Once-off',     '2017-01-01');

INSERT INTO IncidentCategories (CategoryName, SLAHours) VALUES
('System Outage',           2),
('Application Error',       4),
('Data Quality Issue',      8),
('Performance Degradation', 4),
('Access & Permissions',    8),
('Report Failure',          4),
('ETL / Data Load Failure', 4),
('Hardware Fault',          8),
('Network Issue',           4),
('General IT Request',      24);

INSERT INTO FinancialPeriods (PeriodName, PeriodYear, PeriodMonth, StartDate, EndDate, IsMonthEnd, IsClosed) VALUES
('January 2024',    2024, 1,  '2024-01-01', '2024-01-31', 1, 1),
('February 2024',   2024, 2,  '2024-02-01', '2024-02-29', 1, 1),
('March 2024',      2024, 3,  '2024-03-01', '2024-03-31', 1, 1),
('April 2024',      2024, 4,  '2024-04-01', '2024-04-30', 1, 1),
('May 2024',        2024, 5,  '2024-05-01', '2024-05-31', 1, 1),
('June 2024',       2024, 6,  '2024-06-01', '2024-06-30', 1, 1),
('July 2024',       2024, 7,  '2024-07-01', '2024-07-31', 1, 1),
('August 2024',     2024, 8,  '2024-08-01', '2024-08-31', 1, 1),
('September 2024',  2024, 9,  '2024-09-01', '2024-09-30', 1, 1),
('October 2024',    2024, 10, '2024-10-01', '2024-10-31', 1, 1),
('November 2024',   2024, 11, '2024-11-01', '2024-11-30', 1, 1),
('December 2024',   2024, 12, '2024-12-01', '2024-12-31', 1, 1),
('January 2025',    2025, 1,  '2025-01-01', '2025-01-31', 1, 1),
('February 2025',   2025, 2,  '2025-02-01', '2025-02-28', 1, 1),
('March 2025',      2025, 3,  '2025-03-01', '2025-03-31', 1, 1);

-- ============================================================
-- SECTION 9: EMPLOYEES (Realistic SA names, your team)
-- ============================================================

INSERT INTO Employees (FirstName, LastName, JobTitle, DepartmentID, ManagerID, EmploymentType, StartDate, Salary, Region, Email, IsActive) VALUES
-- Executive
('Sipho',       'Dlamini',      'Chief Executive Officer',          9, NULL,   'Permanent', '2010-03-01', 185000.00, 'Gauteng', 'sdlamini@nexusfs.co.za',       1),
('Yolanda',     'Van der Berg', 'Chief Financial Officer',          5, NULL,   'Permanent', '2012-01-15', 165000.00, 'Gauteng', 'yvanderberg@nexusfs.co.za',    1),
('Rajesh',      'Pillay',       'Chief Technology Officer',         1, NULL,   'Permanent', '2011-06-01', 170000.00, 'Gauteng', 'rpillay@nexusfs.co.za',        1),
-- BI & Data Team
('Nomsa',       'Khumalo',      'BI Development Manager',           1, 1003,   'Permanent', '2015-02-01', 120000.00, 'Gauteng', 'nkhumalo@nexusfs.co.za',       1),
('Yasaar',      'Peck',         'Senior SQL Developer',             1, 1004,   'Permanent', '2017-08-01', 98000.00,  'Gauteng', 'ypeck@nexusfs.co.za',          1),
('Thabo',       'Khoali',       'BI Developer',                     1, 1004,   'Permanent', '2024-01-15', 72000.00,  'Gauteng', 'tkhoali@nexusfs.co.za',        1),
('Priya',       'Naidoo',       'Senior BI Developer',              1, 1004,   'Permanent', '2019-03-01', 105000.00, 'Gauteng', 'pnaidoo@nexusfs.co.za',        1),
('Lebo',        'Mokoena',      'Data Analyst',                     1, 1004,   'Permanent', '2020-07-01', 68000.00,  'Gauteng', 'lmokoena@nexusfs.co.za',       1),
-- IT Operations & Support
('Andre',       'Pieterse',     'IT Operations Manager',            2, 1003,   'Permanent', '2013-05-01', 95000.00,  'Gauteng', 'apieterse@nexusfs.co.za',      1),
('Zanele',      'Sithole',      'Senior ICT Support Specialist',    2, 1009,   'Permanent', '2016-04-01', 58000.00,  'Gauteng', 'zsithole@nexusfs.co.za',       1),
('Mpho',        'Molefe',       'ICT Support Technician',           2, 1009,   'Permanent', '2019-01-01', 38000.00,  'Gauteng', 'mmolefe@nexusfs.co.za',        1),
-- Sales - Corporate
('Chantelle',   'Mostert',      'Corporate Sales Manager',          3, 1001,   'Permanent', '2014-09-01', 85000.00,  'Gauteng', 'cmostert@nexusfs.co.za',       1),
('Nhlanhla',    'Ndlovu',       'Senior Account Executive',         3, 1012,   'Permanent', '2016-11-01', 62000.00,  'Gauteng', 'nndlovu@nexusfs.co.za',        1),
('Keegan',      'Phillips',     'Account Executive',                3, 1012,   'Permanent', '2020-02-01', 48000.00,  'Western Cape', 'kphillips@nexusfs.co.za', 1),
('Ayanda',      'Mthembu',      'Account Executive',                3, 1012,   'Permanent', '2021-05-01', 45000.00,  'KwaZulu-Natal', 'amthembu@nexusfs.co.za', 1),
-- Sales - Retail & SME
('Fatima',      'Moosa',        'SME Sales Manager',                4, 1001,   'Permanent', '2015-03-01', 78000.00,  'Gauteng', 'fmoosa@nexusfs.co.za',         1),
('Deon',        'Jacobs',       'SME Account Executive',            4, 1016,   'Permanent', '2018-07-01', 44000.00,  'Gauteng', 'djacobs@nexusfs.co.za',        1),
('Palesa',      'Tau',          'SME Account Executive',            4, 1016,   'Permanent', '2021-01-01', 40000.00,  'Gauteng', 'ptau@nexusfs.co.za',           1),
-- Finance & MI
('Bronwyn',     'September',    'MI Reporting Analyst',             5, 1002,   'Permanent', '2016-06-01', 75000.00,  'Gauteng', 'bseptember@nexusfs.co.za',     1),
('Siyanda',     'Mhlanga',      'Financial Accountant',             5, 1002,   'Permanent', '2018-03-01', 70000.00,  'Gauteng', 'smhlanga@nexusfs.co.za',       1),
-- HR
('Thandeka',    'Zwane',        'HR Manager',                       7, 1001,   'Permanent', '2013-08-01', 82000.00,  'Gauteng', 'tzwane@nexusfs.co.za',         1),
-- Client Services
('Marco',       'Da Silva',     'Client Services Manager',          8, 1001,   'Permanent', '2014-02-01', 80000.00,  'Gauteng', 'mdasilva@nexusfs.co.za',       1);

-- Update ManagerIDs now that employees exist
UPDATE Employees SET ManagerID = 1001 WHERE EmployeeID IN (1002, 1003, 1021, 1022);
UPDATE Employees SET ManagerID = 1004 WHERE EmployeeID IN (1005, 1006, 1007, 1008);

-- ============================================================
-- SECTION 10: CLIENTS (Realistic SA companies)
-- ============================================================

INSERT INTO Clients (ClientName, RegistrationNumber, SegmentID, IndustryType, Region, Province, AccountManagerID, OnboardingDate, ContractValue, ContractEndDate, Status, CreditRating) VALUES
('Absa Group Limited',              '1986/004794/06', 1, 'Banking & Finance',        'Johannesburg', 'Gauteng',       1013, '2015-03-01', 2400000.00, '2025-03-31', 'Active',    'AA'),
('Sasol Limited',                   '1979/003231/06', 1, 'Energy & Chemicals',       'Johannesburg', 'Gauteng',       1013, '2016-07-01', 1800000.00, '2025-06-30', 'Active',    'AA'),
('Shoprite Holdings',               '1936/007721/06', 1, 'Retail',                   'Cape Town',    'Western Cape',  1014, '2017-01-15', 1200000.00, '2025-01-14', 'Active',    'A+'),
('Nedbank Group',                   '1966/010630/06', 1, 'Banking & Finance',        'Johannesburg', 'Gauteng',       1013, '2018-04-01', 960000.00,  '2025-03-31', 'Active',    'AA'),
('Transnet SOC Ltd',                '1990/000900/30', 4, 'Logistics & Transport',    'Johannesburg', 'Gauteng',       1013, '2019-02-01', 780000.00,  '2025-01-31', 'Active',    'A'),
('City of Johannesburg',            '2000/028627/30', 4, 'Local Government',         'Johannesburg', 'Gauteng',       1015, '2020-06-01', 540000.00,  '2025-05-31', 'Active',    'B+'),
('Clicks Group Limited',            '1968/008745/06', 2, 'Retail & Pharmacy',        'Cape Town',    'Western Cape',  1014, '2018-11-01', 360000.00,  '2025-10-31', 'Active',    'A'),
('Tiger Brands Limited',            '1944/017881/06', 1, 'FMCG',                     'Johannesburg', 'Gauteng',       1013, '2020-01-15', 480000.00,  '2025-01-14', 'Active',    'A+'),
('Netcare Limited',                 '1996/008242/06', 1, 'Healthcare',               'Johannesburg', 'Gauteng',       1015, '2019-08-01', 720000.00,  '2025-07-31', 'Active',    'A'),
('Standard Bank Group',             '1969/017128/06', 1, 'Banking & Finance',        'Johannesburg', 'Gauteng',       1013, '2016-05-01', 1560000.00, '2025-04-30', 'Active',    'AA'),
('Discovery Limited',               '1999/007789/06', 1, 'Insurance & Healthcare',   'Johannesburg', 'Gauteng',       1015, '2021-02-01', 840000.00,  '2026-01-31', 'Active',    'A+'),
('Pick n Pay Stores',               '1968/008034/06', 1, 'Retail',                   'Cape Town',    'Western Cape',  1014, '2017-09-01', 420000.00,  '2024-08-31', 'Churned',   'A'),
('Kumba Iron Ore',                  '2005/015852/06', 1, 'Mining',                   'Johannesburg', 'Gauteng',       1013, '2020-03-01', 660000.00,  '2025-02-28', 'Active',    'A'),
('Eskom Holdings SOC',              '2002/015527/30', 4, 'Energy & Utilities',       'Johannesburg', 'Gauteng',       1015, '2018-01-01', 900000.00,  '2025-12-31', 'Active',    'B'),
('Sanlam Limited',                  '1959/001562/06', 1, 'Insurance & Finance',      'Cape Town',    'Western Cape',  1014, '2019-10-01', 1080000.00, '2025-09-30', 'Active',    'AA'),
('Nando''s SA (Pty) Ltd',           '1987/004302/07', 2, 'Food & Beverage',          'Johannesburg', 'Gauteng',       1017, '2022-04-01', 180000.00,  '2025-03-31', 'Active',    'A-'),
('Bidvest Group Limited',           '1946/021180/06', 1, 'Diversified Services',     'Johannesburg', 'Gauteng',       1013, '2015-11-01', 1320000.00, '2025-10-31', 'Active',    'A+'),
('Sun International Limited',       '1967/007528/06', 1, 'Hospitality & Gaming',     'Johannesburg', 'Gauteng',       1015, '2021-07-01', 360000.00,  '2026-06-30', 'Active',    'A-'),
('Momentum Metropolitan',           '1904/002186/06', 1, 'Insurance & Finance',      'Pretoria',     'Gauteng',       1013, '2020-09-01', 780000.00,  '2025-08-31', 'Active',    'A+'),
('Afrimat Limited',                 '2006/022534/06', 2, 'Construction Materials',   'Cape Town',    'Western Cape',  1017, '2022-10-01', 240000.00,  '2025-09-30', 'Active',    'A'),
('Tsebo Solutions Group',           '1970/002871/07', 2, 'Facilities Management',    'Johannesburg', 'Gauteng',       1018, '2023-01-15', 156000.00,  '2025-01-14', 'Active',    'B+'),
('MiWay Insurance',                 '2006/021972/06', 2, 'Insurance',                'Pretoria',     'Gauteng',       1018, '2022-07-01', 216000.00,  '2025-06-30', 'Active',    'A-'),
('Vumatel (Pty) Ltd',               '2013/019421/07', 2, 'Telecommunications',       'Johannesburg', 'Gauteng',       1017, '2023-03-01', 192000.00,  '2025-02-28', 'Active',    'B+'),
('Pepkor Holdings',                 '2017/221869/06', 1, 'Retail',                   'Cape Town',    'Western Cape',  1014, '2019-06-01', 600000.00,  '2025-05-31', 'Active',    'A');

-- ============================================================
-- SECTION 11: SALES TRANSACTIONS (2024 full year + 2025 Q1)
-- Realistic data with intentional data quality issues to find
-- ============================================================

-- Helper: Generate transactions across 2024
INSERT INTO SalesTransactions (ClientID, ProductID, SalespersonID, SaleDate, SaleAmount, DiscountPercentage, NetAmount, Region, Status, InvoiceNumber, PaymentMethod, FinancialYear, FinancialQuarter) VALUES
-- January 2024
(2001, 101, 1013, '2024-01-05', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0001', 'EFT',         '2024', 'Q1'),
(2002, 113, 1013, '2024-01-08', 250000.00,5,    237500.00,'Gauteng',       'Completed', 'INV-2024-0002', 'EFT',         '2024', 'Q1'),
(2003, 103, 1014, '2024-01-10', 80000.00, 10,   72000.00, 'Western Cape',  'Completed', 'INV-2024-0003', 'EFT',         '2024', 'Q1'),
(2010, 102, 1013, '2024-01-12', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0004', 'Debit Order', '2024', 'Q1'),
(2004, 108, 1015, '2024-01-15', 45000.00, 5,    42750.00, 'Gauteng',       'Completed', 'INV-2024-0005', 'EFT',         '2024', 'Q1'),
(2005, 101, 1013, '2024-01-18', 15000.00, 0,    15000.00, 'Gauteng',       'Completed', 'INV-2024-0006', 'Debit Order', '2024', 'Q1'),
(2011, 104, 1015, '2024-01-22', 8500.00,  0,    8500.00,  'Gauteng',       'Completed', 'INV-2024-0007', 'Debit Order', '2024', 'Q1'),
(2015, 103, 1014, '2024-01-25', 80000.00, 15,   68000.00, 'Western Cape',  'Completed', 'INV-2024-0008', 'EFT',         '2024', 'Q1'),
(2017, 102, 1013, '2024-01-28', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0009', 'Debit Order', '2024', 'Q1'),
(2021, 101, 1017, '2024-01-30', 15000.00, 0,    15000.00, 'Gauteng',       'Completed', 'INV-2024-0010', 'EFT',         '2024', 'Q1'),
-- February 2024
(2001, 102, 1013, '2024-02-02', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0011', 'EFT',         '2024', 'Q1'),
(2009, 111, 1015, '2024-02-05', 18000.00, 0,    18000.00, 'Gauteng',       'Completed', 'INV-2024-0012', 'Debit Order', '2024', 'Q1'),
(2013, 114, 1013, '2024-02-08', 90000.00, 5,    85500.00, 'Gauteng',       'Completed', 'INV-2024-0013', 'EFT',         '2024', 'Q1'),
(2006, 101, 1015, '2024-02-12', 15000.00, 0,    15000.00, 'Gauteng',       'Completed', 'INV-2024-0014', 'EFT',         '2024', 'Q1'),
(2016, 101, 1017, '2024-02-14', 15000.00, 0,    15000.00, 'Gauteng',       'Completed', 'INV-2024-0015', 'EFT',         '2024', 'Q1'),
(2024, 109, 1014, '2024-02-18', 38000.00, 10,   34200.00, 'Western Cape',  'Completed', 'INV-2024-0016', 'EFT',         '2024', 'Q1'),
(2007, 106, 1014, '2024-02-20', 22000.00, 0,    22000.00, 'Western Cape',  'Completed', 'INV-2024-0017', 'Debit Order', '2024', 'Q1'),
(2019, 102, 1013, '2024-02-25', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0018', 'EFT',         '2024', 'Q1'),
(2022, 110, 1018, '2024-02-27', 28000.00, 0,    28000.00, 'Gauteng',       'Completed', 'INV-2024-0019', 'EFT',         '2024', 'Q1'),
-- March 2024 (intentional issues: 1 NULL, 1 duplicate TransactionID effect, 1 cancelled)
(2001, 102, 1013, '2024-03-01', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0020', 'EFT',         '2024', 'Q1'),
(2002, 102, 1013, '2024-03-03', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0021', 'EFT',         '2024', 'Q1'),
(2003, 105, 1014, '2024-03-05', 12000.00, 0,    12000.00, 'Western Cape',  'Completed', 'INV-2024-0022', 'Debit Order', '2024', 'Q1'),
(2010, 102, 1013, '2024-03-07', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0023', 'Debit Order', '2024', 'Q1'),
(2004, 108, 1015, '2024-03-08', 45000.00, 0,    45000.00, 'Gauteng',       'Completed', 'INV-2024-0024', 'EFT',         '2024', 'Q1'),
(2011, 104, 1015, '2024-03-10', 8500.00,  0,    8500.00,  'Gauteng',       'Completed', 'INV-2024-0025', 'Debit Order', '2024', 'Q1'),
(2005, 111, 1013, '2024-03-12', 18000.00, 0,    18000.00, 'Gauteng',       'Completed', 'INV-2024-0026', 'EFT',         '2024', 'Q1'),
(2013, 102, 1013, '2024-03-14', NULL,     0,    NULL,     'Gauteng',       'Pending',   'INV-2024-0027', 'EFT',         '2024', 'Q1'),  -- NULL SaleAmount (data issue!)
(2015, 105, 1014, '2024-03-15', 12000.00, 0,    12000.00, 'Western Cape',  'Cancelled', 'INV-2024-0028', 'EFT',         '2024', 'Q1'),  -- Cancelled
(2017, 102, 1013, '2024-03-18', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0029', 'Debit Order', '2024', 'Q1'),
(2009, 111, 1015, '2024-03-20', 18000.00, 0,    18000.00, 'Gauteng',       'Completed', 'INV-2024-0030', 'EFT',         '2024', 'Q1'),
(2019, 102, 1013, '2024-03-22', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0031', 'EFT',         '2024', 'Q1'),
(2001, 102, 1013, '2024-03-22', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0031', 'EFT',         '2024', 'Q1'),  -- DUPLICATE InvoiceNumber (data issue!)
(2007, 106, 1014, '2024-03-25', 22000.00, 0,    22000.00, 'Western Cape',  'Completed', 'INV-2024-0032', 'Debit Order', '2024', 'Q1'),
(2021, 101, 1017, '2024-03-28', 15000.00, 0,    15000.00, 'Gauteng',       'Completed', 'INV-2024-0033', 'EFT',         '2024', 'Q1'),
-- April 2024
(2001, 102, 1013, '2024-04-02', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0034', 'EFT',         '2024', 'Q2'),
(2002, 115, 1013, '2024-04-05', 40000.00, 5,    38000.00, 'Gauteng',       'Completed', 'INV-2024-0035', 'EFT',         '2024', 'Q2'),
(2014, 102, 1015, '2024-04-08', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0036', 'Debit Order', '2024', 'Q2'),
(2015, 102, 1014, '2024-04-10', 35000.00, 0,    35000.00, 'Western Cape',  'Completed', 'INV-2024-0037', 'EFT',         '2024', 'Q2'),
(2016, 113, 1017, '2024-04-15', 250000.00,8,    230000.00,'Gauteng',       'Completed', 'INV-2024-0038', 'EFT',         '2024', 'Q2'),
(2008, 102, 1013, '2024-04-18', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0039', 'Debit Order', '2024', 'Q2'),
(2011, 104, 1015, '2024-04-22', 8500.00,  0,    8500.00,  'Gauteng',       'Completed', 'INV-2024-0040', 'Debit Order', '2024', 'Q2'),
(2023, 106, 1017, '2024-04-25', 22000.00, 0,    22000.00, 'Gauteng',       'Completed', 'INV-2024-0041', 'Debit Order', '2024', 'Q2'),
-- May 2024
(2001, 102, 1013, '2024-05-03', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0042', 'EFT',         '2024', 'Q2'),
(2010, 102, 1013, '2024-05-07', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0043', 'Debit Order', '2024', 'Q2'),
(2003, 107, 1014, '2024-05-10', 150000.00,10,   135000.00,'Western Cape',  'Completed', 'INV-2024-0044', 'EFT',         '2024', 'Q2'),
(2019, 102, 1013, '2024-05-14', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0045', 'EFT',         '2024', 'Q2'),
(2004, 108, 1015, '2024-05-16', 45000.00, 5,    42750.00, 'Gauteng',       'Completed', 'INV-2024-0046', 'EFT',         '2024', 'Q2'),
(2009, 111, 1015, '2024-05-20', 18000.00, 0,    18000.00, 'Gauteng',       'Completed', 'INV-2024-0047', 'Debit Order', '2024', 'Q2'),
(2022, 110, 1018, '2024-05-24', 28000.00, 0,    28000.00, 'Gauteng',       'Completed', 'INV-2024-0048', 'EFT',         '2024', 'Q2'),
(2018, 112, 1015, '2024-05-28', 55000.00, 0,    55000.00, 'Gauteng',       'Completed', 'INV-2024-0049', 'EFT',         '2024', 'Q2'),
-- June 2024
(2001, 102, 1013, '2024-06-04', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0050', 'EFT',         '2024', 'Q2'),
(2002, 102, 1013, '2024-06-07', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0051', 'EFT',         '2024', 'Q2'),
(2017, 102, 1013, '2024-06-10', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0052', 'Debit Order', '2024', 'Q2'),
(2015, 109, 1014, '2024-06-13', 38000.00, 10,   34200.00, 'Western Cape',  'Completed', 'INV-2024-0053', 'EFT',         '2024', 'Q2'),
(2024, 108, 1014, '2024-06-17', 45000.00, 5,    42750.00, 'Western Cape',  'Completed', 'INV-2024-0054', 'EFT',         '2024', 'Q2'),
(2011, 104, 1015, '2024-06-20', 8500.00,  0,    8500.00,  'Gauteng',       'Completed', 'INV-2024-0055', 'Debit Order', '2024', 'Q2'),
(2013, 114, 1013, '2024-06-25', 90000.00, 5,    85500.00, 'Gauteng',       'Completed', 'INV-2024-0056', 'EFT',         '2024', 'Q2'),
(2020, 101, 1018, '2024-06-27', 15000.00, 0,    15000.00, 'Gauteng',       'Completed', 'INV-2024-0057', 'EFT',         '2024', 'Q2'),
-- Q3 & Q4 summary inserts (continuing pattern)
(2001, 102, 1013, '2024-07-03', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0058', 'EFT',         '2024', 'Q3'),
(2010, 102, 1013, '2024-07-08', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0059', 'Debit Order', '2024', 'Q3'),
(2015, 102, 1014, '2024-07-12', 35000.00, 0,    35000.00, 'Western Cape',  'Completed', 'INV-2024-0060', 'EFT',         '2024', 'Q3'),
(2004, 108, 1015, '2024-07-15', 45000.00, 0,    45000.00, 'Gauteng',       'Completed', 'INV-2024-0061', 'EFT',         '2024', 'Q3'),
(2014, 102, 1015, '2024-07-18', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0062', 'EFT',         '2024', 'Q3'),
(2016, 114, 1017, '2024-07-22', 90000.00, 5,    85500.00, 'Gauteng',       'Completed', 'INV-2024-0063', 'EFT',         '2024', 'Q3'),
(2017, 102, 1013, '2024-07-25', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0064', 'Debit Order', '2024', 'Q3'),
(2002, 102, 1013, '2024-08-05', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0065', 'EFT',         '2024', 'Q3'),
(2001, 115, 1013, '2024-08-09', 40000.00, 0,    40000.00, 'Gauteng',       'Completed', 'INV-2024-0066', 'EFT',         '2024', 'Q3'),
(2009, 111, 1015, '2024-08-14', 18000.00, 0,    18000.00, 'Gauteng',       'Completed', 'INV-2024-0067', 'Debit Order', '2024', 'Q3'),
(2019, 102, 1013, '2024-08-18', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0068', 'EFT',         '2024', 'Q3'),
(2022, 110, 1018, '2024-08-22', 28000.00, 0,    28000.00, 'Gauteng',       'Completed', 'INV-2024-0069', 'EFT',         '2024', 'Q3'),
(2003, 107, 1014, '2024-09-04', 150000.00,10,   135000.00,'Western Cape',  'Completed', 'INV-2024-0070', 'EFT',         '2024', 'Q3'),
(2001, 102, 1013, '2024-09-10', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0071', 'EFT',         '2024', 'Q3'),
(2010, 102, 1013, '2024-09-15', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0072', 'Debit Order', '2024', 'Q3'),
(2011, 104, 1015, '2024-09-19', 8500.00,  0,    8500.00,  'Gauteng',       'Completed', 'INV-2024-0073', 'Debit Order', '2024', 'Q3'),
(2013, 113, 1013, '2024-09-23', 250000.00,5,    237500.00,'Gauteng',       'Completed', 'INV-2024-0074', 'EFT',         '2024', 'Q3'),
(2002, 102, 1013, '2024-10-03', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0075', 'EFT',         '2024', 'Q4'),
(2001, 102, 1013, '2024-10-08', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0076', 'EFT',         '2024', 'Q4'),
(2015, 109, 1014, '2024-10-11', 38000.00, 10,   34200.00, 'Western Cape',  'Completed', 'INV-2024-0077', 'EFT',         '2024', 'Q4'),
(2014, 102, 1015, '2024-10-15', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0078', 'EFT',         '2024', 'Q4'),
(2018, 112, 1015, '2024-10-18', 55000.00, 0,    55000.00, 'Gauteng',       'Completed', 'INV-2024-0079', 'EFT',         '2024', 'Q4'),
(2016, 102, 1017, '2024-10-22', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0080', 'Debit Order', '2024', 'Q4'),
(2017, 102, 1013, '2024-10-25', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0081', 'Debit Order', '2024', 'Q4'),
(2001, 102, 1013, '2024-11-05', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0082', 'EFT',         '2024', 'Q4'),
(2009, 111, 1015, '2024-11-08', 18000.00, 0,    18000.00, 'Gauteng',       'Completed', 'INV-2024-0083', 'Debit Order', '2024', 'Q4'),
(2013, 114, 1013, '2024-11-12', 90000.00, 5,    85500.00, 'Gauteng',       'Completed', 'INV-2024-0084', 'EFT',         '2024', 'Q4'),
(2010, 102, 1013, '2024-11-15', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0085', 'Debit Order', '2024', 'Q4'),
(2024, 108, 1014, '2024-11-19', 45000.00, 5,    42750.00, 'Western Cape',  'Completed', 'INV-2024-0086', 'EFT',         '2024', 'Q4'),
(2021, 101, 1017, '2024-11-22', 15000.00, 0,    15000.00, 'Gauteng',       'Completed', 'INV-2024-0087', 'EFT',         '2024', 'Q4'),
(2022, 110, 1018, '2024-11-26', 28000.00, 0,    28000.00, 'Gauteng',       'Completed', 'INV-2024-0088', 'EFT',         '2024', 'Q4'),
(2001, 102, 1013, '2024-12-04', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0089', 'EFT',         '2024', 'Q4'),
(2002, 113, 1013, '2024-12-06', 250000.00,5,    237500.00,'Gauteng',       'Completed', 'INV-2024-0090', 'EFT',         '2024', 'Q4'),
(2015, 102, 1014, '2024-12-09', 35000.00, 0,    35000.00, 'Western Cape',  'Completed', 'INV-2024-0091', 'EFT',         '2024', 'Q4'),
(2014, 111, 1015, '2024-12-11', 18000.00, 0,    18000.00, 'Gauteng',       'Completed', 'INV-2024-0092', 'EFT',         '2024', 'Q4'),
(2019, 102, 1013, '2024-12-13', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2024-0093', 'EFT',         '2024', 'Q4'),
-- 2025 Q1
(2001, 102, 1013, '2025-01-07', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2025-0001', 'EFT',         '2025', 'Q1'),
(2010, 102, 1013, '2025-01-10', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2025-0002', 'Debit Order', '2025', 'Q1'),
(2003, 116, 1014, '2025-01-14', 8500.00,  0,    8500.00,  'Western Cape',  'Completed', 'INV-2025-0003', 'EFT',         '2025', 'Q1'),
(2011, 104, 1015, '2025-01-17', 8500.00,  0,    8500.00,  'Gauteng',       'Completed', 'INV-2025-0004', 'Debit Order', '2025', 'Q1'),
(2013, 102, 1013, '2025-01-21', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2025-0005', 'EFT',         '2025', 'Q1'),
(2015, 105, 1014, '2025-01-24', 12000.00, 0,    12000.00, 'Western Cape',  'Completed', 'INV-2025-0006', 'EFT',         '2025', 'Q1'),
(2002, 102, 1013, '2025-02-05', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2025-0007', 'EFT',         '2025', 'Q1'),
(2017, 102, 1013, '2025-02-10', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2025-0008', 'Debit Order', '2025', 'Q1'),
(2014, 107, 1015, '2025-02-14', 150000.00,10,   135000.00,'Gauteng',       'Completed', 'INV-2025-0009', 'EFT',         '2025', 'Q1'),
(2001, 102, 1013, '2025-03-04', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2025-0010', 'EFT',         '2025', 'Q1'),
(2019, 115, 1013, '2025-03-08', 40000.00, 5,    38000.00, 'Gauteng',       'Completed', 'INV-2025-0011', 'EFT',         '2025', 'Q1'),
(2010, 102, 1013, '2025-03-12', 35000.00, 0,    35000.00, 'Gauteng',       'Completed', 'INV-2025-0012', 'Debit Order', '2025', 'Q1'),
(2022, 110, 1018, '2025-03-18', 28000.00, 0,    28000.00, 'Gauteng',       'Completed', 'INV-2025-0013', 'EFT',         '2025', 'Q1'),
(2016, 113, 1017, '2025-03-24', 250000.00,8,    230000.00,'Gauteng',       'Completed', 'INV-2025-0014', 'EFT',         '2025', 'Q1');

-- ============================================================
-- SECTION 12: SUPPORT TICKETS
-- ============================================================

INSERT INTO SupportTickets (TicketReference, ClientID, AssignedToID, CategoryID, Priority, Subject, Status, LoggedDate, FirstResponseDate, ResolvedDate, SLABreached, CustomerSatisfaction) VALUES
('TKT-2024-001', 2001, 1010, 7, 'Critical', 'ETL job failed - March month-end data not loaded',         'Closed',      '2024-03-01 07:15:00', '2024-03-01 08:00:00', '2024-03-01 11:30:00', 0, 5),
('TKT-2024-002', 2004, 1010, 3, 'High',     'NULL values appearing in SaleAmount column - March data',  'Closed',      '2024-03-14 10:30:00', '2024-03-14 11:00:00', '2024-03-15 09:00:00', 0, 4),
('TKT-2024-003', 2010, 1011, 5, 'Medium',   'Power BI dashboard access denied after password reset',    'Closed',      '2024-03-18 09:00:00', '2024-03-18 10:30:00', '2024-03-18 14:00:00', 0, 5),
('TKT-2024-004', 2002, 1010, 6, 'High',     'SSRS report not generating - March finance pack',          'Closed',      '2024-03-29 08:00:00', '2024-03-29 09:15:00', '2024-03-29 13:00:00', 0, 4),
('TKT-2024-005', 2014, 1010, 1, 'Critical', 'Production database unreachable - full system outage',     'Closed',      '2024-04-02 06:30:00', '2024-04-02 06:45:00', '2024-04-02 09:30:00', 0, 5),
('TKT-2024-006', 2006, 1011, 4, 'Medium',   'Tableau dashboard loading slowly - Government reporting',  'Closed',      '2024-04-10 11:00:00', '2024-04-10 12:00:00', '2024-04-11 10:00:00', 0, 3),
('TKT-2024-007', 2001, 1010, 3, 'High',     'Duplicate records in April SalesTransactions table',       'Closed',      '2024-04-22 14:00:00', '2024-04-22 14:30:00', '2024-04-23 09:00:00', 1, 4),
('TKT-2024-008', 2009, 1011, 2, 'Medium',   'Application crashing when filtering by date range',        'Closed',      '2024-05-07 09:30:00', '2024-05-07 10:00:00', '2024-05-08 11:00:00', 0, 4),
('TKT-2024-009', 2013, 1010, 7, 'High',     'SSIS package failing on Kumba data load',                  'Closed',      '2024-06-03 07:00:00', '2024-06-03 07:30:00', '2024-06-03 12:00:00', 0, 5),
('TKT-2024-010', 2004, 1011, 5, 'Low',      'New analyst requires Power BI access - Nedbank team',      'Closed',      '2024-06-14 10:00:00', '2024-06-14 14:00:00', '2024-06-15 09:00:00', 0, 5),
('TKT-2024-011', 2001, 1010, 3, 'High',     'Q3 data quality check failed - 15% NULL rate in amounts',  'Closed',      '2024-07-02 08:30:00', '2024-07-02 09:00:00', '2024-07-03 10:00:00', 0, 4),
('TKT-2024-012', 2002, 1010, 6, 'Medium',   'Power BI report showing incorrect YTD figures',            'Resolved',    '2024-08-19 11:00:00', '2024-08-19 11:30:00', '2024-08-20 14:00:00', 0, 4),
('TKT-2024-013', 2014, 1011, 1, 'Critical', 'Data warehouse ETL failed overnight - all systems affected','Closed',     '2024-09-01 05:00:00', '2024-09-01 05:15:00', '2024-09-01 08:30:00', 0, 5),
('TKT-2024-014', 2016, 1011, 4, 'High',     'Nandos BI dashboard performance issue post-upgrade',       'Closed',      '2024-09-20 13:00:00', '2024-09-20 13:30:00', '2024-09-21 09:00:00', 1, 3),
('TKT-2024-015', 2019, 1010, 3, 'Medium',   'Missing records in Momentum October data load',            'Closed',      '2024-10-03 09:00:00', '2024-10-03 10:00:00', '2024-10-04 11:00:00', 0, 4),
('TKT-2025-001', 2001, 1010, 7, 'Critical', 'January 2025 ETL job - row count mismatch detected',       'Closed',      '2025-01-08 06:45:00', '2025-01-08 07:00:00', '2025-01-08 10:30:00', 0, 5),
('TKT-2025-002', 2014, 1011, 5, 'High',     'Transnet analyst locked out of SSRS reporting portal',     'Closed',      '2025-01-22 08:30:00', '2025-01-22 09:00:00', '2025-01-22 11:00:00', 0, 5),
('TKT-2025-003', 2010, 1010, 3, 'High',     'Standard Bank March data - duplicate invoice numbers found','In Progress', '2025-03-14 10:00:00', '2025-03-14 10:30:00', NULL,                  0, NULL);

-- ============================================================
-- SECTION 13: ETL JOB LOG DATA
-- ============================================================

INSERT INTO ETLJobs (JobName, SourceSystem, DestinationTable, ScheduleType) VALUES
('Load_SalesTransactions_Daily',    'CRM System',           'SalesTransactions',    'Daily'),
('Load_GL_Monthly',                 'Ability Financial',    'GeneralLedger',        'Monthly'),
('Load_ClientData_Weekly',          'CRM System',           'Clients',              'Daily'),
('Load_SupportTickets_Daily',       'FreshDesk',            'SupportTickets',       'Daily'),
('Load_BudgetData_Monthly',         'Finance Portal',       'BudgetAllocation',     'Monthly'),
('Load_EmployeeData_Daily',         'HR System',            'Employees',            'Daily');

INSERT INTO ETLRunLog (JobID, RunDate, StartTime, EndTime, RowsExtracted, RowsLoaded, RowsRejected, Status, ErrorMessage, RunByUserID) VALUES
(1, '2024-03-01', '2024-03-01 02:00:00', '2024-03-01 02:14:22', 145, 145, 0,  'Success', NULL,                                                          1006),
(2, '2024-03-31', '2024-03-31 23:00:00', '2024-03-31 23:45:10', 890, 888, 2,  'Partial', 'Two records rejected: NULL SaleAmount on TransactionID 10028', 1006),
(1, '2024-04-01', '2024-04-01 02:00:00', '2024-04-01 02:11:05', 132, 132, 0,  'Success', NULL,                                                          1006),
(4, '2024-04-01', '2024-04-01 03:00:00', '2024-04-01 03:05:30', 48,  48,  0,  'Success', NULL,                                                          1006),
(1, '2024-09-01', '2024-09-01 02:00:00', NULL,                   0,   0,   0,  'Failed',  'Connection timeout - SQL Server unreachable',                  1006),
(1, '2024-09-01', '2024-09-01 05:45:00', '2024-09-01 06:01:00', 198, 198, 0,  'Success', NULL,                                                          1006),
(2, '2024-12-31', '2024-12-31 23:00:00', '2024-12-31 23:52:44', 1240,1240,0,  'Success', NULL,                                                          1006),
(1, '2025-01-08', '2025-01-08 02:00:00', '2025-01-08 02:18:30', 210, 198, 12, 'Partial', 'Row count mismatch: 12 records missing from source extract',   1006),
(3, '2025-01-08', '2025-01-08 04:00:00', '2025-01-08 04:08:15', 24,  24,  0,  'Success', NULL,                                                          1006);

-- ============================================================
-- SECTION 14: DATA QUALITY LOG
-- ============================================================

INSERT INTO DataQualityLog (TableName, CheckDate, CheckType, RecordsChecked, RecordsFailed, Severity, ResolvedDate, Notes) VALUES
('SalesTransactions', '2024-03-31', 'NULL Check on SaleAmount',          890,  2,  'High',     '2024-04-02', 'Two March records had NULL SaleAmount - sourced from CRM staging error'),
('SalesTransactions', '2024-03-31', 'Duplicate InvoiceNumber Check',     890,  1,  'High',     '2024-04-02', 'INV-2024-0031 appeared twice - ETL did not deduplicate on reload'),
('SalesTransactions', '2024-03-31', 'Status vs Amount Consistency Check',890,  1,  'Medium',   '2024-04-02', 'One Cancelled record still had a non-zero SaleAmount'),
('Clients',           '2024-06-30', 'NULL Check on ContractValue',       24,   0,  'Low',      NULL,         'All client contract values populated - no issues'),
('GeneralLedger',     '2024-06-30', 'Range Check on DebitAmount',        1240, 3,  'Medium',   '2024-07-05', '3 GL entries had zero debit and zero credit - investigation required'),
('SalesTransactions', '2024-09-30', 'NULL Check on SaleAmount',          450,  0,  'Low',      NULL,         'Q3 data clean - no NULL amounts detected'),
('ETLRunLog',         '2025-01-08', 'Row Count Reconciliation',          210,  12, 'Critical', '2025-01-10', '12 records missing from January load - reprocessed from source'),
('SalesTransactions', '2025-03-14', 'Duplicate InvoiceNumber Check',     156,  1,  'High',     NULL,         'Ongoing investigation - Standard Bank March data affected');

-- ============================================================
-- SECTION 15: MONTHLY REVENUE TARGETS
-- ============================================================

INSERT INTO MonthlyRevenueTarget (DepartmentID, SalespersonID, TargetYear, TargetMonth, TargetAmount, Region) VALUES
(3, 1013, 2024, 1,  500000.00, 'Gauteng'),
(3, 1013, 2024, 2,  500000.00, 'Gauteng'),
(3, 1013, 2024, 3,  500000.00, 'Gauteng'),
(3, 1013, 2024, 4,  550000.00, 'Gauteng'),
(3, 1013, 2024, 5,  550000.00, 'Gauteng'),
(3, 1013, 2024, 6,  550000.00, 'Gauteng'),
(3, 1013, 2024, 7,  600000.00, 'Gauteng'),
(3, 1013, 2024, 8,  600000.00, 'Gauteng'),
(3, 1013, 2024, 9,  600000.00, 'Gauteng'),
(3, 1013, 2024, 10, 650000.00, 'Gauteng'),
(3, 1013, 2024, 11, 650000.00, 'Gauteng'),
(3, 1013, 2024, 12, 650000.00, 'Gauteng'),
(3, 1014, 2024, 1,  300000.00, 'Western Cape'),
(3, 1014, 2024, 2,  300000.00, 'Western Cape'),
(3, 1014, 2024, 3,  300000.00, 'Western Cape'),
(3, 1015, 2024, 1,  280000.00, 'Gauteng'),
(3, 1015, 2024, 2,  280000.00, 'Gauteng'),
(3, 1015, 2024, 3,  280000.00, 'Gauteng'),
(4, 1017, 2024, 1,  150000.00, 'Gauteng'),
(4, 1018, 2024, 1,  120000.00, 'Gauteng');

-- ============================================================
-- SECTION 16: USEFUL VIEWS FOR BI REPORTING
-- (These are what you would build as a BI Developer)
-- ============================================================

-- View 1: Monthly Sales Summary (what the MI team needs)
CREATE VIEW vw_MonthlySalesSummary AS
SELECT
    YEAR(SaleDate)                          AS SaleYear,
    MONTH(SaleDate)                         AS SaleMonth,
    DATENAME(MONTH, SaleDate)               AS MonthName,
    FinancialQuarter,
    Region,
    COUNT(TransactionID)                    AS TotalTransactions,
    SUM(CASE WHEN Status = 'Completed' THEN SaleAmount ELSE 0 END)  AS TotalRevenue,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END)           AS CancelledCount,
    SUM(CASE WHEN SaleAmount IS NULL THEN 1 ELSE 0 END)             AS NullAmountCount
FROM SalesTransactions
GROUP BY YEAR(SaleDate), MONTH(SaleDate), DATENAME(MONTH, SaleDate), FinancialQuarter, Region;
GO

-- View 2: Salesperson Performance vs Target
CREATE VIEW vw_SalespersonPerformance AS
SELECT
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName         AS SalespersonName,
    e.Region,
    t.TargetYear,
    t.TargetMonth,
    t.TargetAmount,
    ISNULL(SUM(s.NetAmount), 0)             AS ActualRevenue,
    t.TargetAmount - ISNULL(SUM(s.NetAmount), 0) AS Variance,
    CAST(ISNULL(SUM(s.NetAmount), 0) / NULLIF(t.TargetAmount, 0) * 100 AS DECIMAL(5,1)) AS AchievementPct
FROM MonthlyRevenueTarget t
JOIN Employees e ON t.SalespersonID = e.EmployeeID
LEFT JOIN SalesTransactions s
    ON s.SalespersonID = t.SalespersonID
    AND YEAR(s.SaleDate) = t.TargetYear
    AND MONTH(s.SaleDate) = t.TargetMonth
    AND s.Status = 'Completed'
GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.Region, t.TargetYear, t.TargetMonth, t.TargetAmount;
GO

-- View 3: Client Revenue Summary (for account managers)
CREATE VIEW vw_ClientRevenueSummary AS
SELECT
    c.ClientID,
    c.ClientName,
    cs.SegmentName,
    c.Province,
    e.FirstName + ' ' + e.LastName         AS AccountManager,
    COUNT(s.TransactionID)                  AS TotalTransactions,
    SUM(CASE WHEN s.Status = 'Completed' THEN s.NetAmount ELSE 0 END) AS TotalRevenue,
    MAX(s.SaleDate)                         AS LastTransactionDate,
    c.ContractValue,
    c.Status                                AS ClientStatus
FROM Clients c
JOIN ClientSegments cs ON c.SegmentID = cs.SegmentID
JOIN Employees e ON c.AccountManagerID = e.EmployeeID
LEFT JOIN SalesTransactions s ON c.ClientID = s.ClientID
GROUP BY c.ClientID, c.ClientName, cs.SegmentName, c.Province,
         e.FirstName, e.LastName, c.ContractValue, c.Status;
GO

-- View 4: Data Quality Dashboard (ETL monitoring)
CREATE VIEW vw_DataQualityDashboard AS
SELECT
    TableName,
    CheckDate,
    CheckType,
    RecordsChecked,
    RecordsFailed,
    CAST(RecordsFailed AS DECIMAL(10,2)) / NULLIF(RecordsChecked,0) * 100 AS FailurePct,
    Severity,
    CASE WHEN ResolvedDate IS NULL THEN 'Open' ELSE 'Resolved' END AS IssueStatus,
    Notes
FROM DataQualityLog;
GO

-- View 5: SLA Compliance Report (Support Tickets)
CREATE VIEW vw_SLAComplianceReport AS
SELECT
    st.TicketID,
    st.TicketReference,
    c.ClientName,
    ic.CategoryName,
    st.Priority,
    st.Status,
    st.LoggedDate,
    st.ResolvedDate,
    DATEDIFF(HOUR, st.LoggedDate, ISNULL(st.ResolvedDate, GETDATE())) AS HoursToResolve,
    ic.SLAHours,
    st.SLABreached,
    e.FirstName + ' ' + e.LastName AS AssignedTo,
    st.CustomerSatisfaction
FROM SupportTickets st
JOIN Clients c ON st.ClientID = c.ClientID
JOIN IncidentCategories ic ON st.CategoryID = ic.CategoryID
JOIN Employees e ON st.AssignedToID = e.EmployeeID;
GO

-- ============================================================
-- SECTION 17: VERIFICATION QUERIES
-- Run these after setup to confirm everything loaded correctly
-- ============================================================

-- Quick data check
SELECT 'Departments'        AS TableName, COUNT(*) AS RecordCount FROM Departments
UNION ALL SELECT 'Employees',           COUNT(*) FROM Employees
UNION ALL SELECT 'Clients',             COUNT(*) FROM Clients
UNION ALL SELECT 'Products',            COUNT(*) FROM Products
UNION ALL SELECT 'SalesTransactions',   COUNT(*) FROM SalesTransactions
UNION ALL SELECT 'SupportTickets',      COUNT(*) FROM SupportTickets
UNION ALL SELECT 'ETLRunLog',           COUNT(*) FROM ETLRunLog
UNION ALL SELECT 'DataQualityLog',      COUNT(*) FROM DataQualityLog
UNION ALL SELECT 'MonthlyRevenueTarget',COUNT(*) FROM MonthlyRevenueTarget;

-- ============================================================
-- DATABASE SETUP COMPLETE
-- Welcome to Nexus Financial Services, Thabo.
-- You are now a BI Developer. Get to work.
-- ============================================================
