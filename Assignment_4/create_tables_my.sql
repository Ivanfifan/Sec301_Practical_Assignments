CREATE TABLE album (
  album_id SERIAL NOT NULL UNIQUE,
  artist_id INTEGER NOT NULL,
  album_title VARCHAR(255) NOT NULL,
  release_date DATE NOT NULL,
  PRIMARY KEY (album_id)
);

CREATE TABLE artist (
  artist_id SERIAL NOT NULL UNIQUE,
  artist_name VARCHAR(255) NOT NULL,
  genre VARCHAR(255) NOT NULL,
  PRIMARY KEY (artist_id)
);

CREATE TABLE stream_history (
  stream_id SERIAL NOT NULL UNIQUE,
  user_id INTEGER NOT NULL,
  track_id INTEGER NOT NULL,
  stream_date TIMESTAMP NOT NULL,
  device_id INTEGER NOT NULL,
  PRIMARY KEY (stream_id)
);

CREATE TABLE track (
  track_id SERIAL NOT NULL UNIQUE,
  album_id INTEGER NOT NULL,
  track_title VARCHAR(255) NOT NULL,
  duration_sec INTEGER NOT NULL CHECK ( duration_sec > 0 ),
  track_number INTEGER NOT NULL CHECK (track_number > 0),
  PRIMARY KEY (track_id)
);

CREATE TABLE user_billing_info (
  user_id INTEGER NOT NULL PRIMARY KEY,
  card_number VARCHAR(50) NOT NULL
);

CREATE TABLE users (
  user_id SERIAL NOT NULL UNIQUE,
  username VARCHAR(255) NOT NULL UNIQUE,
  subscription_type VARCHAR(255) NOT NULL CHECK (subscription_type IN ('Free', 'Premium')),
  city VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL,
  PRIMARY KEY (user_id)
);

CREATE TABLE playlist (
  playlist_id SERIAL NOT NULL UNIQUE,
  user_id INTEGER NOT NULL,
  playlist_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  PRIMARY KEY (playlist_id)
);

CREATE TABLE playlist_tracks (
  playlist_id INTEGER NOT NULL,
  track_id INTEGER NOT NULL,
  PRIMARY KEY (playlist_id, track_id)
);

CREATE TABLE user_liked_tracks (
  user_id INTEGER NOT NULL,
  track_id INTEGER NOT NULL,
  liked_at TIMESTAMP NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, track_id)
);
CREATE TABLE artist_followers (
  user_id INTEGER NOT NULL,
  artist_id INTEGER NOT NULL,
  followed_at TIMESTAMP NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, artist_id)
);

CREATE TABLE user_devices (
  device_id SERIAL NOT NULL UNIQUE,
  user_id INTEGER NOT NULL,
  device_name VARCHAR(255) NOT NULL,
  device_type VARCHAR(50) NOT NULL CHECK (device_type IN ('Mobile', 'Desktop', 'Smart Speaker', 'CarPlay', 'Other')),
  last_active TIMESTAMP NOT NULL DEFAULT now(),
  PRIMARY KEY (device_id)
);

ALTER TABLE album
  ADD CONSTRAINT fk_album_artist
  FOREIGN KEY (artist_id)
  REFERENCES artist (artist_id);

ALTER TABLE user_devices
  ADD CONSTRAINT fk_user_devices_user
  FOREIGN KEY (user_id)
  REFERENCES users (user_id);

ALTER TABLE stream_history
  ADD CONSTRAINT fk_stream_user
  FOREIGN KEY (user_id)
  REFERENCES users (user_id);

ALTER TABLE stream_history
  ADD CONSTRAINT fk_stream_track
  FOREIGN KEY (track_id)
  REFERENCES track (track_id);

ALTER TABLE track
  ADD CONSTRAINT fk_track_album
  FOREIGN KEY (album_id)
  REFERENCES album (album_id);

ALTER TABLE user_billing_info
  ADD CONSTRAINT fk_billing_user
  FOREIGN KEY (user_id)
  REFERENCES users (user_id);

ALTER TABLE playlist
  ADD CONSTRAINT fk_playlist_user
  FOREIGN KEY (user_id)
  REFERENCES users (user_id);

ALTER TABLE playlist_tracks
  ADD CONSTRAINT fk_playlist_tracks_playlist
  FOREIGN KEY (playlist_id)
  REFERENCES playlist (playlist_id);

ALTER TABLE playlist_tracks
  ADD CONSTRAINT fk_playlist_tracks_track
  FOREIGN KEY (track_id)
  REFERENCES track (track_id);

ALTER TABLE user_liked_tracks
  ADD CONSTRAINT fk_user_liked_tracks_user
  FOREIGN KEY (user_id)
  REFERENCES users (user_id);
ALTER TABLE user_liked_tracks
  ADD CONSTRAINT fk_user_liked_tracks_track
  FOREIGN KEY (track_id)
  REFERENCES track (track_id);

ALTER TABLE artist_followers
  ADD CONSTRAINT fk_artist_followers_user
  FOREIGN KEY (user_id)
  REFERENCES users (user_id);
ALTER TABLE artist_followers
  ADD CONSTRAINT fk_artist_followers_artist
  FOREIGN KEY (artist_id)
  REFERENCES artist (artist_id);

ALTER TABLE stream_history
  ADD CONSTRAINT fk_stream_history_device
  FOREIGN KEY (device_id)
  REFERENCES user_devices (device_id);