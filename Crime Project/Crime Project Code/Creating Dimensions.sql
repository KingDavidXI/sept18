USE [Crime Project];
GO

/*********************/
/*Creating Dimensions*/
/*********************/

/*****Creating CrimeType*****/

IF OBJECT_ID('Dim.Crime_Type','U') IS NOT NULL
DROP TABLE Dim.Crime_Type;

SELECT DISTINCT
--[Crime_ID]
--,[Date]
--,[Reported by]
-- ,[Falls within]
-- ,[Longitude]
-- ,[Latitude]
-- ,[Spatial_Location]
-- ,[LSOA code]
-- ,[LSOA name]
	[Crime type]
	-- ,[Last_Outcome_Category]
    ,CASE
	    WHEN [Crime type] = 'Anti-social behaviour' THEN 'Anti-social behaviour'
	    WHEN [Crime type] = 'Bicycle theft' THEN 'Bicycle theft'
	    WHEN [Crime type] = 'Burglary' THEN 'Burglary'
	    WHEN [Crime type] = 'Criminal damage and arson' THEN 'Criminal damage and arson'
	    WHEN [Crime type] = 'Drugs' THEN 'Drug Offences'
	    WHEN [Crime type] = 'Other crime' THEN 'Other Crime'
	    WHEN [Crime type] = 'Other theft' THEN 'Other Theft'
	    WHEN [Crime type] = 'Possession of weapons' THEN 'Public disorder and weapons'
	    WHEN [Crime type] = 'Public disorder and weapons' THEN 'Public disorder and weapons'
	    WHEN [Crime type] = 'Public order' THEN 'Public disorder and weapons'
	    WHEN [Crime type] = 'Robbery' THEN 'Robbery'
	    WHEN [Crime type] = 'Shoplifting' THEN 'Shoplifting'
	    WHEN [Crime type] = 'Theft from the person' THEN 'Theft from the person'
	    WHEN [Crime type] = 'Vehicle crime' THEN 'Vehicle crime'
	    WHEN [Crime type] = 'Violence and sexual offences' THEN 'Violent crime'
	    WHEN [Crime type] = 'Violent crime' THEN 'Violent crime'
	    ELSE NULL
	END [Classification]
INTO 
	Dim.Crime_Type
FROM 
	[STAGING].[Police_Crime_Data];

ALTER TABLE Dim.Crime_Type
ADD 
	Crime_Type_ID INT IDENTITY(1,1) NOT NULL;

/*****Creating Date*****/

ALTER TABLE Dim.[Date]
ADD 
	Date_ID INT IDENTITY(1,1) NOT NULL;

/****Creating Geography****/

IF OBJECT_ID('[Dim].[Geography]','U') IS NOT NULL
DROP TABLE [Dim].[Geography];

SELECT 
	sld.*
    ,rlld.SpatialObj [Spatial_LA_Code] --Adding only Local authority 
INTO 
	[Dim].[Geography]
FROM 
	Staging.Location_Data sld --Adding only Local authority 
	INNER JOIN
	[RAW].[LA_Location_Data] rlld
	ON sld.LA_Code = rlld.GSS_CODE;

ALTER TABLE Dim.[Geography]
ADD 
	Geography_ID INT IDENTITY(1,1) NOT NULL;

/*****Adding Date_ID to Pre_Fact_Table*****/

ALTER TABLE [Staging].[Police_Crime_Data]
ADD 
	[Date_ID] INT;

/*****Adding Geography_ID to Pre_Fact_Table*****/


ALTER TABLE [STAGING].[Police_Crime_Data]
ADD 
	[Geography_ID] INT;


/*****Adding Crime_Type_ID to Pre_Fact_Table*****/

ALTER TABLE [STAGING].[Police_Crime_Data]
ADD 
	[Crime_Type_ID] INT;

/*Staging Police Data at Month Level and LSOA Level*/
/*
UPDATE [Staging].[Police_Crime_Data]
  SET 
	 [Date_ID] = [Dim].[Date].[Date_ID]
FROM [Staging].[Police_Crime_Data]
	LEFT JOIN
	[Dim].[Date]
	ON DATEPART(mm,[Staging].[Police_Crime_Data].[Date]) = [Dim].[Date].[mnth]
	   AND DATEPART(yy,[Staging].[Police_Crime_Data].[Date]) = [Dim].[Date].[yr];

UPDATE [STAGING].[Police_Crime_Data]
  SET 
	 [Geography_ID] = [Dim].[Geography].[Geography_ID]
FROM [STAGING].[Police_Crime_Data]
	LEFT JOIN
	[Dim].[Geography]
	ON [STAGING].[Police_Crime_Data].[LSOA code]  = [Dim].[Geography].LSOA_Code
*/

