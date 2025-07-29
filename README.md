# Public-Transit-Analytics-with-SQL
**Author:** Shubham Yadav
**Date:** July 29, 2025

---

## Project Description

This project analyzes public transit data for Metro Vancouver using SQL to uncover insights into the transit system's operations. By leveraging a real-world GTFS (General Transit Feed Specification) dataset, this analysis identifies key patterns such as the busiest routes, most-served stops, and peak operational hours. The entire project is self-contained within a single SQL script that creates the necessary database schema, loads the data, and runs analytical queries.

---

## Data Source

The project uses the official static GTFS data provided by TransLink, Metro Vancouver's transit authority. The complete dataset can be downloaded from the following link:

* **Official TransLink GTFS Feed:** [https://gtfs.translink.ca/static/latest](https://gtfs.translink.ca/static/latest)

---

## Requirements

* **Database:** PostgreSQL
* **Database GUI (Recommended):** DBeaver or pgAdmin

---

## Setup & Execution

Follow these steps to set up the database and run the analysis.

### 1. Create the Database

Before running the script, create a new database in PostgreSQL.
```sql
CREATE DATABASE transit_db;
```

### 2. Download and Place Data Files

1. Download the dataset from the [Data Source](#data-source) link above. It will be a file named `gtfs.zip`.

2. Unzip the file.

3. Create a public folder on your system that PostgreSQL can access:

   * **On macOS/Linux:** `/tmp/data/`

   * **On Windows:** `C:\data\`

4. Move the following `.txt` files from the unzipped folder into the public folder you just created:

   * `routes.txt`

   * `trips.txt`

   * `stops.txt`

   * `stop_times.txt`

### 3. Run the SQL Script

1. Connect to your `transit_db` database using your preferred SQL client.

2. Open the `Transit_db.sql` file provided in this repository.

3. Execute the entire script.

The script will perform the following actions:
* Create the necessary tables (`routes`, `trips`, `stops`, `stop_times`).
* Load the data from the `.txt` files into the tables using the `COPY` command.
* Run a series of analytical queries to generate insights.

---

## Analysis & Queries

The script answers several key questions about the transit system:

### 1. What are the busiest routes by stop count?

This query identifies the top 15 bus routes that serve the most unique physical stops, highlighting the most extensive routes in the system.

```sql
-- FINAL ANALYSIS QUERY: Top 15 Bus Routes by Stop Count
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
    R.route_type = 3
GROUP BY
    R.route_short_name, R.route_long_name
ORDER BY
    number_of_stops DESC
LIMIT 15;
```

### 2. What are the busiest hours of the day?

This query finds the number of trips starting each hour of the day to identify peak operational periods.

```sql
-- Find the number of trips starting each hour of the day
SELECT
    SPLIT_PART(departure_time, ':', 1)::INT AS hour_of_day,
    COUNT(*) AS number_of_trips
FROM
    stop_times
WHERE
    stop_sequence = 1
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day ASC;
```

### 3. Which are the most-served transit stops?

This query finds the top 20 busiest stops by the number of unique trips that serve them, identifying major transit hubs.

```sql
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
```

### 4. How wheelchair accessible are popular routes?

This query analyzes the wheelchair accessibility for a specific popular route (the '99' bus route) by comparing the total number of unique stops to the number of accessible stops.

```sql
-- Analyze wheelchair accessibility for the '99' bus route
SELECT
    R.route_short_name,
    R.route_long_name,
    COUNT(DISTINCT S.stop_id) AS total_unique_stops,
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
    R.route_short_name = '99'
GROUP BY
    R.route_short_name, R.route_long_name;
