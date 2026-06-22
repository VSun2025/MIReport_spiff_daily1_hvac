/****** Object:  View [pbi].[perform_MI_Payment_Sales_HVAC_weekly_query1_test]    Script Date: 6/22/2026 1:09:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE OR ALTER  view [pbi].[perform_MI_Payment_Sales_HVAC_weekly_query1_test] AS

SELECT 
    AL7.employee_no as [Employee ID],
    AL7.s_first_name as [First Name],
    AL7.s_last_name as [Last Name],
    AL6.s_id as [Reference ID],
    CAST(AL1.final_dt AS DATE) as [Final Date],
    AL3.itm_cd as [Itm Cd],
    AL4.des as Product,
    AL5.des as [Product Minor],
    AL1.del_doc_num as [SO Ref],
    AL8.s_login_name as [Ref Login],
    AL7.work_group as [Job Title],
    AL1.so_store_cd as [Patch Code],
    CAST(GETDATE() AS DATE) as Rundate,
    AL10.x_district as District,
    AL6.x_creation_time as [Creation Date],
    AL1.so_wr_dt as [Written Date],
    AL3.vsn as SKU,
    AL10.x_ops_group_code as [Ops Group Code],
    AL1.pu_del_date as [Install Date],
    ISNULL(AL1.ship_to_addr1,'') + ' ' + ISNULL(AL1.ship_to_addr2,'') as [Customer Address],
    AL1.ship_to_zip_code as [Postal Cd],
    AL8.s_login_name as [Employee Login],
    AL9.site_id as [Site Id],

    -- === MODIFIED: Keep all current year sales (was rolling 6 weeks) ===
    CASE 
        WHEN CAST(AL1.final_dt AS DATE) >= CAST(DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0) AS DATE) 
        THEN '1' 
        ELSE '0' 
    END as keep,

    -- Product Type Logic (UNCHANGED)
    CASE 
        WHEN AL4.des = 'IAQ AIR CLEANER' THEN 'Accessories'
        WHEN AL4.des IN ('AIR CONDITIONING','BOILER','BOILERS', 'ELECTRONIC RECOVERY','FURNACE', 'HEAT RECOVERY VENT.') 
            THEN 'BigBox'
        WHEN AL4.des IN ('HEAT PUMP') THEN 'HeatPump'
        WHEN AL4.des IN ('IAQ HUMIDIFIER') THEN 'Humidifier'
        ELSE 'Other' 
    END as [Product Type]

FROM pbi.perform_so AL1
INNER JOIN pbi.perform_so_ln AL2          ON AL2.del_doc_num = AL1.del_doc_num
INNER JOIN pbi.perform_itm AL3            ON AL2.itm_cd = AL3.itm_cd
INNER JOIN pbi.perform_inv_mnr AL5        ON AL3.mnr_cd = AL5.mnr_cd
INNER JOIN pbi.perform_inv_mjr AL4        ON AL4.mjr_cd = AL5.mjr_cd
INNER JOIN pbi.perform_table_opportunity AL6  ON AL1.alt_doc_num = AL6.s_id
INNER JOIN pbi.perform_table_employee AL7     ON AL7.objid = AL6.x_referred_by2employee
INNER JOIN pbi.perform_table_user AL8         ON AL7.employee2user = AL8.objid
INNER JOIN pbi.perform_table_site AL9         ON AL7.supp_person_off2site = AL9.objid
INNER JOIN pbi.perform_table_x_district_info_lookup AL10 ON AL9.site_id = AL10.x_district

WHERE  
    AL1.ord_tp_cd = 'SAL'
    AND AL1.stat_cd = 'F'
    AND AL2.void_flag = 'N'

    -- All original filters below are UNCHANGED
    AND AL4.des IN ('AIR CONDITIONERS', 'AIR CONDITIONING', 'BOILER', 'BOILERS',
                    'ELECTRONIC RECOVERY.', 'ELECTRONIC RECOVERY', 'FURNACE', 'FURNACES',
                    'HEAT RECOVERY VENT.', 'IAQ AIR CLEANER', 'IAQ HUMIDIFIER', 'HEAT PUMP')
    AND AL5.des IN ('CENTRALLY DUCTED','VERTICAL STACKED HP','DUCTLESS OUTDOOR',
                    'GEOTHERMAL','PTAC HP','AIR HANDLER','ATMOSPHERIC BURNER',
                    'AUXILIARY','BURNER','CENTRAL','CHILLERS','CONVENTIONAL',
                    'DUCTLESS SPLIT','DYNAMIC','ELECTRONIC RECOVERY',
                    'ELECTRONIC RECOVERY.','FURNACE DRUM','FURNACE FLOW THRU',
                    'GCOMBO AIR/FP','GCOMBO BOILER/FP','GCOMBO FURNACE/AIR',
                    'GCOMBO FURNACE/FP','GCOMBO TWO FP','GCOMBO TWO FURNACES',
                    'GFURNACE OIL','GRAVITY','HEAT PUMP','HEAT RECOVERY VENT.',
                    'HEPA','HIGH EFFICIENCY','HIGH+','L2B','MID EFFICIENCY',
                    'POWER BURNER','PTAC','SPACE HEATER','SPACE HTR ELEC',
                    'SPACE HTR LP','SPACEPACK','WALL UNIT','WALL UNITS')
    AND AL10.x_ops_group_code IN ('CA', 'ELECTR', 'HIM', 'PLUMB')
    AND AL7.work_group IN ('Cleaner', 'Helpers', 'HIM', 'Installers', 'Service Technician')
    AND AL3.itm_cd NOT IN ('025129','026248','038105','033542','081630','086876',
                           '093216','098782','101786','127895','141236','141805',
                           '143602','168132','169929','173874','191721','204166',
                           '210829','246524','253740','262023','269463','288939',
                           '312142','325848','326216','330770','333559','339301',
                           '342402','374621','380242','381095','385073','388969',
                           '406728','408997','415094','423624','434483','441275',
                           '443910','446453','457681','490605','506208','511758',
                           '517076','523887','526169','529524','532209','533214',
                           '539993','540051','549587','565769','568800','572002',
                           '574778','579585','588963','589463','612312','621049',
                           '631117','632586','644673','644750','647073','681680',
                           '686814','704377','709344','710152','710623','724777',
                           '725440','728583','743038','744994','756332','756936',
                           '770620','778102','803098','810330','812698','819876',
                           '840088','847885','857346','881845','899262','932185',
                           '933637','942072','965024','978902','979994','979999',
                           '986543','992406','HTROUT','HTRRTN')
    AND SUBSTRING(AL8.s_login_name, LEN(AL8.s_login_name),1) NOT IN ('5','9')
    AND AL8.s_login_name <> 'SSUPPORT'
    AND AL3.vsn NOT LIKE 'BRR%'
    AND AL1.del_doc_num NOT IN (
        SELECT AL11.del_doc_num
        FROM   pbi.perform_so AL11
        INNER JOIN pbi.perform_so_ln AL12 ON AL12.del_doc_num = AL11.del_doc_num
        INNER JOIN pbi.perform_itm AL13 ON AL12.itm_cd = AL13.itm_cd
        WHERE  AL12.void_flag = 'N'
           AND AL13.des IN ('BRR SF SPECIAL DISCOUNT', 'BRR SF SPECIAL DISCOUNT TBD')
    )

    -- === NEW: Full Current Year Filter (Only change for YTD support) ===
    AND CAST(AL1.final_dt AS DATE) >= CAST(DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0) AS DATE)
    AND CAST(AL1.final_dt AS DATE) <= CAST(GETDATE() AS DATE);

GO