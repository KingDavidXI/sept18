


SELECT 
	*
FROM
(
    SELECT 
	    LEFT(month,4)   [Year]
	   ,[Crime type]
	   ,[Crime type] AS [Crime Type 2]
    FROM 
	    [RAW].[Police_Crime_Data]
) AS s PIVOT(COUNT([Crime type]) FOR [Year] IN(
	[2010]
    ,[2011]
    ,[2012]
    ,[2013]
    ,[2014]
    ,[2015]
    ,[2016]
    ,[2017]
    ,[2018])) AS pvt;