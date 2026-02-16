-- Lab 1: Books Read Tracker
-- Author: Abdul Basit
-- Date: 9-Feb-2026
CREATE TABLE books_read (
book_id SERIAL PRIMARY KEY,
title VARCHAR(200) NOT NULL,
author VARCHAR(100) NOT NULL,
category VARCHAR(50),
pages INTEGER CHECK (pages > 0),
date_finished DATE,
rating DECIMAL(3,1) CHECK (rating >= 0 AND rating <= 5.0),
notes TEXT
);
INSERT INTO books_read (title, author, category, pages, date_finished, rating,
notes) VALUES
('Python for Data Analysis', 'Wes McKinney', 'Data Science', 544, '2024-08-15',
4.5, 'Great for pandas library'),
('Designing Data-Intensive Applications', 'Martin Kleppmann', 'Databases', 616,
'2024-09-20', 5.0, 'Must-read for backend engineers'),
('The Hundred-Page Machine Learning Book', 'Andriy Burkov', 'Machine Learning',
160, '2024-10-05', 4.2, 'Concise ML overview'),
('Statistical Rethinking', 'Richard McElreath', 'Statistics', 593, '2024-11-12',
4.8, 'Bayesian statistics approach'),
('Clean Code', 'Robert C. Martin', 'Programming', 464, '2024-12-01', 4.0, 'Good
coding practices');
