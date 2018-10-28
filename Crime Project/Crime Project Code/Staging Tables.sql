
USE [Kubrick Crime Project];
GO

/*****************/
/*Staging Tables*/
/*****************/

/*****Staging Workerless_Housholds*****/

IF OBJECT_ID('[STAGING].[Workerless_Households]','U') IS NOT NULL
DROP TABLE [STAGING].[Workerless_Households];

SELECT DISTINCT
--cwh.LA_Code
	cwh.LA_Name
    ,cwh.Working_Households
	--,[Working Households : Per cent]
    ,cwh.Mixed_Households
	-- ,[Mixed Households : Per cent]
    ,cwh.Workerless_Households
	-- ,[Workless Households : Per cent]
    ,cwh.[Date]
	--,sdg.Old_LA_Code
	--,sdg.LA_Code
	--,cld2.Old_LA_Code
	--  ,cld2.LA_Code [Test_2]
    ,COALESCE(cld2.LA_Code,cld.LA_Code) [LA_Code] --Update old LA code with new LA Code
INTO 
	[STAGING].[Workerless_Households]
FROM 
	[CLEAN].[Workerless_Households] cwh
	LEFT JOIN
	CLEAN.Location_Data cld
	ON cwh.LA_Code = cld.Old_LA_Code
	LEFT JOIN
	CLEAN.Location_Data cld2
	ON cwh.LA_Code = cld2.LA_Code
WHERE COALESCE(cld2.LA_Code,cld.LA_Code) IS NOT NULL
ORDER BY 
	LA_Code ASC
    ,cwh.[Date] ASC;

/*****Staging Workerless_Housholds*****/

IF OBJECT_ID('STAGING.[Deprivation]','U') IS NOT NULL
DROP TABLE STAGING.[Deprivation];

SELECT 
	[LSOA code (2011)]
    ,[LSOA name (2011)]
    ,[Local Authority District code (2013)]
    ,[Local Authority District name (2013)]
    ,[IMD Score]
INTO 
	STAGING.[Deprivation]
FROM 
	[CLEAN].[Deprivation]

/*****Staging Earnings_Total*****/

IF OBJECT_ID('STAGING.[Earnings_Total]','U') IS NOT NULL
DROP TABLE STAGING.[Earnings_Total];

SELECT DISTINCT 
--[Code]                             [LA_Code]
	COALESCE(cld2.LA_Code,cld.LA_Code) [LA_Code]
    ,[Area]
    ,[FT_Pay_Weekly (£)]
    ,[FT_Conf_Weekly (%)]
    ,[PT_Pay_Weekly (£)]
    ,[PT_Conf_Weekly (%)]
    ,[FT_Pay_Weekly_Hourly (£)]
    ,[FT_Conf_Weekly_Hourly (%)]
    ,[PT_Pay_Weekly_Hourly (£)]
    ,[PT_Conf_Weekly_Hourly (%)]
    ,[Date]
INTO 
	STAGING.[Earnings_Total]
FROM 
	[CLEAN].[Earnings_Total] cet
	LEFT JOIN
	CLEAN.Location_Data cld
	ON cet.Code = cld.Old_LA_Code
	LEFT JOIN
	CLEAN.Location_Data cld2
	ON cet.Code = cld2.LA_Code;

/*****Staging Income_Support*****/

IF OBJECT_ID('STAGING.Income_Support','U') IS NOT NULL
DROP TABLE STAGING.Income_Support;

SELECT 
	[Code]
    ,[Area]
    ,[Income_Support (Count)]
    ,[Date]
INTO 
	STAGING.Income_Support
FROM 
	[CLEAN].[Income_Support];

/*****Staging Personal_Insolvency*****/

IF OBJECT_ID('[STAGING].[Personal_Insolvancy]','U') IS NOT NULL
DROP TABLE [STAGING].[Personal_Insolvancy];

