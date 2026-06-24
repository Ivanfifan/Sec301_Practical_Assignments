CREATE OR REPLACE VIEW top_20_tracks AS (
    SELECT
        t.track_id,
        t.track_title,
        al.album_title,
        COUNT(sh.stream_id) AS streaming_count
    FROM streaming.track t
    JOIN streaming.album al ON t.album_id = al.album_id
    LEFT JOIN streaming.stream_history sh ON t.track_id = sh.track_id
    GROUP BY t.track_id, t.track_title, al.album_title
    ORDER BY COUNT(sh.stream_id) DESC
    LIMIT 20
);