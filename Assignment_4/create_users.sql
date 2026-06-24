-- СТВОРЕННЯ РОЛЕЙ (КОРИСТУВАЧІВ)
CREATE ROLE music_admin WITH LOGIN PASSWORD 'Admin1234';
CREATE ROLE music_artist WITH LOGIN PASSWORD 'Artist1234';
CREATE ROLE music_listener WITH LOGIN PASSWORD 'Listener1234';

-- НАДАННЯ ДОСТУПУ ДО СХЕМИ
GRANT USAGE ON SCHEMA streaming TO music_admin, music_artist, music_listener;

-- MUSIC_ADMIN
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA streaming TO music_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA streaming TO music_admin;

-- MUSIC_ARTIST
GRANT SELECT ON streaming.artist, streaming.users TO music_artist;
GRANT SELECT, INSERT, UPDATE, DELETE ON streaming.album, streaming.track TO music_artist;
GRANT SELECT ON streaming.stream_history TO music_artist;
GRANT USAGE, SELECT ON SEQUENCE streaming.album_album_id_seq, streaming.track_track_id_seq TO music_artist;

-- MUSIC_LISTENER
GRANT SELECT ON streaming.artist, streaming.album, streaming.track TO music_listener;
GRANT SELECT, INSERT ON streaming.stream_history TO music_listener;
GRANT SELECT, INSERT, UPDATE, DELETE ON streaming.playlist, streaming.playlist_tracks TO music_listener;
GRANT SELECT, INSERT, UPDATE ON streaming.users, streaming.user_billing_info TO music_listener;
GRANT USAGE, SELECT ON SEQUENCE streaming.users_user_id_seq, streaming.stream_history_stream_id_seq, streaming.playlist_playlist_id_seq TO music_listener;