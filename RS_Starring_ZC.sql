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
-- lexemesstarring should represent a sorted list of distinct lexemes from the starring field
ALTER TABLE movies
ADD IF NOT EXISTS lexemesstarring tsvector;
-- variable starring is passed through to_tsvector to normalize the words appropriately for searching
UPDATE movies
SET lexemesstarring=to_tsvector(starring);
-- full text search based on the match operator @@ when a tsvector (Starring) matches a tsquery ('Jones''Irons''Broderick''Goldberg'), to x-check if those words are found
SELECT url FROM movies
WHERE lexemesstarring @@ to_tsquery ('Jones''Irons''Broderick''Goldberg');
ALTER TABLE movies
-- another column added, if not existing to place the starring ranking
ADD IF NOT EXISTS rank_starring float4;
--ranking gives a relevance between tsvector (lexemes) and tsquery and returns float4, taking into account matching proximity
--plainto_tsquery transforms the unformatted text querytext to a tsquery value from a starring when movie url equals the lion king
UPDATE movies
SET rank_starring=ts_rank(lexemesstarring,plainto_tsquery(
(
SELECT starring FROM movies WHERE url='the-lion-king'
)
));
-- rank threshold set to be above 0, to cover all existing movie matches in the desceinding order (best matching movies are displayed at the top of the list) and are copied to a csv list
CREATE TABLE IF NOT EXISTS  RS_Starring AS
SELECT url, rank_starring FROM movies WHERE rank_starring >0 ORDER BY rank_starring DESC LIMIT 50
\copy (SELECT * FROM RS_Starring) to '/home/pi/RSL/Output/RS_Starring_ZC.csv' WITH csv;
