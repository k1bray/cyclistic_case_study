-- Activate the database to be used
USE [CaseStudy1-Cyclistic];

/*
The question that needs to be answered by this project is:
How do annual members and casual riders use Cyclistic bikes differently?
*/

/*
The first thing that I want to do after uploading the .csv files into my Cyclistic database is to create a new table that will be 
populated by the union of all the monthly tables.
*/

SELECT * INTO divvy_tripdata
FROM (
	SELECT *
	FROM dbo.[202102-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202103-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202104-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202105-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202106-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202107-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202108-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202109-divvy-tripdata]
	
	UNION

	SELECT *
	FROM dbo.[202110-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202111-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202112-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202201-divvy-tripdata]

	UNION

	SELECT *
	FROM dbo.[202202-divvy-tripdata]
) AS tripdata;


/*
Table Demo
*/

SELECT TOP 100 *
FROM divvy_tripdata;

SELECT
	COUNT(*)
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds < (60 * 2);

/*
COUNT() check on the new table and the original total came to 5717608 rows
*/

SELECT 
	COUNT(*) AS total_num_rows
FROM 
	dbo.divvy_tripdata;

/*
Checking to see if there are any duplicates by the ride_id primary key.

Spoiler alert: There are none.
*/

SELECT
	COUNT(DISTINCT(ride_id)) AS count_distinct_ride_id
	,COUNT(ride_id) AS count_all_ride_id
FROM divvy_tripdata;

/*
Checking columns for NULL values, which I discovered in this database are actually empty strings
*/

SELECT
	COUNT(*) AS rid_id_nulls	--0
FROM
	divvy_tripdata
WHERE
	ride_id = ' ';

SELECT
	COUNT(*) AS rideable_type_nulls	--0
FROM
	divvy_tripdata
WHERE
	rideable_type = ' ';

SELECT
	COUNT(*) AS started_at_nulls	--0
FROM
	divvy_tripdata
WHERE
	started_at = ' ';

SELECT
	COUNT(*) AS ended_at_nulls	--0
FROM
	divvy_tripdata
WHERE
	ended_at = ' ';

SELECT
	COUNT(*) AS start_station_name_nulls	--717004
FROM
	divvy_tripdata
WHERE
	start_station_name = ' ';

SELECT
	COUNT(*) AS start_station_id_nulls	--717001
FROM
	divvy_tripdata
WHERE
	start_station_id = ' ';

SELECT
	COUNT(*) AS end_station_name_nulls		--767156
FROM
	divvy_tripdata
WHERE
	end_station_name = ' ';

SELECT
	COUNT(*) AS end_station_id		--767156
FROM
	divvy_tripdata
WHERE
	end_station_id = ' ';

SELECT
	COUNT(*) AS start_lat_nulls		--0
FROM
	divvy_tripdata
WHERE
	start_lat = ' ';

SELECT
	COUNT(*) AS start_lng_nulls		--0
FROM
	divvy_tripdata
WHERE
	start_lng = ' ';

SELECT
	COUNT(*) AS end_lat_nulls		--4831
FROM
	divvy_tripdata
WHERE
	end_lat = ' ';

SELECT
	COUNT(*) AS end_lng_nulls		--4831
FROM
	divvy_tripdata
WHERE
	end_lng = ' ';

SELECT
	COUNT(*) AS member_casual_nulls		--0
FROM
	divvy_tripdata
WHERE
	member_casual = ' ';

/*
Count of the number of each distinct rideable types of bikes.
*/

/*
Something to note is that there are no records of members riding docked bikes

Unfortunately, for this project there is no one that I can contact to find out what a 'docked_bike' is 
or why the members have no record of using them.  Therefore, the records that contain 'docked_bike' need
to be eliminated so as not to skew the other results.
*/

SELECT 
	rideable_type AS 'Rideable Type'
	,member_casual AS 'Rider Type'
	,COUNT(*) AS 'Numer of Rideable Type'
FROM 
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
GROUP BY 
	rideable_type
	,member_casual
ORDER BY
	rideable_type
	,member_casual;


