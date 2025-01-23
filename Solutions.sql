-- Netflix Project

CREATE TABLE netflix 
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);


-- 1. Count the number of Movies vs TV Shows

SELECT type, count(*) as total_content FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT type, rating as Most_common_rating
FROM
(
	SELECT 
		type, 
		rating, 
		count(*), 
		rank() OVER(PARTITION BY type ORDER BY count(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
)
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * from netflix
WHERE 
	release_year=2020 
	AND 
	type = 'Movie'

-- 4. Find the top 5 countries with the most content on Netflix
 /* point to note: some entries in the country column have more than one country in the same cell */

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country;, 
	count(*) as total_content 
from netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;
	/* the string to array function first converts the text into an array seperated by commmas. the unnest breaks
	that array into individual entries and the trim function removes the space which is usually given after comma*/

-- 5. Identify the longest movie

SELECT 
	title,
	SPLIT_PART(duration,' ',1)::NUMERIC AS duration_minutes
FROM netflix
WHERE 
	type = 'Movie'
	AND
	SPLIT_PART(duration,' ',1)::NUMERIC IS NOT NULL
ORDER BY duration_minutes DESC LIMIT 1;

	/* In the table, duration is a string. so cannot directly use MAX function*/
	/* The split part function extracts the string before space and converts it into a number. now you can use max.
	You can't used duration_minutes directly in line 69 because where clause is run before select cluase and in that
	case the variable wouldn't have been defined. */


-- 6. Find content added in the last 5 years

SELECT * FROM netflix
WHERE
	TO_DATE(date_added, 'Monthh DD, YYYY') >= Current_date - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::NUMERIC > 5

	/* the split part function here splits the duration col with space as delimiter and returns the first (1) part */

-- 9. Count the number of content items in each genre

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY (listed_in, ','))) AS Genre,
	COUNT (*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

-- 10. Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	Count (*),
	ROUND(Count (*)::NUMERIC / (SELECT count(*) FROM netflix WHERE country='India')::NUMERIC * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country= 'India'
GROUP BY 1
ORDER BY 1 DESC LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE
	type= 'Movie'
	AND
	listed_in ILIKE '%Documentaries%'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE
	director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT count(*) FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT (YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
	count(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_table AS
(
SELECT *,
	CASE
	WHEN
		description ILIKE '%kill%'
		OR
		description ILIKE '%violence%'
		THEN 'Bad_content'
		ELSE 'Good_content'
	END category
FROM netflix
)
SELECT 
	category,
	count(*) AS total_content
FROM new_table
GROUP BY 1;