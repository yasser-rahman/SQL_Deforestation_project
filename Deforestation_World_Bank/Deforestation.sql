-- Initializing the workspace
DROP VIEW IF EXISTS forestation
-- Creating View
CREATE VIEW forestation AS
  SELECT f.country_code country_code, f.country_name country,
   	  	 f.year AS Year, f.forest_area_sqkm forest_area_sqkm,
  		  (l.total_area_sq_mi * 2.59) land_area_sqkm, r.region region,
         r.income_group income_group,
         ROUND(CAST(((f.forest_area_sqkm / (l.total_area_sq_mi * 2.59)) * 100)
         AS NUMERIC), 2) forest_percentage

  FROM forest_area f
  INNER JOIN  land_area l
  ON f.country_code = l.country_code
  AND f.year = l.year
  INNER JOIN regions r
  ON f.country_code = r.country_code


-- a. What was the total forest area (in sq km) of the world in 1990?

SELECT forest_area_sqkm World_forest_Arae_1990
FROM forestation
WHERE year = 1990 AND country = 'World';
-- 41,282,694.9


-- b. What was the total forest area (in sq km) of the world in 2016?


SELECT forest_area_sqkm World_forest_Arae_2016
FROM forestation
WHERE year = 2016 AND country = 'World';
-- 39,958,245.9




-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
-- d. What was the percent change in forest area of the world between 1990 and 2016?


SELECT (_1990.forest_area_sqkm  - _2016.forest_area_sqkm) AS area_difference,
((_1990.forest_area_sqkm  - _2016.forest_area_sqkm) / _1990.forest_area_sqkm *100)
 AS area_diff_percentage
FROM forestation AS _1990
JOIN forestation AS _2016
ON _1990.year =1990 AND _2016.year =2016
AND _1990.country_name = 'World'
AND _2016.country_name = 'World'
-- 1,324,449 area difference
-- 3.2% percentage difference

--e. If you compare the amount of forest area lost between 1990 and 2016,
-- to which country's total area in 2016 is it closest to?

SELECT country, land_area_sqkm
FROM forestation
WHERE ABS(land_area_sqkm - 1324449) < 100000 --Arbitrary vakue
ORDER BY 2 DESC
LIMIT 1
-- Peru         land_area_sqkm = 1279999.9891

/****************   Regional Outlook    **************************/
-- a. What was the percent forest of the entire world in 2016? Which
-- region had the HIGHEST percent forest in 2016, and which had the LOWEST,
-- to 2 decimal places?

-- Percent forest entire world in 2016:
SELECT forest_percentage AS world_forest_2016
FROM forestation
WHERE year = 2016 AND country = 'World';
-- 31.38%

-- Getting the country with max forest_percentage in 2016
SELECT country, forest_percentage
FROM forestation
WHERE forest_percentage = (
              SELECT MAX(forest_percentage) AS max_forest_percentage
              FROM forestation
              WHERE year = 2016);
-- Country = Suriname, forest_percentage = 98.26

-- Getting the country with min forest_percentage in 2016
SELECT country, forest_percentage
FROM forestation
WHERE forest_percentage = (
              SELECT MIN(forest_percentage) AS min_forest_percentage
              FROM forestation
              WHERE year = 2016);

-- Country = Greenland, forest_percentage = 0%

-- b. What was the percent forest of the entire world in 1990? Which region
-- had the HIGHEST percent forest in 1990, and which had the LOWEST,
-- to 2 decimal places?

SELECT forest_percentage AS world_forest_1990
FROM forestation
WHERE year = 1990 AND country = 'World';
-- 32.42%

-- Getting the country with max forest_percentage in 1990
SELECT country, forest_percentage
FROM forestation
WHERE forest_percentage = (
              SELECT MAX(forest_percentage) AS max_forest_percentage
              FROM forestation
              WHERE year = 1990);

-- Country = Suriname, forest_percentage = 98.91%

-- Getting the country with min forest_percentage in 1990
SELECT country, forest_percentage
FROM forestation
WHERE forest_percentage = (
              SELECT MIN(forest_percentage) AS min_forest_percentage
              FROM forestation
              WHERE year = 1990);
-- Country = Greenland, forest_percentage = 0%

--Create a table that shows the Regions and their percent forest area
-- in 1990 and 2016.

