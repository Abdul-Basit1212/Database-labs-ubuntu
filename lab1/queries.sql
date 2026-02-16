-- Lab 1: Analytical Queries
-- Author: Abdul Basit
-- Query 1: Filter books by specific category
SELECT title, author, rating
FROM books_read
WHERE category = 'Machine Learning';

-- Query 2: High rated books sorted by rating
SELECT title, rating, date_finished
FROM books_read
WHERE rating >= 4.5
ORDER BY rating DESC;

-- Query 3: Average pages and book count by category
SELECT category, AVG(pages) as avg_pages, COUNT(*) as book_count
FROM books_read
GROUP BY category
ORDER BY avg_pages DESC;

-- Query 4: Total sum of pages read
SELECT SUM(pages) as total_pages_read
FROM books_read;

-- Query 5: Monthly reading volume and page totals
SELECT TO_CHAR(date_finished, 'YYYY-MM') as month, COUNT(*) as books_finished, SUM(pages) as pages_read
FROM books_read
GROUP BY TO_CHAR(date_finished, 'YYYY-MM')
ORDER BY month;

-- Query 6: Top 3 longest books
SELECT title, author, pages
FROM books_read
ORDER BY pages DESC
LIMIT 3;

-- Query 7: First 3 books finished (chronological)
SELECT title, author, date_finished
FROM books_read
ORDER BY date_finished ASC
LIMIT 3;

-- Query 8: Next books finished using offset (pagination)
SELECT title, author, date_finished
FROM books_read
ORDER BY date_finished ASC
OFFSET 3;

-- Query 9: Average rating by category
SELECT category, AVG(rating) AS avg_rating
FROM books_read
GROUP BY category
ORDER BY avg_rating DESC;

-- Query 10: Rounded average rating with book count
SELECT category, COUNT(*), ROUND(AVG(rating), 2) AS avg_rating
FROM books_read
GROUP BY category
ORDER BY avg_rating DESC;

-- Query 11: Longest reading streak (count only)
WITH monthly_activity AS (
SELECT DISTINCT DATE_TRUNC('month', date_finished) AS read_month
FROM books_read
),
streaks AS (
SELECT read_month, read_month - (INTERVAL '1 month' * DENSE_RANK() OVER (ORDER BY read_month)) AS group_id
FROM monthly_activity
)
SELECT COUNT(*) AS streak_length
FROM streaks
GROUP BY group_id
ORDER BY streak_length DESC
LIMIT 1;

-- Query 12: Longest reading streak with start and end dates
WITH monthly_activity AS (
SELECT DISTINCT DATE_TRUNC('month', date_finished) AS read_month
FROM books_read
),
streaks AS (
SELECT read_month, read_month - (INTERVAL '1 month' * DENSE_RANK() OVER (ORDER BY read_month)) AS group_id
FROM monthly_activity
)
SELECT COUNT(*) AS streak_length, MIN(read_month) AS streak_start, MAX(read_month) AS streak_end
FROM streaks;

-- Query 13: Update author for a specific book title
UPDATE books_read
SET author = 'Wes McKinney'
WHERE title = 'Clean Code';

-- Query 14: Identify authors with multiple books
SELECT author, COUNT() AS books_written
FROM books_read
GROUP BY author
HAVING COUNT() > 1;
