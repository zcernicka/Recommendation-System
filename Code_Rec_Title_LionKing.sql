CREATE TABLE IF NOT EXISTS movies (
url TEXT,
title TEXT,
RealeaseDate TEXT,
Distributor TEXT,
Starring TEXT,
Summary TEXT,
Director TEXT,
Genre TEXT,
Rating TEXT,
Runtime TEXT,
Userscore TEXT,
Metascore TEXT,
coreCounts TEXT
)
;
\copy movies FROM '/home/pi/RSL/moviesFromMetacritic.csv' DELIMITER';' csv header
SELECT * FROM movies WHERE url='the-lion-king';
ALTER TABLE movies
ADD IF NOT EXISTS lexemestitle tsvector;
UPDATE movies
SET lexemestitle=to_tsvector(title);
SELECT url FROM movies
WHERE lexemestitle @@ to_tsquery('lion''king'); 
ALTER TABLE movies
ADD IF NOT EXISTS rank_title float4;
UPDATE movies
SET rank_title=ts_rank(lexemestitle,plainto_tsquery(
(
SELECT title FROM movies WHERE url='the-lion-king'
)
));
SELECT url, rank_title FROM movies WHERE rank_title >0 ORDER BY rank_title DESC LIMIT 50
