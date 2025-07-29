-- =================================================================
-- Project: Public Transit Analytics with SQL
-- Author: Shubham Yadav
-- Date: July 29, 2025
-- Description: This script creates the necessary tables for analyzing
--              GTFS data and runs a query to find the top 15 bus
--              routes with the most stops in the transit system.
-- =================================================================


--Create table
DROP TABLE IF EXISTS routes;
	CREATE TABLE routes (
	    route_id VARCHAR(100) PRIMARY KEY,
	    agency_id VARCHAR(100),
	    route_short_name VARCHAR(50),
	    route_long_name VARCHAR(255),
	    route_desc TEXT,
	    route_type INT,
	    route_url TEXT,
	    route_color VARCHAR(6),
	    route_text_color VARCHAR(6)
	);


-- For trips.txt
DROP TABLE IF EXISTS trips;
	CREATE TABLE trips (
	    route_id VARCHAR(100),
	    service_id VARCHAR(100),
	    trip_id VARCHAR(100) PRIMARY KEY,
	    trip_headsign VARCHAR(255),
	    trip_short_name VARCHAR(100),
	    direction_id INT,
	    block_id VARCHAR(100),
	    shape_id VARCHAR(100),
	    wheelchair_accessible INT,
	    bikes_allowed INT
	);
	

-- For stop_times.txt
DROP TABLE IF EXISTS stop_times;
	CREATE TABLE stop_times (
	    trip_id VARCHAR(100),
	    arrival_time TEXT,
	    departure_time TEXT,
	    stop_id VARCHAR(100),
	    stop_sequence INT,
	    stop_headsign VARCHAR(255),
	    pickup_type INT,
	    drop_off_type INT,
	    shape_dist_traveled REAL,
	    timepoint INT,
	    PRIMARY KEY (trip_id, stop_sequence)
	);



-- For stops.txt
DROP TABLE IF EXISTS stops;
	CREATE TABLE stops (
	    stop_id VARCHAR(100) PRIMARY KEY,
	    stop_code VARCHAR(50),
	    stop_name VARCHAR(255),
	    stop_desc TEXT,
	    stop_lat DECIMAL(9, 6),
	    stop_lon DECIMAL(9, 6),
	    zone_id VARCHAR(100),
	    stop_url TEXT,
	    location_type INT,
	    parent_station VARCHAR(100),
	    wheelchair_boarding INT
	);

	
	
	
	-- Load the routes data
	COPY routes FROM '/tmp/data/routes.txt' DELIMITER ',' CSV HEADER;
	
	-- Load the trips data
	COPY trips FROM '/tmp/data/trips.txt' DELIMITER ',' CSV HEADER;
	
	-- Load the stops data
	COPY stops FROM '/tmp/data/stops.txt' DELIMITER ',' CSV HEADER;
	
	-- Load the stop_times data
	COPY stop_times FROM '/tmp/data/stop_times.txt' DELIMITER ',' CSV HEADER;
	
	--ou can verify that it worked by running a SELECT query:
	SELECT * FROM routes LIMIT 5;

--Q1. What are the busiest routes by stop count?

	SELECT
	    R.route_short_name,
	    R.route_long_name,
	    COUNT(DISTINCT ST.stop_id) AS number_of_stops
	FROM
	    routes AS R
	JOIN
	    trips AS T ON R.route_id = T.route_id
	JOIN
	    stop_times AS ST ON T.trip_id = ST.trip_id
	WHERE
	    R.route_type = 3 -- This filters for buses only
	GROUP BY
	    R.route_short_name, R.route_long_name
	ORDER BY
	    number_of_stops DESC
LIMIT 15;

--Q2 What are the busiest hours of the day?

-- Find the number of trips starting each hour of the day

-- Find the number of trips starting each hour of the day

	SELECT
	    -- Split the text by ':' and take the first part, then convert it to a number
	    SPLIT_PART(departure_time, ':', 1)::INT AS hour_of_day,
	    COUNT(*) AS number_of_trips
	FROM
	    stop_times
	WHERE
	    stop_sequence = 1 -- Filter for only the first stop of each trip
	GROUP BY
	    hour_of_day
	ORDER BY
	    hour_of_day ASC; -- Order by hour to see the full daily schedule

--Q3 Which are the most-served transit stops?

-- Find the top 20 busiest stops by trip count
	SELECT
	    S.stop_name,
	    COUNT(DISTINCT ST.trip_id) AS number_of_trips
	FROM
	    stops AS S
	JOIN
	    stop_times AS ST ON S.stop_id = ST.stop_id
	GROUP BY
	    S.stop_name
	ORDER BY
	    number_of_trips DESC
	LIMIT 20;

--Q4. Which popular routes are the most wheelchair accessible?

-- Analyze wheelchair accessibility for the '99' bus route
SELECT
    R.route_short_name,
    R.route_long_name,
    -- Count only the UNIQUE physical stops
    COUNT(DISTINCT S.stop_id) AS total_unique_stops,
    -- Count only the UNIQUE accessible stops
    COUNT(DISTINCT S.stop_id) FILTER (WHERE S.wheelchair_boarding = 1) AS accessible_unique_stops
FROM
    routes AS R
JOIN
    trips AS T ON R.route_id = T.route_id
JOIN
    stop_times AS ST ON T.trip_id = ST.trip_id
JOIN
    stops AS S ON ST.stop_id = S.stop_id
WHERE
    R.route_short_name = '99' -- Filter for a specific popular route
GROUP BY
    R.route_short_name, R.route_long_name;




	
--Thank you--