/*
Count of the number of each distinct member types

The results of this query show a total of 3113200 for member and 2205567 for casual
*/

SELECT 
	member_casual AS 'Rider Type'
	,COUNT(*) AS 'Number of Each Type'
FROM 
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike'
GROUP BY 
	member_casual;

/*
I wanted to know what the most popular starting station was.  What I found was that the top spot belonged to a NULL.
*/

SELECT 
	start_station_name
	,COUNT(*) AS popular_start_station_name
FROM 
	divvy_tripdata
WHERE
	start_station_name != ' '  -- eliminate the NULLs in search condition
	AND rideable_type != 'docked_bike'
GROUP BY 
	start_station_name	
ORDER BY 
	popular_start_station_name DESC;

/*
This is the same query as above only using the end station name
*/

SELECT 
	end_station_name
	,COUNT(*) AS popular_end_station_name
FROM 
	divvy_tripdata
WHERE
	end_station_name != ' '  -- eliminate the NULLs in search condition
	AND rideable_type != 'docked_bike'
GROUP BY 
	end_station_name	
ORDER BY 
	popular_end_station_name DESC;


/*
Need to find the difference between ended_at and started_at as ride_duration

https://www.sqlservercentral.com/articles/calculating-duration-using-datetime-start-and-end-dates-sql-spackle-2

The ultimate goal is to find the AVG(ride_duration) overall, as well as AVG(ride_duration) for both members and casual riders.
*/


/*
The query below finds 145 records where the started_at time is greater than the ended_at time.  These records are mistakes that will have to be 
eliminated.
*/

SELECT 
	*
FROM 
	divvy_tripdata
WHERE 
	started_at > ended_at;

/*
Deleting the rows where started_at > ended_at
*/

DELETE
FROM 
	divvy_tripdata
WHERE
	started_at > ended_at;



SELECT TOP 20 *
	,(ended_at - started_at) AS ride_duration
FROM 
	divvy_tripdata;

/*
Finding the ride duration in seconds
*/

SELECT TOP 10
	ride_id
	,rideable_type
	,started_at
	,ended_at
	,start_station_name
	,end_station_name
	,member_casual
	,DATEDIFF(SECOND, started_at, ended_at) AS ride_duration_seconds
FROM
	divvy_tripdata
ORDER BY ride_duration_seconds DESC;

/*
Adding a column with the DATEDIFF() results.
*/

ALTER TABLE divvy_tripdata
ADD ride_duration_seconds bigint;

UPDATE divvy_tripdata
SET ride_duration_seconds = DATEDIFF(SECOND, started_at, ended_at)


/*
Fiding rides that have a duration longer than 1 day?
*/

SELECT TOP 100
	ride_duration_seconds/60 AS ride_duration_minutes
FROM
	divvy_tripdata
ORDER BY 
	ride_duration_seconds/60 DESC;


SELECT TOP 100
	(((ride_duration_seconds/60)/60)/24) AS ride_duration_days
FROM
	divvy_tripdata
ORDER BY 
	ride_duration_seconds/60 DESC;

/*
COUNT() of rides that last longer than 1 day

The initial result is 4155 for all rideable bike types.  When records with docked_bike are excluded, the count drops to 2763.
*/

SELECT 
	COUNT(ride_duration_seconds) AS num_of_ride_duration_days_over_1
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds > (24*60*60)
 	AND rideable_type != 'docked_bike';

SELECT
	24*60*60 AS seconds_in_a_day

/*
AVG ride duration in minutes for all rides
*/

SELECT
	AVG(ride_duration_seconds/60) AS 'Total AVG Minutes'  -- 18 minutes
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike';

/*
AVG ride duration in minutes for members
*/

SELECT
	AVG(ride_duration_seconds/60) AS avg_ride_duration_minutes_member
FROM
	divvy_tripdata
WHERE
	member_casual = 'member'
	AND ride_duration_seconds >= 60;

/*
AVG ride duration in minutes for nonmembers/casual riders
*/

SELECT
	AVG(ride_duration_seconds/60) AS avg_ride_duration_minutes_casual
