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
