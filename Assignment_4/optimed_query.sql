CREATE INDEX idx_users_country_sub ON users(country, subscription_type);

CREATE INDEX idx_stream_history_covering ON stream_history(user_id, stream_date) INCLUDE (track_id, stream_id);

CREATE INDEX idx_track_album ON track(track_id) INCLUDE (album_id);
CREATE INDEX idx_album_artist ON album(album_id) INCLUDE (artist_id);

DROP INDEX IF EXISTS idx_users_country_sub;
DROP INDEX IF EXISTS idx_stream_history_covering;
DROP INDEX IF EXISTS idx_track_album;
DROP INDEX IF EXISTS idx_album_artist;

EXPLAIN ANALYZE
WITH premium_streams AS (
    SELECT
        sh.track_id,
        sh.stream_id,
        u.country
    FROM stream_history sh
    JOIN users u ON sh.user_id = u.user_id
    WHERE u.country = 'Ukraine'
      AND u.subscription_type = 'Premium'
      AND sh.stream_date >= '2023-12-01'
),
artist_stats AS (
    SELECT
        ar.artist_id,
        ar.artist_name,
        ar.genre,
        ps.country,
        COUNT(ps.stream_id) AS total_streams
    FROM premium_streams ps
    JOIN track t ON ps.track_id = t.track_id
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    GROUP BY ar.artist_id, ar.artist_name, ar.genre, ps.country
)
SELECT
    artist_name,
    genre,
    country,
    total_streams,
    RANK() OVER (PARTITION BY country ORDER BY total_streams DESC) as rank_in_country
FROM artist_stats
WHERE total_streams > 10
ORDER BY country, rank_in_country;



