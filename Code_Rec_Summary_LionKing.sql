CREATE TABLE IF NOT EXISTS movies (
url TEXT,
title TEXT,
RealeaseDate TEXT,
Distributor TEXT,
Starring TEXT,
Summary TEXT, --hello
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
SELECT * FROM movies where url='the-lion-king';
ALTER TABLE movies
ADD IF NOT EXISTS lexemesSummary tsvector; 
--a sorted list of distinct lexemes,tsvector type itself does not perform any word normalization; it assumes the words it is given are normalized
UPDATE movies
SET lexemesSummary = to_tsvector(Summary);
--Raw document text should usually be passed through to_tsvector to normalize the words appropriately for searching
SELECT url FROM movies
WHERE lexemesSummary @@ to_tsquery('lion''king');
--Full text searching based on the match operator @@, which returns true if a tsvector (document) matches a tsquery (query)
ALTER TABLE movies
ADD IF NOT EXISTS rank_summary float4;
UPDATE movies
SET rank_summary=ts_rank(lexemessummary,plainto_tsquery(
(
SELECT Summary FROM movies WHERE url='the-lion-king'
)
));
--ranking gives a relevance between tsvector (lexemes) and tsquery and returns float4, taking into account matching proximity
--plainto_tsquery transforms the unformatted text querytext to a tsquery value
SELECT url, rank_summary FROM movies WHERE rank_summary >0 ORDER BY rank_summary DESC LIMIT 50
