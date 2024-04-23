SELECT *
FROM worldlifeexpectancy;

SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`), ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) Life_Increase_15_Years
FROM worldlifeexpectancy
GROUP by Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years DESC
;

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM worldlifeexpectancy
WHERE`Life expectancy` <> 0
AND `life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

SELECT *
FROM worldlifeexpectancy
;

SELECT Country, ROUND(AVG(`life expectancy`),2) AS Life_exp, ROUND(AVG(GDP),2) AS GDP
FROM worldlifeexpectancy
GROUP BY Country
HAVING Life_exp > 0
AND GDP > 0
ORDER BY GDP DESC
;

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >=1500 THEN `Life expectancy` ELSE NULL END) High_GDP_life_Expectancy,
SUM(CASE WHEN GDP <=1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <=1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_life_Expectancy
FROM worldlifeexpectancy
;

#Comparing the life expectancy between Developed and Developing country

SELECT Status, ROUND(AVG(`Life expectancy`),1) as AvgLifeExpectancy
FROM worldlifeexpectancy
GROUP by Status
;

# Only 32Developed Country vs 161Developing Country
SELECT Status, COUNT(DISTINCT Country)
FROM worldlifeexpectancy
GROUP BY Status;

SELECT Status, COUNT(distinct Country), ROUND(AVG(`Life expectancy`),1)
FROM worldlifeexpectancy
GROUP BY Status;

#Checking each country's average Life Expectancy and Average BMI
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM worldlifeexpectancy
GROUP BY Country
HAVING life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC
;

Select Country,
Year
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(partition by Country ORDER BY Year) AS Rolling_Total
FROM worldlifeexpectancy
WHERE Country LIKE '%United%'
;

