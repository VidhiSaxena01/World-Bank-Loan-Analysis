SELECT * FROM world_bank_analysis.ida_statement;

-- Top 5 countries with the highest loan amount

SELECT 
    `Country / Economy`,
    CONCAT('$',
            FORMAT(SUM(`Original Principal Amount`) / 1000000000,
                0),
            ' B') AS Total_Loan
FROM
    ida_statement
GROUP BY `Country / Economy`
ORDER BY SUM(`Original Principal Amount`) DESC
LIMIT 5;

-- How many Countries have taken Loan From World Bank.

SELECT 
    COUNT(DISTINCT `Country / Economy`)
FROM
    ida_statement
    
-- Top 5 Countries with highest Due amount

SELECT `Country / Economy`,
    CONCAT('$',
            ROUND(SUM(REPLACE(`Due to IDA`, ',', '') + 0) / 1000000000,
                    0),
            'B') AS `Due Loan Amount`
FROM
    ida_statement
GROUP BY `Country / Economy`
ORDER BY SUM(REPLACE(`Due to IDA`, ',', '') + 0) DESC
LIMIT 5;

-- Top 5 Countries who have taken most loan amount in percentage

SELECT 
    `Country / Economy`,
    ROUND((SUM(`Original Principal Amount`) / (SELECT 
                    SUM(`Original Principal Amount`)
                FROM
                    ida_statement) * 100),
            2) AS loan_percentage
FROM
    ida_statement
GROUP BY `Country / Economy`
ORDER BY loan_percentage DESC
LIMIT 5;

-- Project First Approved Loan for India.

SELECT 
    `Project Name`,
    `Board Approval Date` AS `First Approved Date`
FROM
    ida_statement
WHERE
    `Country / Economy` = 'India'
        AND STR_TO_DATE(`Board Approval Date`, '%m/%d/%Y') = (SELECT 
            MIN(STR_TO_DATE(`Board Approval Date`, '%m/%d/%Y'))
        FROM
            ida_statement
        WHERE
            `Country / Economy` = 'India')
LIMIT 1;

-- Top 5 Project in India having Highest Loan.

SELECT 
    `Project Name`,
    CONCAT('$',
            ROUND(SUM(REPLACE(`Original Principal Amount`,
                        ',',
                        '') / 1000000000),
                    2) - ROUND(SUM(REPLACE(`Cancelled Amount`, ',', '') / 1000000000),
                    2),
            'B') AS `Total Loan Amount`
FROM
    ida_statement
WHERE
    `Country / Economy` = 'India'
GROUP BY `Project Name`
ORDER BY SUM(REPLACE(`Original Principal Amount`,
    ',',
    '') + 0) DESC
LIMIT 5;

-- Top 5 project in India having highest loan and the Due amount of those loans.

SELECT 
    `Project Name`,
    CONCAT('$',
            ROUND(SUM(REPLACE(`Original Principal Amount`,
                        ',',
                        '') / 1000000000),
                    2) - ROUND(SUM(REPLACE(`Cancelled Amount`, ',', '') / 1000000000),
                    2),
            'B') AS `Total Loan Amount`,
    CONCAT('$',
            ROUND(SUM(REPLACE(`Due to IDA`, ',', '') / 1000000000),
                    2),
            'B') AS `Due Loan Amount`
FROM
    ida_statement
WHERE
    `Country / Economy` = 'India'
GROUP BY `Project Name`
ORDER BY SUM(REPLACE(`Original Principal Amount`,
    ',',
    '') + 0) - SUM(REPLACE(`Cancelled Amount`, ',', '') + 0) DESC
LIMIT 5;

-- Total number of loan projects that have fully repaid the loan.

WITH CTE AS (
    SELECT 
        `Project Name`,
        CONCAT('$', ROUND(SUM(REPLACE(`Original Principal Amount`, ',', '') / 1000000000), 2) -
               ROUND(SUM(REPLACE(`Cancelled Amount`, ',', '') / 1000000000), 2), 
               'B') AS `Total Loan Amount`
    FROM 
        ida_statement
    WHERE 
        `Country / Economy` = 'India' 
        AND `Credit Status` IN ('Fully Repaid')
    GROUP BY 
        `Project Name`
    ORDER BY 
        SUM(REPLACE(`Original Principal Amount`, ',', '') + 0) - 
        SUM(REPLACE(`Cancelled Amount`, ',', '') + 0) DESC
)
SELECT
    COUNT(*) AS `total Count of paid Loan`
FROM 
    CTE;

-- Top 5 Maximum approval time in project for India
    
SELECT 
    DISTINCT `Project Name`,
    ROUND(DATEDIFF(
        STR_TO_DATE(`Closed Date`, '%m/%d/%Y'),
        STR_TO_DATE(`Board Approval Date`, '%m/%d/%Y')
    ) / 365.25, 0) AS `Loan Process Time (years)`
FROM 
    ida_statement
WHERE 
    `Country / Economy` = 'India' 
    AND `Closed Date` IS NOT NULL 
    AND `Board Approval Date` IS NOT NULL
ORDER BY 
    `Loan Process Time (years)` DESC;

-- Top 5 Minimum approval time in project for India

SELECT 
    `Project Name`,
    DATEDIFF(
        STR_TO_DATE(`Closed Date`, '%m/%d/%Y'), 
        STR_TO_DATE(`Board Approval Date`, '%m/%d/%Y')
    ) AS `Approval Time (Days)`
FROM 
    `world_bank_analysis`.`ida_statement`
WHERE 
    `Country / Economy` = 'India'
ORDER BY 
    `Approval Time (Days)` ASC
LIMIT 5;
