USE 
[Crime Project]
GO

/*****************/
/*Cleaning Tables*/
/*****************/

/*Cleaning Deprivation*/

IF OBJECT_ID('[CLEAN].[Deprivation]','U') IS NOT NULL
DROP TABLE [CLEAN].[Deprivation];

SELECT 
	[LSOA code (2011)]
    ,[LSOA name (2011)]
    ,[Local Authority District code (2013)]
    ,[Local Authority District name (2013)]
    ,[IMD Score]
--,[IMD Rank (where 1 is most deprived)]
--,[IMD Decile (where 1 is most deprived 10% of LSOAs)]
--,[Income Score (rate)]
--,[Income Rank (where 1 is most deprived)]
--,[Income Decile (where 1 is most deprived 10% of LSOAs)]
--,[Employment Score (rate)]
--,[Employment Rank (where 1 is most deprived)]
--,[Employment Decile (where 1 is most deprived 10% of LSOAs)]
--,[Education, Skills and Training Score]
--,[Education, Skills and Training Rank (where 1 is most deprived)]
--,[Education, Skills and Training Decile (where 1 is most deprived ]
--,[Health Deprivation and Disability Score]
--,[Health Deprivation and Disability Rank (where 1 is most deprived]
--,[Health Deprivation and Disability Decile (where 1 is most depriv]
--,[Crime Score]
--,[Crime Rank (where 1 is most deprived)]
--,[Crime Decile (where 1 is most deprived 10% of LSOAs)]
--,[Barriers to Housing and Services Score]
--,[Barriers to Housing and Services Rank (where 1 is most deprived)]
--,[Barriers to Housing and Services Decile (where 1 is most deprive]
--,[Living Environment Score]
--,[Living Environment Rank (where 1 is most deprived)]
--,[Living Environment Decile (where 1 is most deprived 10% of LSOAs]
INTO 
	[CLEAN].[Deprivation]
FROM 
	[RAW].[Deprivation];

/*Cleaning Earnings*/

IF OBJECT_ID('[CLEAN].[Earnings_FT]','U') IS NOT NULL
DROP TABLE [CLEAN].[Earnings_FT];

WITH CTE
	AS (SELECT 
		    *
		   ,SUBSTRING([Column],CHARINDEX('- ',[Column])+2,LEN([Column])) [Year] --Create year column
	    FROM
	    (
		   SELECT 
			   [Code]
			  ,[Area]
			  ,[F3]  [Pay (£) - 2002]
			  ,[F4]  [Conf (%) - 2002]
			  ,[F5]  [Pay (£) - 2003]
			  ,[F6]  [Conf (%) - 2003]
			  ,[F7]  [Pay (£) - 2004]
			  ,[F8]  [Conf (%) - 2004]
			  ,[F9]  [Pay (£) - 2005]
			  ,[F10] [Conf (%) - 2005]
			  ,[F11] [Pay (£) - 2006]
			  ,[F12] [Conf (%) - 2006]
			  ,[F13] [Pay (£) - 2007]
			  ,[F14] [Conf (%) - 2007]
			  ,[F15] [Pay (£) - 2008]
			  ,[F16] [Conf (%) - 2008]
			  ,[F17] [Pay (£) - 2009]
			  ,[F18] [Conf (%) - 2009]
			  ,[F19] [Pay (£) - 2010]
			  ,[F20] [Conf (%) - 2010]
			  ,[F21] [Pay (£) - 2011]
			  ,[F22] [Conf (%) - 2011]
			  ,[F23] [Pay (£) - 2012]
			  ,[F24] [Conf (%) - 2012]
			  ,[F25] [Pay (£) - 2013]
			  ,[F26] [Conf (%) - 2013]
			  ,[F27] [Pay (£) - 2014]
			  ,[F28] [Conf (%) - 2014]
			  ,[F29] [Pay (£) - 2015]
			  ,[F30] [Conf (%) - 2015]
			  ,[F31] [Pay (£) - 2016]
			  ,[F32] [Conf (%) - 2016]
			  ,[F33] [Pay (£) - 2017]
			  ,[F34] [Conf (%) - 2017]
		   FROM 
			   [RAW].[Earnings_FT]
		   WHERE Code IS NOT NULL 
			    AND AREA IS NOT NULL
	    ) c UNPIVOT([Value] FOR [Column] IN(
		    [Pay (£) - 2002]
		   ,[Conf (%) - 2002]
		   ,[Pay (£) - 2003]
		   ,[Conf (%) - 2003]
		   ,[Pay (£) - 2004]
		   ,[Conf (%) - 2004]
		   ,[Pay (£) - 2005]
		   ,[Conf (%) - 2005]
		   ,[Pay (£) - 2006]
		   ,[Conf (%) - 2006]
		   ,[Pay (£) - 2007]
		   ,[Conf (%) - 2007]
		   ,[Pay (£) - 2008]
		   ,[Conf (%) - 2008]
		   ,[Pay (£) - 2009]
		   ,[Conf (%) - 2009]
		   ,[Pay (£) - 2010]
		   ,[Conf (%) - 2010]
		   ,[Pay (£) - 2011]
		   ,[Conf (%) - 2011]
		   ,[Pay (£) - 2012]
		   ,[Conf (%) - 2012]
		   ,[Pay (£) - 2013]
		   ,[Conf (%) - 2013]
		   ,[Pay (£) - 2014]
		   ,[Conf (%) - 2014]
		   ,[Pay (£) - 2015]
		   ,[Conf (%) - 2015]
		   ,[Pay (£) - 2016]
		   ,[Conf (%) - 2016]
		   ,[Pay (£) - 2017]
		   ,[Conf (%) - 2017])) unpiv)
	SELECT 
		Code
	    ,Area
	    ,MAX(CASE
			   WHEN CHARINDEX('Pay (£)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Pay_Weekly (£)]
	    ,MAX(CASE
			   WHEN CHARINDEX('Conf (%)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Conf_Weekly (%)]
	    ,[Year]
	INTO 
		CLEAN.Earnings_FT
	FROM 
		CTE
	WHERE [Code] IS NOT NULL
		 AND LEN(code) > 2
	GROUP BY 
		Code
	    ,Area
	    ,Year;

IF OBJECT_ID('[CLEAN].[Earnings_PT]','U') IS NOT NULL
DROP TABLE [CLEAN].[Earnings_PT];

WITH CTE
	AS (SELECT 
		    *
		   ,SUBSTRING([Column],CHARINDEX('- ',[Column])+2,LEN([Column])) [Year]
	    FROM
	    (
		   SELECT 
			   [Code]
			  ,[Area]
			  ,[F3]  [Pay (£) - 2002]
			  ,[F4]  [Conf (%) - 2002]
			  ,[F5]  [Pay (£) - 2003]
			  ,[F6]  [Conf (%) - 2003]
			  ,[F7]  [Pay (£) - 2004]
			  ,[F8]  [Conf (%) - 2004]
			  ,[F9]  [Pay (£) - 2005]
			  ,[F10] [Conf (%) - 2005]
			  ,[F11] [Pay (£) - 2006]
			  ,[F12] [Conf (%) - 2006]
			  ,[F13] [Pay (£) - 2007]
			  ,[F14] [Conf (%) - 2007]
			  ,[F15] [Pay (£) - 2008]
			  ,[F16] [Conf (%) - 2008]
			  ,[F17] [Pay (£) - 2009]
			  ,[F18] [Conf (%) - 2009]
			  ,[F19] [Pay (£) - 2010]
			  ,[F20] [Conf (%) - 2010]
			  ,[F21] [Pay (£) - 2011]
			  ,[F22] [Conf (%) - 2011]
			  ,[F23] [Pay (£) - 2012]
			  ,[F24] [Conf (%) - 2012]
			  ,[F25] [Pay (£) - 2013]
			  ,[F26] [Conf (%) - 2013]
			  ,[F27] [Pay (£) - 2014]
			  ,[F28] [Conf (%) - 2014]
			  ,[F29] [Pay (£) - 2015]
			  ,[F30] [Conf (%) - 2015]
			  ,[F31] [Pay (£) - 2016]
			  ,[F32] [Conf (%) - 2016]
			  ,[F33] [Pay (£) - 2017]
			  ,[F34] [Conf (%) - 2017]
		   FROM 
			   [RAW].[Earnings_PT]
		   WHERE Code IS NOT NULL
			    AND AREA IS NOT NULL
	    ) c UNPIVOT([Value] FOR [Column] IN(
		    [Pay (£) - 2002]
		   ,[Conf (%) - 2002]
		   ,[Pay (£) - 2003]
		   ,[Conf (%) - 2003]
		   ,[Pay (£) - 2004]
		   ,[Conf (%) - 2004]
		   ,[Pay (£) - 2005]
		   ,[Conf (%) - 2005]
		   ,[Pay (£) - 2006]
		   ,[Conf (%) - 2006]
		   ,[Pay (£) - 2007]
		   ,[Conf (%) - 2007]
		   ,[Pay (£) - 2008]
		   ,[Conf (%) - 2008]
		   ,[Pay (£) - 2009]
		   ,[Conf (%) - 2009]
		   ,[Pay (£) - 2010]
		   ,[Conf (%) - 2010]
		   ,[Pay (£) - 2011]
		   ,[Conf (%) - 2011]
		   ,[Pay (£) - 2012]
		   ,[Conf (%) - 2012]
		   ,[Pay (£) - 2013]
		   ,[Conf (%) - 2013]
		   ,[Pay (£) - 2014]
		   ,[Conf (%) - 2014]
		   ,[Pay (£) - 2015]
		   ,[Conf (%) - 2015]
		   ,[Pay (£) - 2016]
		   ,[Conf (%) - 2016]
		   ,[Pay (£) - 2017]
		   ,[Conf (%) - 2017])) unpiv)
	SELECT 
		Code
	    ,Area
	    ,MAX(CASE
			   WHEN CHARINDEX('Pay (£)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Pay_Weekly (£)]
	    ,MAX(CASE
			   WHEN CHARINDEX('Conf (%)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Conf_Weekly (%)]
	    ,[Year]
	INTO 
		CLEAN.Earnings_PT
	FROM 
		CTE
	WHERE [Code] IS NOT NULL
		 AND LEN(code) > 2
	GROUP BY 
		Code
	    ,Area
	    ,Year;

IF OBJECT_ID('[CLEAN].[Earnings_FT_Hourly]','U') IS NOT NULL
DROP TABLE [CLEAN].[Earnings_FT_Hourly];

WITH CTE
	AS (SELECT 
		    *
		   ,SUBSTRING([Column],CHARINDEX('- ',[Column])+2,LEN([Column])) [Year]
	    FROM
	    (
		   SELECT 
			   [Code]
			  ,[Area]
			  ,[F3]  [Pay (£) - 2002]
			  ,[F4]  [Conf (%) - 2002]
			  ,[F5]  [Pay (£) - 2003]
			  ,[F6]  [Conf (%) - 2003]
			  ,[F7]  [Pay (£) - 2004]
			  ,[F8]  [Conf (%) - 2004]
			  ,[F9]  [Pay (£) - 2005]
			  ,[F10] [Conf (%) - 2005]
			  ,[F11] [Pay (£) - 2006]
			  ,[F12] [Conf (%) - 2006]
			  ,[F13] [Pay (£) - 2007]
			  ,[F14] [Conf (%) - 2007]
			  ,[F15] [Pay (£) - 2008]
			  ,[F16] [Conf (%) - 2008]
			  ,[F17] [Pay (£) - 2009]
			  ,[F18] [Conf (%) - 2009]
			  ,[F19] [Pay (£) - 2010]
			  ,[F20] [Conf (%) - 2010]
			  ,[F21] [Pay (£) - 2011]
			  ,[F22] [Conf (%) - 2011]
			  ,[F23] [Pay (£) - 2012]
			  ,[F24] [Conf (%) - 2012]
			  ,[F25] [Pay (£) - 2013]
			  ,[F26] [Conf (%) - 2013]
			  ,[F27] [Pay (£) - 2014]
			  ,[F28] [Conf (%) - 2014]
			  ,[F29] [Pay (£) - 2015]
			  ,[F30] [Conf (%) - 2015]
			  ,[F31] [Pay (£) - 2016]
			  ,[F32] [Conf (%) - 2016]
			  ,[F33] [Pay (£) - 2017]
			  ,[F34] [Conf (%) - 2017]
		   FROM 
			   [RAW].[Earnings_FT_Hourly]
		   WHERE Code IS NOT NULL
			    AND AREA IS NOT NULL
	    ) c UNPIVOT([Value] FOR [Column] IN(
		    [Pay (£) - 2002]
		   ,[Conf (%) - 2002]
		   ,[Pay (£) - 2003]
		   ,[Conf (%) - 2003]
		   ,[Pay (£) - 2004]
		   ,[Conf (%) - 2004]
		   ,[Pay (£) - 2005]
		   ,[Conf (%) - 2005]
		   ,[Pay (£) - 2006]
		   ,[Conf (%) - 2006]
		   ,[Pay (£) - 2007]
		   ,[Conf (%) - 2007]
		   ,[Pay (£) - 2008]
		   ,[Conf (%) - 2008]
		   ,[Pay (£) - 2009]
		   ,[Conf (%) - 2009]
		   ,[Pay (£) - 2010]
		   ,[Conf (%) - 2010]
		   ,[Pay (£) - 2011]
		   ,[Conf (%) - 2011]
		   ,[Pay (£) - 2012]
		   ,[Conf (%) - 2012]
		   ,[Pay (£) - 2013]
		   ,[Conf (%) - 2013]
		   ,[Pay (£) - 2014]
		   ,[Conf (%) - 2014]
		   ,[Pay (£) - 2015]
		   ,[Conf (%) - 2015]
		   ,[Pay (£) - 2016]
		   ,[Conf (%) - 2016]
		   ,[Pay (£) - 2017]
		   ,[Conf (%) - 2017])) unpiv)
	SELECT 
		Code
	    ,Area
	    ,MAX(CASE
			   WHEN CHARINDEX('Pay (£)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Pay_Weekly (£)]
	    ,MAX(CASE
			   WHEN CHARINDEX('Conf (%)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Conf_Weekly (%)]
	    ,[Year]
	INTO 
		CLEAN.Earnings_FT_Hourly
	FROM 
		CTE
	WHERE [Code] IS NOT NULL
		 AND LEN(code) > 2
	GROUP BY 
		Code
	    ,Area
	    ,Year;
IF OBJECT_ID('[CLEAN].[Earnings_PT_Hourly]','U') IS NOT NULL
DROP TABLE [CLEAN].[Earnings_PT_Hourly];

WITH CTE
	AS (SELECT 
		    *
		   ,SUBSTRING([Column],CHARINDEX('- ',[Column])+2,LEN([Column])) [Year]
	    FROM
	    (
		   SELECT 
			   [Code]
			  ,[Area]
			  ,[F3]  [Pay (£) - 2002]
			  ,[F4]  [Conf (%) - 2002]
			  ,[F5]  [Pay (£) - 2003]
			  ,[F6]  [Conf (%) - 2003]
			  ,[F7]  [Pay (£) - 2004]
			  ,[F8]  [Conf (%) - 2004]
			  ,[F9]  [Pay (£) - 2005]
			  ,[F10] [Conf (%) - 2005]
			  ,[F11] [Pay (£) - 2006]
			  ,[F12] [Conf (%) - 2006]
			  ,[F13] [Pay (£) - 2007]
			  ,[F14] [Conf (%) - 2007]
			  ,[F15] [Pay (£) - 2008]
			  ,[F16] [Conf (%) - 2008]
			  ,[F17] [Pay (£) - 2009]
			  ,[F18] [Conf (%) - 2009]
			  ,[F19] [Pay (£) - 2010]
			  ,[F20] [Conf (%) - 2010]
			  ,[F21] [Pay (£) - 2011]
			  ,[F22] [Conf (%) - 2011]
			  ,[F23] [Pay (£) - 2012]
			  ,[F24] [Conf (%) - 2012]
			  ,[F25] [Pay (£) - 2013]
			  ,[F26] [Conf (%) - 2013]
			  ,[F27] [Pay (£) - 2014]
			  ,[F28] [Conf (%) - 2014]
			  ,[F29] [Pay (£) - 2015]
			  ,[F30] [Conf (%) - 2015]
			  ,[F31] [Pay (£) - 2016]
			  ,[F32] [Conf (%) - 2016]
			  ,[F33] [Pay (£) - 2017]
			  ,[F34] [Conf (%) - 2017]
		   FROM 
			   [RAW].[Earnings_PT_Hourly]
		   WHERE Code IS NOT NULL
			    AND AREA IS NOT NULL
	    ) c UNPIVOT([Value] FOR [Column] IN(
		    [Pay (£) - 2002]
		   ,[Conf (%) - 2002]
		   ,[Pay (£) - 2003]
		   ,[Conf (%) - 2003]
		   ,[Pay (£) - 2004]
		   ,[Conf (%) - 2004]
		   ,[Pay (£) - 2005]
		   ,[Conf (%) - 2005]
		   ,[Pay (£) - 2006]
		   ,[Conf (%) - 2006]
		   ,[Pay (£) - 2007]
		   ,[Conf (%) - 2007]
		   ,[Pay (£) - 2008]
		   ,[Conf (%) - 2008]
		   ,[Pay (£) - 2009]
		   ,[Conf (%) - 2009]
		   ,[Pay (£) - 2010]
		   ,[Conf (%) - 2010]
		   ,[Pay (£) - 2011]
		   ,[Conf (%) - 2011]
		   ,[Pay (£) - 2012]
		   ,[Conf (%) - 2012]
		   ,[Pay (£) - 2013]
		   ,[Conf (%) - 2013]
		   ,[Pay (£) - 2014]
		   ,[Conf (%) - 2014]
		   ,[Pay (£) - 2015]
		   ,[Conf (%) - 2015]
		   ,[Pay (£) - 2016]
		   ,[Conf (%) - 2016]
		   ,[Pay (£) - 2017]
		   ,[Conf (%) - 2017])) unpiv)
	SELECT 
		Code
	    ,Area
	    ,MAX(CASE
			   WHEN CHARINDEX('Pay (£)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Pay_Weekly (£)]
	    ,MAX(CASE
			   WHEN CHARINDEX('Conf (%)',[Column]) != 0 THEN [Value]
			   ELSE NULL
		    END) [Conf_Weekly (%)]
	    ,[Year]
	INTO 
		CLEAN.Earnings_PT_Hourly
	FROM 
		CTE
	WHERE [Code] IS NOT NULL
		 AND LEN(code) > 2
	GROUP BY 
		Code
	    ,Area
	    ,Year;

/****Creating Earnings Total*****/

IF OBJECT_ID('[CLEAN].[Earnings_Total]','U') IS NOT NULL
DROP TABLE [CLEAN].[Earnings_Total];

SELECT 
	EFT.[Code]
    ,EFT.[Area]
    ,EFT.[Pay_Weekly (£)]     [FT_Pay_Weekly (£)]
    ,EFT.[Conf_Weekly (%)]    [FT_Conf_Weekly (%)]
    ,EPT.[Pay_Weekly (£)]     [PT_Pay_Weekly (£)]
    ,EPT.[Conf_Weekly (%)]    [PT_Conf_Weekly (%)]
    ,EFTH.[Pay_Weekly (£)]     [FT_Pay_Weekly_Hourly (£)]
    ,EFTH.[Conf_Weekly (%)]    [FT_Conf_Weekly_Hourly (%)]
    ,EPTH.[Pay_Weekly (£)]     [PT_Pay_Weekly_Hourly (£)]
    ,EPTH.[Conf_Weekly (%)]    [PT_Conf_Weekly_Hourly (%)]
    ,CAST(EFT.[Year] AS DATE) [Date]
INTO 
	CLEAN.Earnings_Total
FROM 
	[CLEAN].[Earnings_FT] EFT
	FULL JOIN
	[CLEAN].[Earnings_PT] EPT
	ON EFT.[Code] = EPT.[Code]
	   AND EFT.[Area] = EPT.[Area]
	   AND EFT.[Year] = EPT.[Year]
	FULL JOIN
	CLEAN.Earnings_FT_Hourly EFTH
	ON EFT.Code = EFTH.Code
	   AND EFT.Area = EFTH.Area
	   AND EFT.Year = EFTH.Year
	FULL JOIN
	CLEAN.Earnings_PT_Hourly EPTH
	ON EFT.Code = EPTH.Code
	   AND EFT.Area = EPTH.Area
	   AND EFT.Year = EPTH.Year
WHERE EFT.[Code] IS NOT NULL;

/******Cleaning Housing Tenure******/

IF OBJECT_ID('[CLEAN].[Housing_Tenure]','U') IS NOT NULL
DROP TABLE [CLEAN].[Housing_Tenure];

SELECT 
	[LSOA]
    ,[LSOA Name] [LSOA_Name]
    ,[Numbers:  Own Outright]                                           [Amt_Own_Outright]
    ,[Numbers:  Buying with mortgage]                                   [Amt_Mortgage]
    ,[Numbers:  Rented from Local Authority or Housing Association]     [Amt_Rent_LA/HA]
    ,[Numbers:  Rented from Private landlord]                           [Amt_Rent_Private]
	-- ,[Numbers:  Total]
	-- ,[F8]
    ,[Confidence Interval (95%) +/-:  Own Outright]                     [Conf_95_Own_Outright]
    ,[Confidence Interval (95%) +/-:  Buying with mortgage]             [Conf_95_Mortgage]
    ,[Confidence Interval (95%) +/-:  Rented from Local Authority or H] [Conf_95_Rent_LA/HA]
    ,[Confidence Interval (95%) +/-:  Rented from Private landlord]     [Conf_95_Rent_Private]
	--,[Confidence Interval (95%) +/-:  Total]
	-- ,[F14]
	--,[Percentages:  Own Outright]
	--,[Percentages:  Buying with mortgage]
	--,[Percentages:  Rented from Local Authority or Housing Association]
	--,[Percentages:  Rented from Private landlord]
	-- ,[Percentages:  Total]
	--  ,[F20]
	--,[Confidence Interval (95%) +/-:  Own Outright1]
	--,[Confidence Interval (95%) +/-:  Buying with mortgage1]
	--,[Confidence Interval (95%) +/-:  Rented from Local Authority or 1]
	--,[Confidence Interval (95%) +/-:  Rented from Private landlord1]
	--,[Confidence Interval (95%) +/-:  Total1]
    ,CAST(CAST([Year] as nvarchar) as date) [Date]
INTO 
	[CLEAN].[Housing_Tenure]
FROM 
	[RAW].[Housing_Tenure]
WHERE CHARINDEX('E09',LSOA) != 0;


/*****Cleaning Income_Support*****/

IF OBJECT_ID('[CLEAN].[Income_Support]','U') IS NOT NULL
DROP TABLE [CLEAN].[Income_Support];

WITH CTE
	AS (SELECT 
		    *
	    FROM
	    (
		   SELECT 
			   [Code]
			  ,[Area]
			  ,[1999-08-01]
			  ,[1999-11-01]
			  ,[2000-02-01]
			  ,[2000-05-01]
			  ,[2000-08-01]
			  ,[2000-11-01]
			  ,[2001-02-01]
			  ,[2001-05-01]
			  ,[2001-08-01]
			  ,[2001-11-01]
			  ,[2002-02-01]
			  ,[2002-05-01]
			  ,[2002-08-01]
			  ,[2002-11-01]
			  ,[2003-02-01]
			  ,[2003-05-01]
			  ,[2003-08-01]
			  ,[2003-11-01]
			  ,[2004-02-01]
			  ,[2004-05-01]
			  ,[2004-08-01]
			  ,[2004-11-01]
			  ,[2005-02-01]
			  ,[2005-05-01]
			  ,[2005-08-01]
			  ,[2005-11-01]
			  ,[2006-02-01]
			  ,[2006-05-01]
			  ,[2006-08-01]
			  ,[2006-11-01]
			  ,[2007-02-01]
			  ,[2007-05-01]
			  ,[2007-08-01]
			  ,[2007-11-01]
			  ,[2008-02-01]
			  ,[2008-05-01]
			  ,[2008-08-01]
			  ,[2008-11-01]
			  ,[2009-02-01]
			  ,[2009-05-01]
			  ,[2009-08-01]
			  ,[2009-11-01]
			  ,[2010-02-01]
			  ,[2010-05-01]
			  ,[2010-08-01]
			  ,[2010-11-01]
			  ,[2011-02-01]
			  ,[2011-05-01]
			  ,[2011-08-01]
			  ,[2011-11-01]
			  ,[2012-02-01]
			  ,[2012-05-01]
			  ,[2012-08-01]
			  ,[2012-11-01]
			  ,[2013-02-01]
			  ,[2013-05-01]
			  ,[2013-08-01]
			  ,[2013-11-01]
			  ,[2014-02-01]
			  ,[2014-05-01]
			  ,[2014-08-01]
			  ,[2014-11-01]
			  ,[2015-02-01]
			  ,[2015-05-01]
			  ,[2015-08-01]
			  ,[2015-11-01]
			  ,[2016-02-01]
			  ,[2016-05-01]
			  ,[2016-08-01]
			  ,[2016-11-01]
			  ,[2017-02-01]
			  ,[2017-05-01]
			  ,[2017-08-01]
			  ,[2017-11-01]
			  ,[2018-02-01]
		   FROM 
			   [RAW].[Income_Support]
	    ) c UNPIVOT([Income_Support (Count)] FOR [Date] IN(
		    [1999-08-01]
		   ,[1999-11-01]
		   ,[2000-02-01]
		   ,[2000-05-01]
		   ,[2000-08-01]
		   ,[2000-11-01]
		   ,[2001-02-01]
		   ,[2001-05-01]
		   ,[2001-08-01]
		   ,[2001-11-01]
		   ,[2002-02-01]
		   ,[2002-05-01]
		   ,[2002-08-01]
		   ,[2002-11-01]
		   ,[2003-02-01]
		   ,[2003-05-01]
		   ,[2003-08-01]
		   ,[2003-11-01]
		   ,[2004-02-01]
		   ,[2004-05-01]
		   ,[2004-08-01]
		   ,[2004-11-01]
		   ,[2005-02-01]
		   ,[2005-05-01]
		   ,[2005-08-01]
		   ,[2005-11-01]
		   ,[2006-02-01]
		   ,[2006-05-01]
		   ,[2006-08-01]
		   ,[2006-11-01]
		   ,[2007-02-01]
		   ,[2007-05-01]
		   ,[2007-08-01]
		   ,[2007-11-01]
		   ,[2008-02-01]
		   ,[2008-05-01]
		   ,[2008-08-01]
		   ,[2008-11-01]
		   ,[2009-02-01]
		   ,[2009-05-01]
		   ,[2009-08-01]
		   ,[2009-11-01]
		   ,[2010-02-01]
		   ,[2010-05-01]
		   ,[2010-08-01]
		   ,[2010-11-01]
		   ,[2011-02-01]
		   ,[2011-05-01]
		   ,[2011-08-01]
		   ,[2011-11-01]
		   ,[2012-02-01]
		   ,[2012-05-01]
		   ,[2012-08-01]
		   ,[2012-11-01]
		   ,[2013-02-01]
		   ,[2013-05-01]
		   ,[2013-08-01]
		   ,[2013-11-01]
		   ,[2014-02-01]
		   ,[2014-05-01]
		   ,[2014-08-01]
		   ,[2014-11-01]
		   ,[2015-02-01]
		   ,[2015-05-01]
		   ,[2015-08-01]
		   ,[2015-11-01]
		   ,[2016-02-01]
		   ,[2016-05-01]
		   ,[2016-08-01]
		   ,[2016-11-01]
		   ,[2017-02-01]
		   ,[2017-05-01]
		   ,[2017-08-01]
		   ,[2017-11-01]
		   ,[2018-02-01])) unpiv)
	SELECT 
		Code
	    ,Area
	    ,[Income_Support (Count)]
	    ,CAST(Date AS DATE) [Date]
    INTO
	   CLEAN.Income_Support
	FROM 
		CTE
	WHERE CHARINDEX('E09',Code) != 0
		 AND DATEPART(mm,[Date]) = 2;

/*****Cleaning Personal_Insolvency*****/

IF OBJECT_ID('[CLEAN].[Personal_Insovlency]','U') IS NOT NULL
DROP TABLE [CLEAN].[Personal_Insovlency];

SELECT 
	[Code]
    ,[Area]
    ,[New Personal Insolvencies (counts)]
	--,[New Personal Insolvencies (rates) Rate per 10000]
    ,[New Bankruptcy Orders (counts)]
	--,[New Bankruptcy Orders (rates) Rate per 10000]
    ,[New Individual Voluntary Arrangements (IVAs) (counts)]
	-- ,[New Individual Voluntary Arrangements (IVAs) (rates) Rate per 10]
    ,[New Debt Relief Orders (DROs) (counts)]
	--,[New Debt Relief Orders (DROs) (rates) Rate per 10000]
    ,CAST(CAST([Year] AS NVARCHAR) AS DATE) [Date]
INTO
    [CLEAN].[Personal_Insovlency]
FROM 
	[RAW].[Personal_Insolvency]
WHERE Code IS NOT NULL
	 AND AREA IS NOT NULL
	 AND LEN(Code) > 2

/*****Cleaning Workerless_Households*****/

IF OBJECT_ID('[CLEAN].[Workerless_Households]','U') IS NOT NULL
DROP TABLE [CLEAN].[Workerless_Households];

SELECT 
	[LSOA_Code]                            [LA_Code]
    ,[LSOA_Name]                            [LA_Name]
    ,[Working Households : Thousands]       [Working_Households]
	-- ,[Working Households : Per cent]
    ,[Mixed Households : Thousands]         [Mixed_Households]
	--,[Mixed Households : Per cent]
    ,[Workless Households : Thousands]      [Workerless_Households]
	-- ,[Workless Households : Per cent]
    ,CAST(CAST([Year] AS NVARCHAR) AS DATE) [Date]
INTO 
	[CLEAN].[Workerless_Households]
FROM 
	[RAW].[Workerless_Households]
WHERE [LSOA_Code] IS NOT NULL
	 AND [LSOA_Name] IS NOT NULL
	 AND LEN([LSOA_Code]) > 2
	 AND ([Working Households : Thousands] IS NOT NULL
	 OR [Mixed Households : Thousands]  IS NOT NULL
	 OR [Workless Households : Thousands] IS NOT NULL)

/*****Cleaning Police_Crime_Data*****/

IF OBJECT_ID('[CLEAN].[Police_Crime_Data]','U') IS NOT NULL
DROP TABLE [CLEAN].[Police_Crime_Data];

SELECT 
	NULLIF([Crime ID],'')                       [Crime_ID]
    ,CAST([Month]+'-01' AS DATE)                 [Date]
    ,[Reported by]
    ,[Falls within]
    ,CAST([Longitude] as float) [Longitude]
    ,CAST([Latitude] as float) [Latitude]
	-- ,[Location]
    ,Geography::Point([Latitude],Longitude,4237) [Spatial_Location]
    ,[LSOA code]
    ,[LSOA name]
    ,[Crime type]
    ,NULLIF([Last outcome category],'')          [Last_Outcome_Category]
--  ,[Context]
INTO 
	[CLEAN].[Police_Crime_Data]
FROM 
	[RAW].[Police_Crime_Data];

--Swap rows with incorrect data
UPDATE
[CLEAN].[Police_Crime_Data]
SET [LSOA code] = [LSOA name]
WHERE [Crime type] LIKE '%Hillingdon%'

UPDATE
[CLEAN].[Police_Crime_Data]
SET [LSOA name] = [Crime type]
WHERE [Crime type] LIKE '%Hillingdon%'

UPDATE
[CLEAN].[Police_Crime_Data]
SET [Crime type] = Last_Outcome_Category
WHERE [Crime type] LIKE '%Hillingdon%'

/*****Cleaning Location_Data*****/

IF OBJECT_ID('[Clean].[Location_Data]','U') IS NOT NULL
DROP TABLE [Clean].[Location_Data];

SELECT 
	[LSOA11CD] [LSOA_Code]
    ,[LSOA11NM] [LSOA_Name]
    ,[MSOA11CD] [MSOA_Code]
    ,[MSOA11NM] [MSOA_Name]
    ,[LAD11CD] [LA_Code]
    ,CAST([Former Code] as nvarchar) [Old_LA_Code]
    ,[LAD11NM] [LA_Name]
    ,[RGN11CD] [Region_Code]
    ,[RGN11NM] [Region_Name]
    --,[USUALRES]
    --,[HHOLDRES]
    --,[COMESTRES]
    --,[POPDEN]
    --,[HHOLDS]
    --,[AVHHOLDSZ]
    ,[SpatialObj] [Spatial_LSOA_Code]
    --,[Code]
    --,[Former Code]
    --,[Local Authority]
INTO
    [Clean].[Location_Data]
FROM 
	[RAW].[Location_Data]
ORDER BY 
	LA_Code ASC;

/*****Cleaning Household_Composition*****/


IF OBJECT_ID('[CLEAN].[2011_Household_Composition]','U') IS NOT NULL
DROP TABLE [CLEAN].[2011_Household_Composition];

SELECT 
	[F1]                                LA_Code
    ,[F2]                                LA_Name
    ,[One person household: Aged 65 and over]								   [One_Person_Household: Aged 65 and over]
    ,[One person household: Other]											   [One_Person_Household: Other]
    ,[One family only: All aged 65 and over]									   [One_Family_Household: All aged 65 and over]
    ,[One family only: Married or same-sex civil partnership couple: N]			   [One_Family_Household: Married or same-sex civil partnership couple: N]
    ,[One family only: Married or same-sex civil partnership couple: D]			   [One_Family_Household: Married or same-sex civil partnership couple: D]
    ,[One family only: Married or same-sex civil partnership couple: A]			   [One_Family_Household: Married or same-sex civil partnership couple: A]
    ,[One family only: Cohabiting couple: No children]							   [One_Family_Household: Cohabiting couple: No children]
    ,[One family only: Cohabiting couple: Dependent children]					   [One_Family_Household: Cohabiting couple: Dependent children]
    ,[One family only: Cohabiting couple: All children non-dependent]				   [One_Family_Household: Cohabiting couple: All children non-dependent]
    ,[One family only: Lone parent: Dependent children]						   [One_Family_Household: Lone parent: Dependent children]
    ,[One family only: Lone parent: All children non-dependent]					   [One_Family_Household: Lone parent: All children non-dependent]
    ,[Other household types: With dependent children]							   [Other_Household: With dependent children]
    ,[Other household types: All full-time students]							   [Other_Household: All full-time students]
    ,[Other household types: All aged 65 and over]							   [Other_Household: All aged 65 and over]
    ,[Other household types: Other]										   [Other_Household: Other]
    ,CAST(CAST(CASE
			    WHEN [F1] IS NOT NULL THEN 2011
			    ELSE [F1]
			END AS NVARCHAR) AS DATE) [Date]
INTO 
	[CLEAN].[2011_Household_Composition]
FROM 
	[RAW].[2011_Household_Composition];


/*****Cleaning Inflation*****/

IF OBJECT_ID('[Clean].[Inflation]','U') IS NOT NULL
DROP TABLE [Clean].[Inflation];

SELECT 
	CAST([CPIH INDEX 00: ALL ITEMS 2015=100] as float) CPIH_Index
    ,CAST(CASE
		    WHEN TITLE LIKE '%JAN%' THEN REPLACE(Title,' JAN','-01-01')
		    WHEN TITLE LIKE '%Feb%' THEN REPLACE(Title,' FEB','-02-01')
		    WHEN TITLE LIKE '%MAR%' THEN REPLACE(Title,' MAR','-03-01')
		    WHEN TITLE LIKE '%APR%' THEN REPLACE(Title,' APR','-04-01')
		    WHEN TITLE LIKE '%MAY%' THEN REPLACE(Title,' MAY','-05-01')
		    WHEN TITLE LIKE '%JUN%' THEN REPLACE(Title,' JUN','-06-01')
		    WHEN TITLE LIKE '%JUL%' THEN REPLACE(Title,' JUL','-07-01')
		    WHEN TITLE LIKE '%AUG%' THEN REPLACE(Title,' AUG','-08-01')
		    WHEN TITLE LIKE '%SEP%' THEN REPLACE(Title,' SEP','-09-01')
		    WHEN TITLE LIKE '%OCT%' THEN REPLACE(Title,' OCT','-10-01')
		    WHEN TITLE LIKE '%NOV%' THEN REPLACE(Title,' NOV','-11-01')
		    WHEN TITLE LIKE '%DEC%' THEN REPLACE(Title,' DEC','-12-01')
		    ELSE [Title]
		END AS DATE)                   [Date]
INTO 
	[Clean].[Inflation]
FROM 
	[RAW].[Inflation]
WHERE CHARINDEX(' Q',Title) = 0
	 AND CHARINDEX('2',Title) != 0
	 AND LEN(title) > 4

/*****Cleaning Population*****/

SELECT 
	LA_Name
    ,Population
    ,CAST(Year AS DATE) [Date]
INTO 
	[CLEAN].[Population_Data]
FROM
(
    SELECT 
	    [local authority: county / unitary (as of April 2015)] [LA_Name]
	   ,[1991]
	   ,[1992]
	   ,[1993]
	   ,[1994]
	   ,[1995]
	   ,[1996]
	   ,[1997]
	   ,[1998]
	   ,[1999]
	   ,[2000]
	   ,[2001]
	   ,[2002]
	   ,[2003]
	   ,[2004]
	   ,[2005]
	   ,[2006]
	   ,[2007]
	   ,[2008]
	   ,[2009]
	   ,[2010]
	   ,[2011]
	   ,[2012]
	   ,[2013]
	   ,[2014]
	   ,[2015]
	   ,[2016]
	   ,[2017]
    FROM 
	    [RAW].[Population_Data]
) c UNPIVOT([Population] FOR [Year] IN(
	[1991]
    ,[1992]
    ,[1993]
    ,[1994]
    ,[1995]
    ,[1996]
    ,[1997]
    ,[1998]
    ,[1999]
    ,[2000]
    ,[2001]
    ,[2002]
    ,[2003]
    ,[2004]
    ,[2005]
    ,[2006]
    ,[2007]
    ,[2008]
    ,[2009]
    ,[2010]
    ,[2011]
    ,[2012]
    ,[2013]
    ,[2014]
    ,[2015]
    ,[2016]
    ,[2017])) unpiv;

