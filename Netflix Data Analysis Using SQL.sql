create database netflix;
use netflix;
show tables;
select * from netflix_titles;

select type,count(*) from netflix_titles group by 1;
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rnk
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rnk = 1;

SELECT * FROM netflix_titles WHERE release_year = 2020;

WITH RECURSIVE country_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
        SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2) AS rest
    FROM netflix_titles
    WHERE country IS NOT NULL
    
    UNION ALL
    
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS country,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM country_split
    WHERE rest <> ''
)
SELECT 
    country,
    COUNT(*) AS total_content
FROM country_split
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

SELECT * FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

SELECT * FROM netflix_titles
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

WITH RECURSIVE director_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(director, ',', 1)) AS director_name,
        SUBSTRING(director, LENGTH(SUBSTRING_INDEX(director, ',', 1)) + 2) AS rest,
        type, title, cast, country, date_added, release_year, rating, duration, listed_in, description
    FROM netflix_titles
    WHERE director IS NOT NULL
    
    UNION ALL
    
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS director_name,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2),
        type, title, cast, country, date_added, release_year, rating, duration, listed_in, description
    FROM director_split
    WHERE rest <> ''
)
SELECT *
FROM director_split
WHERE director_name = 'Rajiv Chilaka';


SELECT *
FROM netflix_titles
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
  
  
WITH RECURSIVE genre_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
    FROM netflix_titles
    WHERE listed_in IS NOT NULL
    
    UNION ALL
    
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS genre,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM genre_split
    WHERE rest <> ''
)
SELECT 
    genre,
    COUNT(*) AS total_content
FROM genre_split
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_content DESC;

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) * 100.0 /
        (SELECT COUNT(show_id) FROM netflix_titles WHERE country = 'India'),
        2
    ) AS avg_release
FROM netflix_titles
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

SELECT * FROM netflix_titles WHERE listed_in LIKE '%Documentaries%';

SELECT * FROM netflix_titles WHERE director IS NULL;

SELECT * FROM netflix_titles WHERE cast LIKE '%Salman Khan%' AND release_year > YEAR(CURDATE()) - 10;

WITH RECURSIVE actor_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(`cast`, ',', 1)) AS actor,
        SUBSTRING(`cast`, LENGTH(SUBSTRING_INDEX(`cast`, ',', 1)) + 2) AS rest
    FROM netflix_titles
    WHERE `cast` IS NOT NULL AND country = 'India'
    
    UNION ALL
    
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS actor,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM actor_split
    WHERE rest <> ''
)
SELECT 
    actor,
    COUNT(*) AS total_content
FROM actor_split
WHERE actor IS NOT NULL AND actor <> ''
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY category;


