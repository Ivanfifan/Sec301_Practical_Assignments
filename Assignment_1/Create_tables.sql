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
  PRIMARY KEY (stream_id)
);

CREATE TABLE track (
  track_id SERIAL NOT NULL UNIQUE,
  album_id INTEGER NOT NULL,
  track_title VARCHAR(255) NOT NULL,
  duration_sec INTEGER NOT NULL,
  track_number INTEGER NOT NULL,
  PRIMARY KEY (track_id)
);

CREATE TABLE users (
  user_id SERIAL NOT NULL UNIQUE,
  username VARCHAR(255) NOT NULL UNIQUE,
  subscription_type VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL,
  PRIMARY KEY (user_id)
);

ALTER TABLE album
  ADD CONSTRAINT fk_album_artist
  FOREIGN KEY (artist_id)
  REFERENCES artist (artist_id);

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