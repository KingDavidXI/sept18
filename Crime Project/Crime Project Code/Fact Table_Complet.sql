
USE [Crime Project];
GO

SELECT 
	Fact_Table_ID
    ,[Crime_ID]
    ,[Longitude]
    ,[Latitude]
    ,[Spatial_Location]
    ,[Last_Outcome_Category]
    ,[dt]
    ,[yr]
    ,[mnth]
    ,[dy]
    ,[dynm]
    ,[isWeekDay]
    ,[Season]
    ,[LSOA_Code]
    ,[LSOA_Name]
    ,[MSOA_Code]
    ,[MSOA_Name]
    ,[LA_Code]
    ,[Old_LA_Code]
    ,[LA_Name]
    ,[Region_Code]
    ,[Region_Name]
	-- ,[Spatial_LSOA_Code]
	-- ,[Spatial_LA_Code]
    ,[Crime type]
    ,[Classification]
    ,[Working_Households]
    ,[Mixed_Households]
    ,[Workerless_Households]
    ,[Amt_Mortgage]
    ,[Amt_Own_Outright]
    ,[Amt_Rent_LA/HA]
    ,[Amt_Rent_Private]
    ,[Conf_95_Mortgage]
    ,[Conf_95_Own_Outright]
    ,[Conf_95_Rent_LA/HA]
    ,[Conf_95_Rent_Private]
    ,[FT_Pay_Weekly (£)]
    ,[FT_Conf_Weekly (%)]
    ,[PT_Pay_Weekly (£)]
    ,[PT_Conf_Weekly (%)]
    ,[FT_Pay_Weekly_Hourly (£)]
    ,[FT_Conf_Weekly_Hourly (%)]
    ,[PT_Pay_Weekly_Hourly (£)]
    ,[PT_Conf_Weekly_Hourly (%)]
    ,[One_Person_Household: Aged 65 and over]
    ,[One_Person_Household: Other]
    ,[One_Family_Household: All aged 65 and over]
    ,[One_Family_Household: Married or same-sex civil partnership couple: N]
    ,[One_Family_Household: Married or same-sex civil partnership couple: D]
    ,[One_Family_Household: Married or same-sex civil partnership couple: A]
    ,[One_Family_Household: Cohabiting couple: No children]
    ,[One_Family_Household: Cohabiting couple: Dependent children]
    ,[One_Family_Household: Cohabiting couple: All children non-dependent]
    ,[One_Family_Household: Lone parent: Dependent children]
    ,[One_Family_Household: Lone parent: All children non-dependent]
    ,[Other_Household: With dependent children]
    ,[Other_Household: All full-time students]
    ,[Other_Household: All aged 65 and over]
    ,[Other_Household: Other]
    ,[Population]
    ,ai.CPIH_Index
    ,awb.London_Living_Wage
    ,awb.National_Wage
FROM 
	Dim.Fact_Table spcd
	INNER JOIN
	Dim.Date dd
	ON dd.Date_ID = spcd.Date_ID
	INNER JOIN
	DIM.Geography dg
	ON dg.Geography_ID = spcd.Geography_ID
	INNER JOIN
	dim.Crime_Type dct
	ON dct.Crime_Type_ID = spcd.Crime_Type_ID
	INNER JOIN
	attr.households ah
	ON dg.Geography_ID = ah.Geography_ID
	   AND spcd.Date_ID = ah.Date_ID
	INNER JOIN
	attr.Population_Data apd
	ON dg.Geography_ID = apd.Geography_ID
	   AND spcd.Date_ID = apd.Date_ID
	INNER JOIN
	attr.Inflation ai
	ON dd.Date_ID = ai.Date_ID
	INNER JOIN
	attr.Wage_Boundaries awb
	ON spcd.Date_ID = awb.Date_ID;