/*****Staging Police Data at Year Level and LA Level*****/

UPDATE [Staging].[Police_Crime_Data]
  SET 
	 [Date_ID] = dd2.Date_ID_YR
FROM [STAGING].[Police_Crime_Data]
	INNER JOIN
     Dim.Date_V2 dd2
	ON [Staging].[Police_Crime_Data].[Date] = dd2.dt;

WITH CTE
-- create a temporary column which will allow assigning each LSOA to only one geography_ID based on Local Authority
	AS (SELECT 
		    *
		   ,FIRST_VALUE(Geography_ID) OVER(PARTITION BY LA_Code 
		    ORDER BY 
		    Geography_ID ASC) [Geography_ID_LA]
	    FROM 
		    DIM.Geography)
UPDATE [STAGING].[Police_Crime_Data]
  SET 
	[STAGING].[Police_Crime_Data].[Geography_ID] = CTE.Geography_ID_LA
FROM [STAGING].[Police_Crime_Data]
	INNER JOIN
	CTE
	ON [STAGING].[Police_Crime_Data].[LSOA code]  = CTE.LSOA_Code


/*****Adding CrimeType to Pre_Fact_Table*****/

UPDATE [STAGING].[Police_Crime_Data]
  SET 
	 [Crime_Type_ID] = [Dim].[Crime_Type].[Crime_Type_ID]
FROM [STAGING].[Police_Crime_Data]
	LEFT JOIN
	[Dim].[Crime_Type]
	ON [STAGING].[Police_Crime_Data].[Crime type] = [Dim].[Crime_Type].[Crime type];

/*****Creating Fact_Table*****/

IF OBJECT_ID('Dim.Fact_Table','U') IS NOT NULL
DROP TABLE Dim.Fact_Table;

SELECT 
	[Crime_ID]
	-- ,[Date]
	-- ,[Reported by]
	-- ,[Falls within]
    ,[Longitude]
    ,[Latitude]
    ,[Spatial_Location]
	-- ,[LSOA code]
	-- ,[LSOA name]
	--,[Crime type]
    ,[Last_Outcome_Category]
    ,[Date_ID]
    ,[Geography_ID]
    ,[Crime_Type_ID]
INTO 
	Dim.Fact_Table
FROM 
	[STAGING].[Police_Crime_Data];
	
ALTER TABLE Dim.[Fact_Table]
ADD 
	Fact_Table_ID INT IDENTITY(1,1) NOT NULL;

/*****Creating Households*****/

IF OBJECT_ID('[ATTR].[Households]','U') IS NOT NULL
DROP TABLE [ATTR].[Households];