SELECT DISTINCT
	--[Code]
    COALESCE(cld2.LA_Code,cld.LA_Code) [LA_Code]
    ,[Area]
    ,[New Personal Insolvencies (counts)]
    ,[New Bankruptcy Orders (counts)]
    ,[New Individual Voluntary Arrangements (IVAs) (counts)]
    ,[New Debt Relief Orders (DROs) (counts)]
    ,[Date]
INTO
    [STAGING].[Personal_Insolvancy]
FROM 
	[CLEAN].[Personal_Insovlency] cpi
	LEFT JOIN
	CLEAN.Location_Data cld
	ON cpi.Code = cld.Old_LA_Code
	LEFT JOIN
	CLEAN.Location_Data cld2
	ON cpi.Code = cld2.LA_Code
WHERE COALESCE(cld2.LA_Code,cld.LA_Code) IS NOT NULL

/*****Staging Police_Crime_Data*****/

IF OBJECT_ID('[STAGING].[Police_Crime_Data]','U') IS NOT NULL
DROP TABLE [STAGING].[Police_Crime_Data];

SELECT 
	[Crime_ID]
    ,[Date]
    ,[Reported by]
    ,[Falls within]
    ,[Longitude]
    ,[Latitude]
    ,[Spatial_Location]
    ,[LSOA code]
    ,[LSOA name]
    ,[Crime type]
    ,[Last_Outcome_Category]
INTO
    STAGING.Police_Crime_Data
FROM 
	[CLEAN].[Police_Crime_Data]

/*****Staging House_Tenure*****/

IF OBJECT_ID('[STAGING].[Housing_Tenure]','U') IS NOT NULL
DROP TABLE [STAGING].[Housing_Tenure];

SELECT 
	[LSOA]
    ,[LSOA_Name]
    ,[Amt_Own_Outright]
    ,[Amt_Mortgage]
    ,[Amt_Rent_LA/HA]
    ,[Amt_Rent_Private]
    ,[Conf_95_Own_Outright]
    ,[Conf_95_Mortgage]
    ,[Conf_95_Rent_LA/HA]
    ,[Conf_95_Rent_Private]
    ,[Date]
INTO
    STAGING.Housing_Tenure
FROM 
	[CLEAN].[Housing_Tenure]

/*****Staging Location_Data*****/

IF OBJECT_ID('[STAGING].[Location_Data]','U') IS NOT NULL
DROP TABLE [STAGING].[Location_Data];

SELECT 
	[LSOA_Code]
    ,[LSOA_Name]
    ,[MSOA_Code]
    ,[MSOA_Name]
    ,[LA_Code]
    ,[Old_LA_Code]
    ,[LA_Name]
    ,[Region_Code]
    ,[Region_Name]
    ,[Spatial_LSOA_Code]
INTO 
	[STAGING].[Location_Data]
FROM 
	[CLEAN].[Location_Data]

/*****Staging Household_Composition*****/


IF OBJECT_ID('[STAGING].[2011_Household_Composition]','U') IS NOT NULL
DROP TABLE [STAGING].[2011_Household_Composition];

SELECT 
	[LA_Code]
    ,[LA_Name]
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
    ,[Date]
INTO 
    [STAGING].[2011_Household_Composition]
FROM 
	[CLEAN].[2011_Household_Composition]
    
/*****Staging Inflation*****/

IF OBJECT_ID('STAGING.Inflation','U') IS NOT NULL
DROP TABLE STAGING.Inflation;

SELECT 
	[CPIH_Index]
    ,[Date]
INTO
    STAGING.Inflation
FROM 
	[CLEAN].[Inflation];

/*****Staging Population*****/

IF OBJECT_ID('STAGING.Population_Data','U') IS NOT NULL
DROP TABLE STAGING.Population_Data;

SELECT 
	[LA_Name]
    ,[Population]
    ,[Date]
INTO
STAGING.Population_Data
FROM 
	[Crime Project].[CLEAN].[Population_Data]
