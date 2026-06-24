SELECT
    t.track_id,
    t.track_title,
    al.album_title,
    COUNT(sh.stream_id) AS "streaming_count"
FROM streaming.track t
JOIN streaming.album al ON t.album_id = al.album_id
LEFT JOIN streaming.stream_history sh ON t.track_id = sh.track_id
WHERE al.artist_id = (
    SELECT album.artist_id
    FROM streaming.track
    JOIN streaming.album ON track.album_id = album.album_id
    WHERE track.track_id = 10
)
GROUP BY t.track_id, t.track_title, al.album_title
ORDER BY COUNT(sh.stream_id) DESC
LIMIT 20;