WITH CTE
	AS (SELECT 
		    *
		   ,FIRST_VALUE(Geography_ID) OVER(PARTITION BY LA_Code
		    ORDER BY 
		    Geography_ID ASC) [Geography_ID_LA]
	    FROM 
		    DIM.Geography)
	SELECT 
		dd.Date_ID
	    ,CTE.Geography_ID_LA [Geography_ID]
	    ,MAX(swh.Working_Households)                                                      Working_Households
	    ,MAX(swh.Mixed_Households)                                                        Mixed_Households
	    ,MAX(swh.Workerless_Households)                                                   Workerless_Households
	    ,MAX(sht.Amt_Mortgage)                                                            Amt_Mortgage
	    ,MAX(sht.Amt_Own_Outright)                                                        Amt_Own_Outright
	    ,MAX(sht.[Amt_Rent_LA/HA])                                                        [Amt_Rent_LA/HA]
	    ,MAX(sht.Amt_Rent_Private)                                                        Amt_Rent_Private
	    ,MAX(sht.Conf_95_Mortgage)                                                        Conf_95_Mortgage
	    ,MAX(sht.Conf_95_Own_Outright)                                                    Conf_95_Own_Outright
	    ,MAX(sht.[Conf_95_Rent_LA/HA])                                                    [Conf_95_Rent_LA/HA]
	    ,MAX(sht.Conf_95_Rent_Private)                                                    Conf_95_Rent_Private
	    ,MAX(se.[FT_Pay_Weekly (£)])                                                      [FT_Pay_Weekly (£)]
	    ,MAX(se.[FT_Conf_Weekly (%)])                                                     [FT_Conf_Weekly (%)]
	    ,MAX(se.[PT_Pay_Weekly (£)])                                                      [PT_Pay_Weekly (£)]
	    ,MAX(se.[PT_Conf_Weekly (%)])                                                     [PT_Conf_Weekly (%)]
	    ,MAX(se.[FT_Pay_Weekly_Hourly (£)])                                               [FT_Pay_Weekly_Hourly (£)]
	    ,MAX(se.[FT_Conf_Weekly_Hourly (%)])                                              [FT_Conf_Weekly_Hourly (%)]
	    ,MAX(se.[PT_Pay_Weekly_Hourly (£)])                                               [PT_Pay_Weekly_Hourly (£)]
	    ,MAX(se.[PT_Conf_Weekly_Hourly (%)])                                              [PT_Conf_Weekly_Hourly (%)]
	    ,MAX(shc.[One_Person_Household: Aged 65 and over])                                [One_Person_Household: Aged 65 and over]
	    ,MAX(shc.[One_Person_Household: Other])                                           [One_Person_Household: Other]
	    ,MAX(shc.[One_Family_Household: All aged 65 and over])                            [One_Family_Household: All aged 65 and over]
	    ,MAX(shc.[One_Family_Household: Married or same-sex civil partnership couple: N]) [One_Family_Household: Married or same-sex civil partnership couple: N]
	    ,MAX(shc.[One_Family_Household: Married or same-sex civil partnership couple: D]) [One_Family_Household: Married or same-sex civil partnership couple: D]
	    ,MAX(shc.[One_Family_Household: Married or same-sex civil partnership couple: A]) [One_Family_Household: Married or same-sex civil partnership couple: A]
	    ,MAX(shc.[One_Family_Household: Cohabiting couple: No children])                  [One_Family_Household: Cohabiting couple: No children]
	    ,MAX(shc.[One_Family_Household: Cohabiting couple: Dependent children])           [One_Family_Household: Cohabiting couple: Dependent children]
	    ,MAX(shc.[One_Family_Household: Cohabiting couple: All children non-dependent])   [One_Family_Household: Cohabiting couple: All children non-dependent]
	    ,MAX(shc.[One_Family_Household: Lone parent: Dependent children])                 [One_Family_Household: Lone parent: Dependent children]
	    ,MAX(shc.[One_Family_Household: Lone parent: All children non-dependent])         [One_Family_Household: Lone parent: All children non-dependent]
	    ,MAX(shc.[Other_Household: With dependent children])                              [Other_Household: With dependent children]
	    ,MAX(shc.[Other_Household: All full-time students])                               [Other_Household: All full-time students]
	    ,MAX(shc.[Other_Household: All aged 65 and over])                                 [Other_Household: All aged 65 and over]
	    ,MAX(shc.[Other_Household: Other])                                                [Other_Household: Other]
	INTO 
		[ATTR].households
	FROM 
		[STAGING].[Workerless_Households] swh
		FULL JOIN
		[STAGING].[Housing_Tenure] sht
		ON swh.LA_Code = sht.LSOA
		   AND swh.Date = sht.Date
		FULL JOIN
		[STAGING].Earnings_Total se
		ON swh.LA_Code = se.LA_Code
		   AND swh.date = se.date
		FULL JOIN
		[STAGING].[2011_Household_Composition] shc
		ON swh.LA_Code = shc.LA_Code
		   AND swh.date = shc.date
		FULL JOIN
		DIM.Date dd
		ON dd.dt = swh.Date
		   OR dd.dt = sht.Date
		   OR dd.dt = se.Date
		FULL JOIN
		CTE
		ON CTE.LA_Code = swh.LA_Code
		   OR CTE.LA_Code = sht.LSOA
		   OR CTE.LA_Code = se.LA_Code
		   OR CTE.LA_Code = shc.LA_Code
	WHERE dd.dt IS NOT NULL
		 AND (swh.date IS NOT NULL
			 OR se.Date IS NOT NULL
			 OR sht.Date IS NOT NULL)
		 AND (swh.Working_Households IS NOT NULL
			 OR swh.Mixed_Households IS NOT NULL
			 OR swh.Workerless_Households IS NOT NULL
			 OR sht.Amt_Mortgage IS NOT NULL
			 OR sht.Amt_Own_Outright IS NOT NULL
			 OR sht.[Amt_Rent_LA/HA] IS NOT NULL
			 OR sht.Amt_Rent_Private IS NOT NULL
			 OR sht.Conf_95_Mortgage IS NOT NULL
			 OR sht.Conf_95_Own_Outright IS NOT NULL
			 OR sht.[Conf_95_Rent_LA/HA] IS NOT NULL
			 OR sht.Conf_95_Rent_Private IS NOT NULL
			 OR se.[FT_Pay_Weekly (£)] IS NOT NULL
			 OR se.[FT_Conf_Weekly (%)] IS NOT NULL
			 OR se.[PT_Pay_Weekly (£)] IS NOT NULL
			 OR se.[PT_Conf_Weekly (%)] IS NOT NULL
			 OR se.[FT_Pay_Weekly_Hourly (£)] IS NOT NULL
			 OR se.[FT_Conf_Weekly_Hourly (%)] IS NOT NULL
			 OR se.[PT_Pay_Weekly_Hourly (£)] IS NOT NULL
			 OR se.[PT_Conf_Weekly_Hourly (%)] IS NOT NULL)
	GROUP BY 
		dd.Date_ID
	    ,CTE.Geography_ID_LA
	ORDER BY 
		dd.Date_ID ASC;

