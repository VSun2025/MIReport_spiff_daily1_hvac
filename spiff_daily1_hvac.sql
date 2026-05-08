SELECT 
    [Employee ID],
    [First Name],
    [Last Name],
    [Job Title],
    [Reference ID],
    CONVERT(varchar(10), TRY_CAST([Creation Date] AS DATETIME), 120) AS [Creation Date],
    CONVERT(varchar(10), TRY_CAST([Written Date] AS DATETIME), 120) AS [Written Date],
    CONVERT(varchar(10), TRY_CAST([Final Date] AS DATETIME), 120) AS [Final Date],
    Product,
    [Itm Cd],
    SKU,
    CASE 
        WHEN [Product Type] = 'BigBox' THEN 
            CASE 
                WHEN Total_Units <= 50 THEN '50' 
                ELSE '75' 
            END
    WHEN [Product Type] = 'HeatPump' THEN 
            CASE 
                WHEN Total_Units <= 50 THEN '75' 
                ELSE '100' 
            END
        WHEN [Product Type] = 'Humidifier' THEN '20'
        ELSE '15'
    END AS PymtAmt,
    'ChargedUp Spiff Payment' AS PymtType,
    [Patch Code],
    [SO Ref],
    [Customer Address],
    [Postal Cd],
    keep
FROM (
    SELECT 
        a.*,
        b.Total_Units
    FROM pbi.perform_MI_Payment_Sales_HVAC_weekly_query1 a
    LEFT JOIN (
        SELECT 
            [employee login],
            COUNT(*) AS Total_Units
        FROM pbi.perform_MI_Payment_Sales_HVAC_weekly_query1
        WHERE [Product Type] = 'BigBox'
        GROUP BY [employee login]
    ) b
        ON a.[employee login] = b.[employee login]
) tab1
WHERE keep = 1
ORDER BY [Reference ID];