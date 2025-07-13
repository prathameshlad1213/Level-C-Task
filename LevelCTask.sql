-- Task 1: Students whose best friends got higher salary
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages sp ON s.ID = sp.ID
JOIN Packages fp ON f.Friend_ID = fp.ID
WHERE fp.Salary > sp.Salary
ORDER BY fp.Salary;

-- Task 2: Symmetric pairs
SELECT DISTINCT 
    LEAST(a.X, a.Y) AS X,
    GREATEST(a.X, a.Y) AS Y
FROM Functions a
JOIN Functions b ON a.X = b.Y AND a.Y = b.X
WHERE a.X <= b.X;

-- Task 3: First login date for each player
SELECT player_id, MIN(event_date) AS first_login
FROM Activity
GROUP BY player_id;

-- Task 4: Rising temperature (temperature greater than yesterday)
SELECT w1.id
FROM Weather w1
JOIN Weather w2 ON DATEDIFF(w1.recordDate, w2.recordDate) = 1
WHERE w1.temperature > w2.temperature;

-- Task 5: SQL Contest Daily Summary
SELECT s.submission_date,
       COUNT(DISTINCT s.hacker_id) AS unique_hackers,
       h.hacker_id,
       h.name
FROM Submissions s
JOIN Hackers h ON s.hacker_id = h.hacker_id
WHERE s.submission_date BETWEEN '2016-03-01' AND '2016-03-15'
GROUP BY s.submission_date, h.hacker_id, h.name
HAVING (h.hacker_id = (
    SELECT TOP 1 hacker_id
    FROM Submissions s2
    WHERE s2.submission_date = s.submission_date
    GROUP BY hacker_id
    ORDER BY COUNT(*) DESC, hacker_id ASC
));

-- Task 6: Manhattan Distance between extreme lat/longs
SELECT ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4) AS ManhattanDistance
FROM STATION;

-- Task 7: Prime numbers ≤ 1000
WITH RECURSIVE Numbers AS (
  SELECT 2 AS n
  UNION ALL
  SELECT n + 1 FROM Numbers WHERE n < 1000
),
Primes AS (
  SELECT n FROM Numbers
  WHERE NOT EXISTS (
    SELECT 1 FROM Numbers AS d WHERE d.n < n AND n % d.n = 0 AND d.n > 1
  )
)
SELECT STRING_AGG(n, '&') AS primes FROM Primes;

-- Task 8: Pivot Occupation
SELECT
  MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
  MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
  MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
  MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM (
  SELECT Name, Occupation,
         ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
  FROM Occupations
) AS T
GROUP BY rn;

-- Task 9: Identify node type in a binary tree
SELECT N,
       CASE 
         WHEN P IS NULL THEN 'Root'
         WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
         ELSE 'Inner'
       END AS NodeType
FROM BST
ORDER BY N;

-- Task 11: Students whose best friends got higher salary
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID
JOIN Packages p2 ON f.Friend_ID = p2.ID
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;


-- Task 12: Ratio of cost of job family in % (India vs International)
SELECT 
  JobFamily,
  SUM(CASE WHEN Country = 'India' THEN Cost ELSE 0 END) * 100.0 / SUM(Cost) AS India_Percent,
  SUM(CASE WHEN Country <> 'India' THEN Cost ELSE 0 END) * 100.0 / SUM(Cost) AS International_Percent
FROM SimulationData
GROUP BY JobFamily;


-- Task 13: Ratio of Cost to Revenue for a BU Month on Month
SELECT 
  BU, 
  Month,
  ROUND(SUM(Cost) * 1.0 / NULLIF(SUM(Revenue), 0), 2) AS CostToRevenueRatio
FROM BU_Financials
GROUP BY BU, Month;


-- Task 14: Headcount and % per SubBand (no JOINs or subqueries)
SELECT 
  SubBand,
  COUNT(*) AS HeadCount,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS Percentage
FROM Employees
GROUP BY SubBand;


-- Task 15: Top 5 Employees by Salary (without ORDER BY)
WITH RankedEmployees AS (
  SELECT *, DENSE_RANK() OVER (ORDER BY Salary DESC) AS rnk
  FROM Employees
)
SELECT * FROM RankedEmployees
WHERE rnk <= 5;


-- Task 16: Swap two column values without using third variable
-- Assumes columns col1 and col2 in table Employees
UPDATE Employees
SET col1 = col1 + col2,
    col2 = col1 - col2,
    col1 = col1 - col2;


-- Task 17: Create login, user, and assign db_owner permissions (SQL Server syntax)
CREATE LOGIN myuser WITH PASSWORD = 'StrongPassword@123';
USE YourDatabase;
CREATE USER myuser FOR LOGIN myuser;
EXEC sp_addrolemember 'db_owner', 'myuser';


-- Task 18: Weighted Average Cost of Employees Month on Month in a BU
SELECT 
  BU,
  Month,
  ROUND(SUM(Cost * Headcount * 1.0) / NULLIF(SUM(Headcount), 0), 2) AS Weighted_Avg_Cost
FROM BU_EmployeeCost
GROUP BY BU, Month;


-- Task 19: Miscalculated vs Actual Salary Average Difference (Round up)
SELECT 
  CEILING(AVG(Salary) - AVG(CAST(REPLACE(CAST(Salary AS VARCHAR), '0', '') AS INT))) AS Salary_Error
FROM Employees;


-- Task 20: Copy new data from one table to another (detecting new data by comparison)
INSERT INTO TargetTable
SELECT *
FROM SourceTable
EXCEPT
SELECT *
FROM TargetTable;