/*****Creating Inflation*****/

ALTER TABLE [Staging].[Inflation]
ADD 
	[Date_ID] INT;

UPDATE [Staging].[Inflation]
  SET 
	 staging.inflation.[Date_ID] = [Dim].[Date].[Date_ID]
FROM [Staging].[Inflation]
	INNER JOIN
	[Dim].[Date]
	ON STAGING.Inflation.Date = [Dim].[Date].dt

SELECT 
	[CPIH_Index]
    --,[Date]
    ,[Date_ID]
INTO
    ATTR.Inflation
FROM 
	[STAGING].[Inflation]


/*****Creating Population*****/

ALTER TABLE [STAGING].[Population_Data]
ADD 
	[Geography_ID] INT;

WITH CTE
	AS (SELECT 
		    *
		   ,FIRST_VALUE(Geography_ID) OVER(PARTITION BY LA_Code
		    ORDER BY 
		    Geography_ID ASC) [Geography_ID_LA]
	    FROM 
		    DIM.Geography)
UPDATE [STAGING].[Population_Data]
  SET 
	[STAGING].[Population_Data].Geography_ID = CTE.Geography_ID_LA
FROM 
	[STAGING].[Population_Data]
INNER JOIN
CTE
ON CTE.LA_Name = [STAGING].[Population_Data].LA_Name

ALTER TABLE [STAGING].[Population_Data]
ADD 
	[Date_ID] INT;


UPDATE [STAGING].[Population_Data]
  SET 
	 [Date_ID] = dd.Date_ID_YR
FROM [STAGING].[Population_Data]
	INNER JOIN
(
    SELECT 
	    dd.*
	   ,FIRST_VALUE(Dd.Date_ID) OVER(PARTITION BY dd.yr
	    ORDER BY 
	    Dd.yr) Date_ID_YR
    FROM 
	    DIM.Date dd
) dd
	ON [STAGING].[Population_Data].Date = dd.dt

IF OBJECT_ID('ATTR.Population_Data','U') IS NOT NULL
DROP TABLE ATTR.Population_Data;

SELECT
--LA_Name
Population
--,Date
,Date_ID
,Geography_ID
INTO
ATTR.Population_Data
FROM
STAGING.Population_Data
WHERE
Date_ID IS NOT NULL and Geography_ID IS NOT NULL

/*****Assigning Keys****/

ALTER TABLE Dim.Geography
ADD PRIMARY KEY (Geography_ID);

ALTER TABLE Dim.Date
ADD PRIMARY KEY (Date_ID);

ALTER TABLE Dim.Crime_Type
ADD PRIMARY KEY (Crime_Type_ID);

ALTER TABLE Dim.Fact_Table
ADD PRIMARY KEY (Fact_Table_ID);

alter table Dim.Fact_Table
add constraint FK_Geography FOREIGN KEY (Geography_ID)
references Dim.Geography(Geography_ID)

alter table Dim.Fact_Table
add constraint FK_Date FOREIGN KEY (Date_ID)
references Dim.Date(Date_ID)

alter table Dim.Fact_Table
add constraint FK_Crime_Type FOREIGN KEY (Crime_Type_ID)
references Dim.Crime_Type(Crime_Type_ID)

alter table Attr.Households
add constraint FK_Date_Attr FOREIGN KEY (Date_ID)
references Dim.Date(Date_ID)

alter table Attr.Households
add constraint FK_Geography_Attr FOREIGN KEY (Geography_ID)
references Dim.Geography(Geography_ID)

alter table Attr.Population_Data
add constraint FK_Date_Attr_2 FOREIGN KEY (Date_ID)
references Dim.Date(Date_ID)

alter table Attr.Population_Data
add constraint FK_Geography_Attr_2 FOREIGN KEY (Geography_ID)
references Dim.Geography(Geography_ID)

alter table Attr.Inflation
add constraint FK_Date_Attr_3 FOREIGN KEY (Date_ID)
references Dim.Date(Date_ID)

   