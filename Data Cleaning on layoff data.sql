SELECT * 
FROM world_layoff.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank values
-- 4. Remove Any Columns

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry,total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions ) AS row_num
FROM layoffs_copy
;

#Because the following string is not executable, we have to create a new table to make row_num as an actual column
SELECT *
FROM layoffs_copy
WHERE company = 'Casper';

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry,total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions) AS row_num
FROM layoffs_copy
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#This step is to insert these filtered(partitioned data) into new table with 'row_num'stand as an individual column
INSERT INTO layoffs_copy2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,
country,funds_raised_millions) AS row_num
FROM layoffs_copy;

DELETE
FROM layoffs_copy2
WHERE row_num > 1;

SELECT *
FROM layoffs_copy2;

-- Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2;


UPDATE layoffs_copy2
set company = TRIM(company)
;

SELECT DISTINCT industry
FROM layoffs_copy2
ORDER BY 1
;

#Since we have a discrepency in company name related with Crypto, we use '%'sign to select company name started with 'Crypto'
SELECT *
FROM layoffs_copy2
WHERE industry LIKE 'Crypto%'
;
UPDATE layoffs_copy2
SET industry = 'Crypto'
WHERE industry like 'Crypto%'
;

#This is removing additional '.' from mis type.
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_copy2
WHERE country LIKE 'United States%'
;

UPDATE layoffs_copy2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

#Reformating the date format 
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_copy2
;

UPDATE layoffs_copy2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y')
;

#Changing the date column from text to date format
ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` DATE
;

SELECT *
FROM layoffs_staging2;

#Now solving the Null and blank problem

SELECT *
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

#Four given industry may possibly get populated
SELECT *
FROM layoffs_copy2
WHERE industry IS NULL
OR industry = '';

#we could use query to populate 'Travel' industry to another observation
SELECT *
FROM layoffs_copy2
WHERE company = 'Airbnb';


#After selfjoin, finding similiar roles which can popluate each other
SELECT t1.industry, t2.industry
FROM layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company = t2.company
AND t1.location = t2.location
WHERE (t1.industry IS NULL or t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_copy2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_copy2 t1
JOIN layoffs_copy2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry #Adjust this part to 
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

#Remvoe unnecessary column

#This query would select all the records which are missing two critical information as being an observation
SELECT *
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

#Drop unnecessary column
ALTER TABLE layoffs_copy2
DROP COLUMN row_num;

SELECT *
FROM layoffs_copy2