SELECT
    [Employee ID],
    [First Name],
    [Last Name],
    [Job Title],
    [Reference ID],
    CONVERT(varchar(10), FinalDate, 120) AS [Creation Date],
    CONVERT(varchar(10), WrittenDate, 120) AS [Written Date],
    CONVERT(varchar(10), FinalDate, 120) AS [Final Date],
    Product,
    [Itm Cd],
    SKU,

    CASE 
        -- BigBox (YTD from Jan 1)
        WHEN [Product Type] = 'BigBox' THEN 
            CASE 
                WHEN BigBox_YTD_Units < 50 THEN '50'
                ELSE '75'
            END

        --  HeatPump (YTD from Jan 1)
        WHEN [Product Type] = 'HeatPump' THEN
            CASE 
                -- Q1: always 50
                WHEN FinalDate <= '2026-03-31' THEN '50'

                -- Apr onward: use YTD (NOT reset)
                WHEN FinalDate >= '2026-04-01' THEN
                    CASE 
                        WHEN HeatPump_YTD_Units < 50 THEN '75'
                        ELSE '100'
                    END
            END

        --  Humidifier
        WHEN [Product Type] = 'Humidifier' THEN '20'

        --  Others
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

        TRY_CAST([Final Date] AS DATETIME) AS FinalDate,
        TRY_CAST([Written Date] AS DATETIME) AS WrittenDate,

        -- BigBox YTD cumulative (Jan 1 start)
        SUM(
            CASE 
                WHEN [Product Type] = 'BigBox'
                     AND TRY_CAST([Final Date] AS DATETIME) >= '2026-01-01'
                THEN 1 ELSE 0
            END
        ) OVER (
            PARTITION BY [employee login]
            ORDER BY TRY_CAST([Final Date] AS DATETIME)
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS BigBox_YTD_Units,

        -- HeatPump YTD cumulative (Jan 1 start)
        SUM(
            CASE 
                WHEN [Product Type] = 'HeatPump'
                     AND TRY_CAST([Final Date] AS DATETIME) >= '2026-01-01'
                THEN 1 ELSE 0
            END
        ) OVER (
            PARTITION BY [employee login]
            ORDER BY TRY_CAST([Final Date] AS DATETIME)
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS HeatPump_YTD_Units

    FROM pbi.perform_MI_Payment_Sales_HVAC_weekly_query1_test a
) tab1

--WHERE [Employee ID]='600031' and FinalDate<='20260608'
--WHERE [Employee ID]='234319'
ORDER BY [Employee ID],[Product Type],[Final Date];