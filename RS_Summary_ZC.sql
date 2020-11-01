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
-- lexemesSummary should represent a sorted list of distinct lexemes from the summary field
ALTER TABLE movies
ADD IF NOT EXISTS lexemesSummary tsvector; 
-- variable summary is passed through to_tsvector to normalize the words appropriately for searching
UPDATE movies
SET lexemesSummary = to_tsvector(Summary);
-- full text search based on the match operator @@ when a tsvector (Summary) matches a tsquery ('lion' 'king'), to x-check if those words are found
SELECT url FROM movies
WHERE lexemesSummary @@ to_tsquery('lion''king');
-- another column added, if not existing to place the summary ranking
ALTER TABLE movies
ADD IF NOT EXISTS rank_summary float4;
--ranking gives a relevance between tsvector (lexemes) and tsquery and returns float4, taking into account matching proximity
--plainto_tsquery transforms the unformatted text querytext to a tsquery value from a summary when movie url equals the lion king
UPDATE movies
SET rank_summary=ts_rank(lexemessummary,plainto_tsquery(
(
SELECT Summary FROM movies WHERE url='the-lion-king'
)
));
-- rank threshold set to be above 0, to cover all existing movie matches in the desceinding order (best matching movies are displayed at the top of the list) and are copied to a csv list
CREATE TABLE IF NOT EXISTS  RS_Summary AS
SELECT url, rank_summary FROM movies WHERE rank_summary > 0 ORDER BY rank_summary DESC LIMIT 50
\copy (SELECT * FROM RS_Summary) to '/home/pi/RSL/Output/RS_Summary_ZC.csv' WITH csv;