WITH t1 AS(

          SELECT region,
          ROUND(CAST(SUM(forest_area_sqkm) AS NUMERIC), 2) AS forest_area
          FROM forestation
          WHERE year = 1990
          GROUP BY 1),
    t2 AS(
          SELECT region,
          ROUND(CAST(SUM(land_area_sqkm) AS NUMERIC), 2) AS land_area
          FROM forestation
          WHERE year = 1990
          GROUP BY 1),
    t3 AS(
          SELECT region,
          ROUND(CAST(SUM(forest_area_sqkm) AS NUMERIC), 2) AS forest_area
          FROM forestation
          WHERE year = 2016
          GROUP BY 1),
    t4 AS(
          SELECT region,
          ROUND(CAST(SUM(land_area_sqkm) AS NUMERIC), 2) AS land_area
          FROM forestation
          WHERE year = 2016
          GROUP BY 1)


SELECT t1.region,
       ROUND((t1.forest_area/t2.land_area*100), 2) _1990,
			 ROUND((t3.forest_area/t4.land_area*100), 2) _2016
FROM t1
JOIN t2 ON t1.region = t2.region
JOIN t3 ON t2.region = t3.region
JOIN t4 ON t3.region = t4.region
ORDER BY 2 DESC

--The Top 2 countries where forest_area has increased from 1990 and _2016
SELECT f1.country AS country_name,
       f1.forest_area_sqkm AS forest_area_1990,
       f2.forest_area_sqkm AS forest_area_2016
       f2.forest_area_sqkm - f1.forest_area_sqkm AS forest_area_gained
FROM forestation AS f1
JOIN forestation AS f2
ON f1.country = f2.country
AND f1.year = 1990 AND f2.year = 2016
ORDER BY 3 DESC;

-- China and USA
--The Top 1 country where forest_area_percenrage has increased from
--1990 and _2016

SELECT f1.country AS country_name,
       f1.forest_area_sqkm AS forest_area_1990,
       f2.forest_area_sqkm AS forest_area_2016,
       (100.0 *(f2.forest_area_sqkm - f1.forest_area_sqkm) / f1.forest_area_sqkm)
        AS forest_area_gained_percentage
FROM forestation AS f1
JOIN forestation AS f2
ON f1.country = f2.country
AND f1.year = 1990 AND f2.year = 2016
ORDER BY 4 DESC;

-- Iceland 213.66 %

-- a. Which 5 countries saw the largest amount decrease in forest area
-- from 1990 to 2016? What was the difference in forest area for each?
SELECT f1.country,
		   f1.region,
       f1.forest_area_sqkm - f2.forest_area_sqkm AS difference
FROM forestation AS f1
JOIN forestation AS f2
  ON  (f1.year = '2016' AND f2.year = '1990')
  AND f1.country = f2.country
ORDER BY 3;

--b. Which 5 countries saw the largest percent decrease in forest area
-- from 1990 to 2016? What was the percent change to 2 decimal places for each?

SELECT f1.country,
		   f1.region,
      (100.0 * (f1.forest_area_sqkm - f2.forest_area_sqkm) / f2.forest_area_sqkm)
       AS diff_percentage
FROM forestation AS f1
JOIN forestation AS f2
  ON  (f1.year = '2016' AND f2.year = '1990')
  AND f1.country = f2.country
ORDER BY 3;


-- c. If countries were grouped by percent forestation in quartiles,
-- which group had the most countries in it in 2016?

SELECT distinct(quartiles), COUNT(country) OVER (PARTITION BY quartiles)
FROM (SELECT country,
  CASE WHEN forest_percentage <= 25 THEN '0-25%'
  WHEN forest_percentage <= 75 AND forest_percentage > 50 THEN '50-75%'
  WHEN forest_percentage <= 50 AND forest_percentage > 25 THEN '25-50%'
  ELSE '75-100%'
END AS quartiles FROM forestation
WHERE forest_percentage IS NOT NULL AND year = 2016) quart;


--quartiles	count
-- 0-25%	85
-- 25-50%	73
-- 50-75%	38
-- 75-100%	9

-- d. List all of the countries that were in the 4th quartile (
-- percent forest > 75%) in 2016.

SELECT country, region, forest_percentage
FROM forestation
WHERE forest_percentage > 75 AND year = 2016
ORDER BY 3 DESC;

-- country	region	forest_percentage
-- Suriname	Latin America & Caribbean	98.26
-- Micronesia, Fed. Sts.	East Asia & Pacific	91.86
-- Gabon	Sub-Saharan Africa	90.04
-- Seychelles	Sub-Saharan Africa	88.41
-- Palau	East Asia & Pacific	87.61
-- American Samoa	East Asia & Pacific	87.50
-- Guyana	Latin America & Caribbean	83.90
-- Lao PDR	East Asia & Pacific	82.11
-- Solomon Islands	East Asia & Pacific	77.86

 
