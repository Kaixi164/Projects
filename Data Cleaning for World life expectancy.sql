SELECT Country, Year, CONCAT(Country, Year) #Take a Glance on data
FROM worldlifeexpectancy
;

#Checking duplicated row

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country,Year))
FROM worldlifeexpectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

SELECT *
FROM (
	SELECT Row_ID,
	CONCAT(Country,Year),
	row_number() OVER(PARTITION BY CONCAT(Country, Year) 
	ORDER BY CONCAT(Country, Year)) as Row_num
	FROM worldlifeexpectancy
	) AS Row_table
WHERE Row_num > 1
;

#Updating table with duplicates removed

DELETE FROM worldlifeexpectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
FROM(
	SELECT Row_ID,
	CONCAT(Country,Year),
	row_number() OVER(PARTITION BY CONCAT(Country, Year) 
	ORDER BY CONCAT(Country, Year)) as Row_num
	FROM worldlifeexpectancy
	) AS Row_table
WHERE Row_num > 1
);
    
#Checking Nulls 

SELECT *
FROM worldlifeexpectancy
WHERE Status = ''
;

SELECT DISTINCT(status)
FROM worldlifeexpectancy
WHERE Status <> ''
;

#Populating blanks with matching data

SELECT DISTINCT(Country)
FROM worldlifeexpectancy
WHERE Status = 'Developing'
;

UPDATE worldlifeexpectancy
SET Status = 'Developing'
WHERE country 	IN (SELECT DISTINCT(Country)
				WHERE Status = 'Developing');
                
UPDATE worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

UPDATE worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

#Working on populating another column named life expectancy

SELECT *
FROM worldlifeexpectancy
#Where `life expectancy` = ''
;

#Populate the blanked life expectancy by taking average from result of ahead and previous year.
SELECT Country,Year, `life expectancy`
FROM worldlifeexpectancy;

SELECT t1.Country, t1.Year, 
t1.`Life expectancy`,
 t2.Country,t2.Year,
 t2.`Life expectancy`,
 t3.Country,t3.Year,
 t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN worldlifeexpectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';


UPDATE worldlifeexpectancy t1
JOIN worldlifeexpectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN worldlifeexpectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''




