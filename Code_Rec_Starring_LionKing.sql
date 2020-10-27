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
ADD IF NOT EXISTS lexemesstarring tsvector;
UPDATE movies
SET lexemesstarring=to_tsvector(starring);
SELECT url FROM movies
WHERE lexemesstarring @@ to_tsquery ('Jones''Irons''Broderick''Goldberg');
ALTER TABLE movies
ADD IF NOT EXISTS rank_starring float4;
UPDATE movies
SET rank_starring=ts_rank(lexemesstarring,plainto_tsquery(
(
SELECT starring FROM movies WHERE url='the-lion-king'
)
));
SELECT url, rank_starring FROM movies WHERE rank_starring >0 ORDER BY rank_starring DESC LIMIT 50