FROM
	divvy_tripdata
WHERE
	member_casual = 'casual'
	AND ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike';


/*
Using a CASE(PIVOT) to find the average for the members, casual riders, and all rides.
The data shows a sharp dropoff in rides that last longer than 4 hours so I included that timeframe in the WHERE clause
to limit the results to a potentially more applicable "average"
*/

SELECT 
	AVG(CASE WHEN member_casual = 'member' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Member AVG Ride Duration'
	,AVG(CASE WHEN member_casual = 'casual' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Casual AVG Ride Duration'
	,AVG(CASE WHEN member_casual = 'casual' OR member_casual = 'member' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Total AVG Ride Duration'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
 	AND ride_duration_seconds <= 14400  -- seconds in a 4 hour period
-- 	AND ride_duration_seconds <= 86400  -- seconds in a 24 hour period
 	AND rideable_type != 'docked_bike';


/*
Using a CASE(PIVOT) to find the AVG ride_duration based on rider type and bicycle type.
*/

SELECT 
	AVG(CASE WHEN member_casual = 'member' AND rideable_type = 'classic_bike' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Member AVG Ride Duration Classic'
	,AVG(CASE WHEN member_casual = 'member' AND rideable_type = 'electric_bike' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Member AVG Ride Duration Electric'
	,AVG(CASE WHEN member_casual = 'casual' AND rideable_type = 'classic_bike' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Casual AVG Ride Duration Classic'
	,AVG(CASE WHEN member_casual = 'casual' AND rideable_type = 'electric_bike' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Casual AVG Ride Duration Electric'
	,AVG(CASE WHEN member_casual = 'casual' OR member_casual = 'member' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Total AVG Ride Duration'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
 	AND ride_duration_seconds <= 14400  -- seconds in a 4 hour period
-- 	AND ride_duration_seconds <= 86400  -- seconds in a 24 hour period
	AND rideable_type != 'docked_bike';

/*
Using a CASE(PIVOT) to find the AVG ride_duration based on bicycle type.
*/

SELECT 
	AVG(CASE WHEN rideable_type = 'classic_bike' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'AVG Ride Duration Classic'
	,AVG(CASE WHEN rideable_type = 'electric_bike' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'AVG Ride Duration Electric'
	,AVG(CASE WHEN rideable_Type = 'classic_bike' OR rideable_Type = 'electric_bike' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Total AVG Ride Duration'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
 	AND ride_duration_seconds <= 14400  -- seconds in a 4 hour period
-- 	AND ride_duration_seconds <= 86400  -- seconds in a 24 hour period
	AND rideable_type != 'docked_bike';

/*
Longest ride duration
*/

SELECT
	MAX(ride_duration_seconds/60) AS 'Longest Ride Minutes'
	,MAX((ride_duration_seconds/60)/60) AS 'Longest Ride Hours'
	,MAX(((ride_duration_seconds/60)/60)/24) AS 'Longest Ride Days'
FROM
	divvy_tripdata
WHERE
	rideable_type != 'docked_bike';

SELECT
	 Top 1 *
FROM
	divvy_tripdata
WHERE
	rideable_type != 'docked_bike'
ORDER BY ride_duration_seconds DESC;

/*
Shortest ride duration in minutes

This query showed that there is a high population of records with low or no time duration
*/

SELECT
	MIN(ride_duration_seconds/60) AS shortest_ride_duration_minutes
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds/60 >= 1
	AND rideable_type != 'docked_bike';

SELECT
	 Top 1 *
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 1
	AND rideable_type != 'docked_bike'
ORDER BY ride_duration_seconds;


/*
Need to find out which rows have almost no time duration and probably delete or exclude them from future queries.
*/

SELECT 
	COUNT(*)
FROM 
	divvy_tripdata
WHERE
	(ride_duration_seconds/60) = 1
	AND rideable_type != 'docked_bike';

/*
Extracting the day of the week that rides are started
*/

SELECT TOP 10 *
	,DATENAME(WEEKDAY, started_at) AS day_of_week
FROM divvy_tripdata;


/*
Number of rides per day of the week based on started_at
*/

SELECT
	DATENAME(WEEKDAY, started_at) AS day_of_week
	,COUNT(DATENAME(WEEKDAY, started_at)) AS rides_per_day_of_week
FROM 
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike'
GROUP BY
	DATENAME(WEEKDAY, started_at);

/*
Getting the number of the day of the week and ordering the results by number of the day of the week.
*/

SELECT 
	DATEPART(WEEKDAY, started_at) AS 'Day of Week'
	,COUNT(DATEPART(WEEKDAY, started_at)) AS 'Rides Per Day of Week'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike'
GROUP BY
	DATEPART(WEEKDAY, started_at)
ORDER BY
	DATEPART(WEEKDAY, started_at);

/*
How many rides per day are being logged by members vs casual riders (using started_at) with the results grouped by
COUNT of the number of rides per day and grouped by member_casual
*/

SELECT
	DATEPART(WEEKDAY, started_at) AS 'Day of Week'
	,member_casual AS 'Member Type'
	,COUNT(DATEPART(WEEKDAY, started_at)) AS 'Number of Rides'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike'
GROUP BY
	DATEPART(WEEKDAY, started_at)
	,member_casual
ORDER BY
	DATEPART(WEEKDAY, started_at);


/*
Trying a COUNT(CASE()) or CASE() Pivot
The results of this query shows an ordered list of days of the week and a count of rides per day based on their rider type
*/

SELECT
--	member_casual
	DATEPART(WEEKDAY, started_at) AS 'Day of Week'
	,COUNT(CASE WHEN member_casual = 'member' THEN member_casual ELSE NULL END) as 'Member'
	,COUNT(CASE WHEN member_casual = 'casual' THEN member_casual ELSE NULL END) as 'Casual'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike'
GROUP BY
	member_casual
	,DATEPART(WEEKDAY, started_at)
ORDER BY
	member_casual
	,'Day of Week';


/*
Find the MODE for day of the week by member type.

This sorts the results by the 'member' and 'casual' in DESC order.  The highest occurence in each column would be the MODE for each rider type. 
*/

SELECT
--	member_casual
	DATEPART(WEEKDAY, started_at) AS day_of_week
	,COUNT(CASE WHEN member_casual = 'member' THEN member_casual ELSE NULL END) as member
	,COUNT(CASE WHEN member_casual = 'casual' THEN member_casual ELSE NULL END) as casual
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike'
GROUP BY
	member_casual
	,DATEPART(WEEKDAY, started_at)
ORDER BY
	member DESC
	,casual DESC;

/*
The results of this query shows an ordered list of months and a count of rides per month based on their rider type
*/

SELECT
--	member_casual
	DATEPART(MONTH, started_at) AS 'Month'
	,COUNT(CASE WHEN member_casual = 'member' THEN member_casual ELSE NULL END) as 'Member'
	,COUNT(CASE WHEN member_casual = 'casual' THEN member_casual ELSE NULL END) as 'Casual'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND rideable_type != 'docked_bike'
GROUP BY
	member_casual
	,DATEPART(MONTH, started_at)
ORDER BY
	member_casual
	,'Month';



/*
What is a reasonable ride_duration?  Can we assume that there is a MINIMUM required length to a 
ride_duration in order for it to be applicable?

The query below shows that there are 512 rows where the ride_duration_seconds = 0
These rows will need to be eliminated.

Also, is there a MAXIMUM ride duration that should be condsidered?  The "typical" ride appears to be less than a day.
Should all rides over a 12 hour period be removed?  Perhaps over 24 hours?
*/

SELECT
	*
FROM
	divvy_tripdata
WHERE 
	--ride_duration_seconds = 0 AND
	started_at = ended_at
	AND rideable_type != 'docked_bike';


SELECT TOP 1000
	*
FROM
	divvy_tripdata
WHERE 
	--ride_duration_seconds = 0 AND
	start_station_name = end_station_name
	AND rideable_type != 'docked_bike'
ORDER BY
	ride_duration_seconds;

SELECT
	*
FROM
	divvy_tripdata
WHERE 
	ride_duration_seconds < 360;

/*
The query below shows that there are 2763 rides that are greater than 24 hours
*/

SELECT
	COUNT(*) AS day_long_rides
FROM
	divvy_tripdata
WHERE 
	ride_duration_seconds > 86400
	AND rideable_type != 'docked_bike';



SELECT
	COUNT(*) AS long_rides  -- 1919 records
FROM
	divvy_tripdata
WHERE 
	ride_duration_seconds BETWEEN 43200 AND 86400
	AND rideable_type != 'docked_bike';


/*
I think I need to set up a query for tiered counting by ride duration.

The results of the distribution show that the VAST majority of rides occur within the timeframe of 0-4 hours.
The dropoff between 2-4 and 4-6 is very steep.
*/


SELECT
	member_casual AS 'Rider Type'
	--COUNT(CASE WHEN ride_duration_seconds BETWEEN 0 AND 59 THEN ride_duration_seconds ELSE NULL END) AS 'Less than 1 minute',
	,COUNT(CASE WHEN ride_duration_seconds BETWEEN 60 AND 3599 THEN ride_duration_seconds ELSE NULL END) AS 'Less than 1 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 3600 AND 7199 THEN ride_duration_seconds ELSE NULL END) AS '1-2 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 7200 AND 14399 THEN ride_duration_seconds ELSE NULL END) AS '2-4 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 14400 AND 21599 THEN ride_duration_seconds ELSE NULL END) AS '4-6 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 21600 AND 28799 THEN ride_duration_seconds ELSE NULL END) AS '6-8 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 28800 AND 35999 THEN ride_duration_seconds ELSE NULL END) AS '8-10 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 36000 AND 43199 THEN ride_duration_seconds ELSE NULL END) AS '10-12 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 43200 AND 50399 THEN ride_duration_seconds ELSE NULL END) AS '12-14 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 50400 AND 57599 THEN ride_duration_seconds ELSE NULL END) AS '14-16 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 57600 AND 64799 THEN ride_duration_seconds ELSE NULL END) AS '16-18 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 64800 AND 71999 THEN ride_duration_seconds ELSE NULL END) AS '18-20 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 72000 AND 79199 THEN ride_duration_seconds ELSE NULL END) AS '20-22 hr'
	,COUNT(CASE WHEN ride_duration_seconds between 79200 AND 86399 THEN ride_duration_seconds ELSE NULL END) AS '22-24 hr'
	,COUNT(CASE WHEN ride_duration_seconds > 86400 THEN ride_duration_seconds ELSE NULL END) AS 'More than 24 hr'
FROM 
	divvy_tripdata
WHERE
	rideable_type != 'docked_bike'
GROUP BY
	member_casual;
/*
Same as the query above only with a more narrow focus on ride duration of less than 6 hours
*/

SELECT
	member_casual AS 'Rider Type'
	,COUNT(CASE WHEN ride_duration_seconds BETWEEN 60 AND 1799 THEN ride_duration_seconds ELSE NULL END) AS 'Less than 1/2hr'
	,COUNT(CASE WHEN ride_duration_seconds between 1800 AND 3599 THEN ride_duration_seconds ELSE NULL END) AS '1/2hr - 1hr'
	,COUNT(CASE WHEN ride_duration_seconds between 3600 AND 5399 THEN ride_duration_seconds ELSE NULL END) AS '1hr - 1-1/2hr'
	,COUNT(CASE WHEN ride_duration_seconds between 5400 AND 7199 THEN ride_duration_seconds ELSE NULL END) AS '1-1/2hr - 2hr'
	,COUNT(CASE WHEN ride_duration_seconds between 7200 AND 8999 THEN ride_duration_seconds ELSE NULL END) AS '2hr - 2-1/2hr'
	,COUNT(CASE WHEN ride_duration_seconds between 9000 AND 10799 THEN ride_duration_seconds ELSE NULL END) AS '2-1/2hr - 3hr'
	,COUNT(CASE WHEN ride_duration_seconds between 10800 AND 12599 THEN ride_duration_seconds ELSE NULL END) AS '3hr - 3-1/2hr'
	--,COUNT(CASE WHEN ride_duration_seconds between 12600 AND 14399 THEN ride_duration_seconds ELSE NULL END) AS '3-1/2hr - 4hr'
	--,COUNT(CASE WHEN ride_duration_seconds between 14400 AND 16199 THEN ride_duration_seconds ELSE NULL END) AS '4hr - 4-1/2hr'
	--,COUNT(CASE WHEN ride_duration_seconds between 16200 AND 17999 THEN ride_duration_seconds ELSE NULL END) AS '4-1/2hr - 5hr'
	--,COUNT(CASE WHEN ride_duration_seconds between 18000 AND 19799 THEN ride_duration_seconds ELSE NULL END) AS '5hr - 5-1/2hr'
	--,COUNT(CASE WHEN ride_duration_seconds between 19800 AND 21599 THEN ride_duration_seconds ELSE NULL END) AS '5-1/2hr - 6hr'
	--,COUNT(CASE WHEN ride_duration_seconds between 21600 AND 23399 THEN ride_duration_seconds ELSE NULL END) AS '6hr - 6-1/2hr'
FROM 
	divvy_tripdata
WHERE
	rideable_type != 'docked_bike'
GROUP BY
	member_casual;

/*
Similar query as above only sorting a grouping by minutes for rides that are less than 1 hour
*/


SELECT
	member_casual AS 'Rider Type'
--	,COUNT(CASE WHEN ride_duration_seconds BETWEEN 0 AND 59 THEN ride_duration_seconds ELSE NULL END) AS 'Less then 1 minute'
	,COUNT(CASE WHEN ride_duration_seconds between 60 AND 599 THEN ride_duration_seconds ELSE NULL END) AS 'Less then 10 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 600 AND 899 THEN ride_duration_seconds ELSE NULL END) AS '10-15 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 900 AND 1199 THEN ride_duration_seconds ELSE NULL END) AS '15-20 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 1200 AND 1499 THEN ride_duration_seconds ELSE NULL END) AS '20-25 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 1500 AND 1799 THEN ride_duration_seconds ELSE NULL END) AS '25-30 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 1800 AND 2099 THEN ride_duration_seconds ELSE NULL END) AS '30-35 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 2100 AND 2399 THEN ride_duration_seconds ELSE NULL END) AS '35-40 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 2400 AND 2699 THEN ride_duration_seconds ELSE NULL END) AS '40-45 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 2700 AND 2999 THEN ride_duration_seconds ELSE NULL END) AS '45-50 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 3000 AND 3299 THEN ride_duration_seconds ELSE NULL END) AS '50-55 minutes'
	,COUNT(CASE WHEN ride_duration_seconds between 3300 AND 3600 THEN ride_duration_seconds ELSE NULL END) AS '55-60 minutes'
FROM 
	divvy_tripdata
WHERE
 	rideable_type != 'docked_bike'
	OR ride_duration_seconds < 60
GROUP BY
	member_casual;



/*
AVG() ride duration by day of the week?

members vs casual riders?
*/

SELECT 
	DATEPART(WEEKDAY, started_at) AS 'Day of Week'
	,AVG(CASE WHEN member_casual = 'member' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Member AVG Ride Duration'
	,AVG(CASE WHEN member_casual = 'casual' THEN (ride_duration_seconds/60) ELSE NULL END) AS 'Casual AVG Ride Duration'
FROM
	divvy_tripdata
WHERE
	ride_duration_seconds >= 60
	AND ride_duration_seconds <= 14400
	AND rideable_type != 'docked_bike'
GROUP BY
	DATEPART(WEEKDAY, started_at)
ORDER BY
	DATEPART(WEEKDAY, started_at);


/*
Scratch pad
*/

USE [CaseStudy1-Cyclistic]

SELECT
	COUNT(*)
FROM
	divvy_tripdata
WHERE
	rideable_type = 'docked_bike'
	OR ride_duration_seconds < 60 
	OR ride_duration_seconds > (60*60*12);

