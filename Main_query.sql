WITH join_all AS (
    SELECT username,country,city,artist_name,album_title,subscription_type,count(stream_id) AS streams_count,sum(duration_sec) as listening_time FROM stream_history
    JOIN users on stream_history.user_id = users.user_id
    JOIN track ON stream_history.track_id = track.track_id
    JOIN album ON track.album_id = album.album_id
    JOIN artist ON album.artist_id = artist.artist_id
    WHERE DATE(stream_date) BETWEEN '2026-06-09' AND '2026-06-10'
    GROUP BY username,country,city,artist_name,album_title,subscription_type
)

SELECT * FROM join_all
WHERE country = 'Ukraine' AND subscription_type = 'Premium'
UNION ALL
SELECT * FROM join_all
WHERE country = 'Poland' AND subscription_type = 'Premium'
ORDER BY listening_time DESC