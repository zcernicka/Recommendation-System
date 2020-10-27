CREATE TABLE movies (
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
ELECT * FROM movies WHERE url=’the-lion-king’;
ALTER TABLE movies
ADD lexemestitle tsvector;
UPDATE movies
SET lexemestitle=to_tsvector(title);
SELECT url FROM movies
WHERE lexemestitle @@ to_tsquery(‘lion’);
ALTER TABLE movies
ADD rank float4;
UPDATE movies
SET rants_rank(lexemestitle,plainto_tsquery(
(
SELECT title FROM movies WHERE url=’the-lion-king’
)
));
SELECT url, rank FROM movies WHERE rank >0 ORDER BY rank DESC LIMIT 50
