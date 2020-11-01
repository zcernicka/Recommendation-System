-- table creation only if it does not already exist within the database, where every column with its variable is defined
CREATE TABLE IF NOT EXISTS movies (
url TEXT,
title TEXT,
RealeaseDate DATE, 
Distributor TEXT,
Starring TEXT,
Summary TEXT, 
Director TEXT,
Genre TEXT,
Rating TEXT,
Runtime INT, 
Userscore FLOAT4, 
Metascore TEXT,
coreCounts TEXT
)
;
\copy movies FROM '/home/pi/RSL/Input/moviesFromMetacritic.csv' DELIMITER';' csv header
-- check if the lion king exists in the table, skipping this command in the final run
--SELECT * FROM movies where url='the-lion-king'; 
-- lexemestitle should represent a sorted list of distinct lexemes from the title field
ALTER TABLE movies
ADD IF NOT EXISTS lexemestitle tsvector;
-- variable title is passed through to_tsvector to normalize the words appropriately for searching
UPDATE movies
SET lexemestitle=to_tsvector(title);
-- full text search based on the match operator @@ when a tsvector (Title) matches a tsquery ('lion' 'king'), to x-check if those words are found
SELECT url FROM movies
WHERE lexemestitle @@ to_tsquery('lion''king'); 
ALTER TABLE movies
-- another column added, if not existing to place the title ranking
ADD IF NOT EXISTS rank_title float4;
--ranking gives a relevance between tsvector (lexemes) and tsquery and returns float4, taking into account matching proximity
--plainto_tsquery transforms the unformatted text querytext to a tsquery value from a title when movie url equals the lion king
UPDATE movies
SET rank_title=ts_rank(lexemestitle,plainto_tsquery(
(
SELECT title FROM movies WHERE url='the-lion-king'
)
));
-- rank threshold set to be above 0.01, to cover all existing movie matches in the desceinding order (best matching movies are displayed at the top of the list) and are copied to a csv list
CREATE TABLE IF NOT EXISTS  RS_Title AS
SELECT url, rank_title FROM movies WHERE rank_title > 0 ORDER BY rank_title DESC LIMIT 50
\copy (SELECT * FROM RS_Title) to '/home/pi/RSL/Output/RS_Title_ZC.csv' WITH csv;
