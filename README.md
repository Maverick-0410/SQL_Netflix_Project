# Netflix Movies and TV shows Data Analysis using SQL

![Netflix logo](https://github.com/Maverick-0410/SQL_Netflix_Project/blob/main/Netflix_logo.jpg)

## Dataset
The data used in this project has been sourced from Kaggle

Link: [Netflix dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, count(*) as total_content FROM netflix
GROUP BY type;
```


### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```


### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * from netflix
WHERE 
	release_year=2020 
	AND 
	type = 'Movie';
```


### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country;, 
	count(*) as total_content 
from netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;
```


### 5. Identify the Longest Movie

```sql
SELECT 
	title,
	SPLIT_PART(duration,' ',1)::NUMERIC AS duration_minutes
FROM netflix
WHERE 
	type = 'Movie'
	AND
	SPLIT_PART(duration,' ',1)::NUMERIC IS NOT NULL
ORDER BY duration_minutes DESC LIMIT 1;
```


### 6. Find Content Added in the Last 5 Years

```sql
SELECT * FROM netflix
WHERE
	TO_DATE(date_added, 'Monthh DD, YYYY') >= Current_date - INTERVAL '5 years';
```


### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'
```


### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::NUMERIC > 5
```


### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY (listed_in, ','))) AS Genre,
	COUNT (*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;
```


### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	Count (*),
	ROUND(Count (*)::NUMERIC / (SELECT count(*) FROM netflix WHERE country='India')::NUMERIC * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country= 'India'
GROUP BY 1
ORDER BY 1 DESC LIMIT 5;
```


### 11. List All Movies that are Documentaries

```sql
SELECT * FROM netflix
WHERE
	type= 'Movie'
	AND
	listed_in ILIKE '%Documentaries%'
```


### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix
WHERE
	director IS NULL;
```


### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT count(*) FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT (YEAR FROM CURRENT_DATE) - 10
```


### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
	count(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;
```


### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```




