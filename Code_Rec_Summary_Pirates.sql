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
SELECT * FROM movies where url='pirates-of-the-caribbean-the-curse-of-the-black-pearl';
ALTER TABLE movies
ADD lexemesSummary tsvector;
UPDATE movies
SET lexemesSummary = to_tsvector(Summary);
SELECT url FROM movies
WHERE lexemesSummary @@ to_tsquery('pirate');
ALTER TABLE movies
ADD rank float4;
UPDATE movies
SET rank=ts_rank(lexemessummary,plainto_tsquery(
(
SELECT Summary FROM movies WHERE url='pirates-of-the-caribbean-the-curse-of-the-black-pearl'
)
));
CREATE TABLE recommendationsBasedOnSummaryField AS
SELECT url, rank FROM movies WHERE rank>0.77 ORDER BY rank DESC LIMIT 50;
\copy (SELECT * FROM recommendationsBasedOnSummaryField) to '/home/pi/RSL/recommendationsBasedOnSummaryField.csv' WITH csv;
