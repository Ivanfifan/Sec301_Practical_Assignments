-- ЗАПОВНЕННЯ ВИКОНАВЦІВ
INSERT INTO artist (artist_name, genre) VALUES
('Metallica', 'Thrash Metal'),
('Nine Inch Nails', 'Industrial Rock'),
('Queens of the Stone Age', 'Stoner Rock / Alternative');

-- ЗАПОВНЕННЯ АЛЬБОМІВ
INSERT INTO album (artist_id, album_title, release_date) VALUES
(1, 'Kill ''Em All', '1983-07-25'),
(1, 'Ride the Lightning', '1984-07-27'),
(1, 'Master of Puppets', '1986-03-03'),
(1, '...And Justice for All', '1988-09-07'),
(1, 'Metallica', '1991-08-12'),

(2, 'Pretty Hate Machine', '1989-10-20'),
(2, 'The Downward Spiral', '1994-03-08'),
(2, 'The Fragile', '1999-09-21'),
(2, 'With Teeth', '2005-05-03'),

(3, '...Like Clockwork', '2013-06-03'),
(3, 'Villains', '2017-08-25'),
(3, 'In Times New Roman...', '2023-06-16');

INSERT INTO track (album_id, track_title, duration_sec, track_number) VALUES

(1, 'Hit the Lights', 257, 1),
(1, 'The Four Horsemen', 433, 2),
(1, 'Seek & Destroy', 415, 9),


(2, 'Fight Fire with Fire', 284, 1),
(2, 'Ride the Lightning', 396, 2),
(2, 'For Whom the Bell Tolls', 309, 3),

(3, 'Battery', 312, 1),
(3, 'Master of Puppets', 516, 2),
(3, 'Welcome Home (Sanitarium)', 387, 4),

(4, 'Blackened', 400, 1),
(4, '...And Justice for All', 586, 2),
(4, 'One', 446, 4),

(5, 'Enter Sandman', 331, 1),
(5, 'Sad but True', 324, 2),
(5, 'Nothing Else Matters', 388, 8),

(6, 'Head Like a Hole', 299, 1),
(6, 'Terrible Lie', 278, 2),
(6, 'Down in It', 226, 3),

(7, 'Mr. Self Destruct', 270, 1),
(7, 'Closer', 373, 5),
(7, 'Hurt', 373, 14),

(8, 'Somewhat Damaged', 271, 1),
(8, 'The Day the World Went Away', 273, 2),
(8, 'We''re in This Together', 436, 5),

(9, 'All the Love in the World', 315, 1),
(9, 'The Hand That Feeds', 211, 4),
(9, 'Only', 263, 8),

(10, 'Keep Your Eyes Peeled', 304, 1),
(10, 'I Sat by the Ocean', 235, 2),
(10, 'My God Is the Sun', 235, 6),

(11, 'Feet Don''t Fail Me', 341, 1),
(11, 'The Way You Used to Do', 274, 2),
(11, 'Domesticated Animals', 320, 3),

(12, 'Obscenery', 263, 1),
(12, 'Paper Machete', 202, 2),
(12, 'Emotion Sickness', 271, 4);

-- ЗАПОВНЕННЯ КОРИСТУВАЧІВ
INSERT INTO users (username, subscription_type, city, country) VALUES
('ivan_s', 'Premium', 'Kyiv', 'Ukraine'),
('diana', 'Premium', 'Warsaw', 'Poland'),
('trent_fan99', 'Free', 'Lviv', 'Ukraine'),
('stoner_dude', 'Premium', 'Kyiv', 'Ukraine');

-- ЗАПОВНЕННЯ ІСТОРІЇ СТРІМІНГУ
INSERT INTO stream_history (user_id, track_id, stream_date) VALUES
(1, 8, '2026-06-08 14:15:00'),
(1, 23, '2026-06-08 15:30:22'),
(2, 35, '2026-06-09 08:12:10'),
(2, 36, '2026-06-09 08:16:05'),
(3, 16, '2026-06-09 23:45:00'),
(3, 18, '2026-06-10 00:05:11'),
(4, 29, '2026-06-10 16:20:00'),
(1, 12, '2026-06-10 18:40:00'),
(2, 21, '2026-06-11 09:15:33'),
(4, 32, '2026-06-11 20:00:00');