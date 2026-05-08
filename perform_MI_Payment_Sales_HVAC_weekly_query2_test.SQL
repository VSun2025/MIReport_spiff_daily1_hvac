/****** Object:  View [pbi].[perform_MI_Payment_Sales_HVAC_weekly_query2]    Script Date: 5/8/2026 10:45:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE   view  [pbi].[perform_MI_Payment_Sales_HVAC_weekly_query2] as 
SELECT AL7.employee_no as [Employee ID],
       AL7.s_first_name as [First Name],
       AL7.s_last_name as [Last Name],
       AL6.s_id as [Reference ID],
       Cast(AL1.final_dt AS DATE) as [Final Date],
       AL3.itm_cd as [Itm Cd],
       AL4.des as Product,
       AL5.des [Product Minor],
       AL1.del_doc_num as [SO Ref],
       AL8.s_login_name as [Ref Login],
       AL7.work_group as [Job Title],
       AL1.so_store_cd as [Patch Code],
       Cast(Getdate() AS DATE) as RunDate,
       AL6.x_creation_time as [Creation Date],
       AL1.so_wr_dt as [Written Date],
       AL3.vsn as SKU,
       AL1.pu_del_date as [Install Date],
       Isnull(AL1.ship_to_addr1, '') + ' '
       + Isnull(AL1.ship_to_addr2, '') as [Customer Address],
       AL1.ship_to_zip_code as [Postal Cd],
       AL8.s_login_name as [Employee Login],
       AL10.s_login_name as [Originator Login],
       AL11.work_group as [Originator Work Group],
       AL9.site_id as [Site Id],
       AL12.s_name as [Lead Source],
	   case when AL8.s_login_name != AL10.s_login_name  then '1' else '0' end as keep,
	   case when AL11.work_group= 'Sales Support Clerk' then case when AL8.s_login_name != AL10.s_login_name  then '1' else '0' end else '0' end as [Eligible For Points],
	   CASE WHEN AL4.des ='IAQ AIR CLEANER' then 'Accessories'
			WHEN AL4.des in ('AIR CONDITIONING','AIR CONDITIONERS','BOILER','BOILERS', 'ELECTRONIC RECOVERY','FURNACE','FURNACES', 'HEAT RECOVERY VENT.','HEAT PUMP') then 'BigBox'
			WHEN AL4.des in ('IAQ HUMIDIFIER') then 'Humidifier'
			ELSE 'Other' END as [Product Type]
FROM   pbi.perform_so AL1,
       pbi.perform_so_ln AL2,
       pbi.perform_itm AL3,
       pbi.perform_inv_mjr AL4,
       pbi.perform_inv_mnr AL5,
       pbi.perform_table_opportunity AL6,
       pbi.perform_table_employee AL7,
       pbi.perform_table_user AL8,
       pbi.perform_table_site AL9,
       pbi.perform_table_user AL10,
       pbi.perform_table_employee AL11,
       pbi.perform_table_lead_source AL12
WHERE  ( AL2.itm_cd = AL3.itm_cd
         AND AL2.del_doc_num = AL1.del_doc_num
         AND AL4.mjr_cd = AL5.mjr_cd
         AND AL3.mnr_cd = AL5.mnr_cd
         AND AL1.alt_doc_num = AL6.s_id
         AND AL7.objid = AL6.x_referred_by2employee
         AND AL7.employee2user = AL8.objid
         AND AL7.supp_person_off2site = AL9.objid
         AND AL6.opp_originator2user = AL10.objid
         AND AL11.employee2user = AL10.objid
         AND AL6.opp2lead_source = AL12.objid )
       AND ( Cast(AL1.final_dt AS DATE) BETWEEN cast(DATEADD(wk, DATEDIFF(wk, 18, GETDATE()), 8) as date) AND
            Cast(Dateadd(wk, Datediff(wk, 6, Getdate ()), 7) AS DATE)
             AND AL1.ord_tp_cd = 'SAL'
             AND AL1.stat_cd = 'F'
             AND AL2.void_flag = 'N'
             AND AL4.des IN ( 'AIR CONDITIONERS', 'AIR CONDITIONING', 'BOILER',
                              'BOILERS',
                              'ELECTRONIC RECOVERY.', 'ELECTRONIC RECOVERY', 'FURNACE',  -- added 'ELECTRONIC RECOVERY' ON 20260424
                                  'HEAT RECOVERY VENT.',
                              'IAQ AIR CLEANER', 'IAQ HUMIDIFIER', 'HEAT PUMP' )
             AND AL5.des IN ( 'CENTRALLY DUCTED',
'VERTICAL STACKED HP',
'DUCTLESS OUTDOOR',
'GEOTHERMAL',
'PTAC HP','AIR HANDLER', 'ATMOSPHERIC BURNER', 'AUXILIARY',
                              'BURNER',
                              'CENTRAL', 'CHILLERS', 'CONVENTIONAL',
                              'DUCTLESS SPLIT',
                              'DYNAMIC', 'ELECTRONIC RECOVERY', 'ELECTROSTATIC', 'ELECTRONIC RECOVERY.', -- added 'ELECTRONIC RECOVERY.' ON 20260424
                              'FURNACE DRUM',
                              'FURNACE FLOW THRU', 'GCOMBO AIR/FP',
                              'GCOMBO BOILER/FP',
                                  'GCOMBO FURNACE/AIR'
                                             ,
                              'GCOMBO FURNACE/FP', 'GCOMBO TWO FP',
                              'GCOMBO TWO FURNACES',
                                  'GFURNACE OIL',
                              'GRAVITY', 'HEAT PUMP', 'HEAT RECOVERY VENT.',
                              'HEPA',
                              'HIGH EFFICIENCY', 'HIGH+', 'L2B',
                              'MID EFFICIENCY',
                              'POWER BURNER', 'PTAC', 'SPACE HEATER',
                              'SPACE HTR ELEC',
                              'SPACE HTR LP', 'SPACEPACK', 'WALL UNIT',
                              'WALL UNITS' )
             AND AL7.work_group IN ( 'Admin. Assistant', 'Billing Operations',
                                     'Business Analyst'
                                     , 'CCA',
                                     'Charged Up (Non-Access)', 'Claims',
                                     'Contract Processing',
                                         'District Manager'
                                                           ,
                                     'EST', 'Field Manager', 'Finance',
                                     'Home Services Ops'
                                     ,
                                     'Install Clerk', 'Install Planning', 'IT',
                                     'M&L',
                                     'Marketing', 'Ops Support Clerk',
                                     'Process Analyst',
                                         'Reconciliation',
                                     'Sales Support Clerk', 'Service Clerical',
                                     'Service Clerk',
                                         'Service Planning'
                                                           ,
                                     'Super Office Admin', 'Tech Desk',
                                     'Tech Desk Supervisor',
                                         'Workload Planning' )
             AND AL9.site_id IN ( 'INT20', 'INT71', 'SCEAST', 'SCWEST', 'SMLCOM'
                                )
			AND AL3.itm_cd not in ('025129',
'026248',
'038105',
'033542',
'081630',
'086876',
'093216',
'098782',
'101786',
'127895',
'141236',
'141805',
'143602',
'168132',
'169929',
'173874',
'191721',
'204166',
'210829',
'246524',
'253740',
'262023',
'269463',
'288939',
'312142',
'325848',
'326216',
'330770',
'333559',
'339301',
'342402',
'374621',
'380242',
'381095',
'385073',
'388969',
'406728',
'408997',
'415094',
'423624',
'434483',
'441275',
'443910',
'446453',
'457681',
'490605',
'506208',
'511758',
'517076',
'523887',
'526169',
'529524',
'532209',
'533214',
'539993',
'540051',
'549587',
'565769',
'568800',
'572002',
'574778',
'579585',
'588963',
'589463',
'612312',
'621049',
'631117',
'632586',
'644673',
'644750',
'647073',
'681680',
'686814',
'704377',
'709344',
'710152',
'710623',
'724777',
'725440',
'728583',
'743038',
'744994',
'756332',
'756936',
'770620',
'778102',
'803098',
'810330',
'812698',
'819876',
'840088',
'847885',
'857346',
'881845',
'899262',
'932185',
'933637',
'942072',
'965024',
'978902',
'979994',
'979999',
'986543',
'992406',
'HTROUT',
'HTRRTN')

AND SUBSTRING(AL8.s_login_name, LEN(AL8.s_login_name),1) <> '5'
AND AL3.vsn NOT LIKE 'BRR%' 
/* New as of March 2026 START */
AND AL1.del_doc_num NOT IN (SELECT AL11.del_doc_num
                                     FROM   pbi.perform_so AL11,
                                            pbi.perform_so_ln AL12,
                                            pbi.perform_itm AL13
                                     WHERE  ( AL12.itm_cd = AL13.itm_cd AND AL12.del_doc_num = AL11.del_doc_num )                                            
                                     AND AL12.void_flag = 'N'
									 AND (AL13.des IN ('BRR SF SPECIAL DISCOUNT', 'BRR SF SPECIAL DISCOUNT TBD') ))
/* New as of March 2026 END */
)
GO


