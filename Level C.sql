--------------Task 1--------------------

WITH ProjectWithGroup AS (
  SELECT *,
         DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY Start_Date), Start_Date) AS grp
  FROM Projects
),
GroupedProjects AS (
  SELECT MIN(Start_Date) AS Project_Start,
         MAX(End_Date) AS Project_End,
         DATEDIFF(DAY, MIN(Start_Date), MAX(End_Date)) AS Duration
  FROM ProjectWithGroup
  GROUP BY grp
)
SELECT Project_Start, Project_End
FROM GroupedProjects
ORDER BY Duration, Project_Start;

-------------------Task 2-----------------------

SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages sp ON s.ID = sp.ID
JOIN Packages fp ON f.Friend_ID = fp.ID
WHERE fp.Salary > sp.Salary
ORDER BY fp.Salary;

-------------------Task 3---------------------------

SELECT DISTINCT
    LEAST(f1.X, f1.Y) AS X,
    GREATEST(f1.X, f1.Y) AS Y
FROM Functions f1
JOIN Functions f2
  ON f1.X = f2.Y AND f1.Y = f2.X
WHERE f1.X <= f1.Y
ORDER BY X;

------------------Task 4--------------------------------

