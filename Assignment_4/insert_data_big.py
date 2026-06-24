import random
import string
from datetime import datetime, timedelta

import psycopg2
from psycopg2 import Error
from psycopg2.extras import execute_values

# ---------------------------------------------------------------------------
# Database credentials -- put your own here
# ---------------------------------------------------------------------------
HOST = "localhost"
USER = "postgres"
PASSWORD = "password"
DATABASE = "apple_music"
PORT = "5432"
SCHEMA = "streaming"   # schema where the tables live

# ---------------------------------------------------------------------------
# Volume configuration (scaled around 1,000,000 streams / 200,000 users)
# ---------------------------------------------------------------------------
N_ARTIST = 5_000
N_ALBUM = 25_000
N_TRACK = 120_000
N_USERS = 200_000
N_STREAM = 1_000_000
N_PLAYLIST = 50_000          # playlists actually created (subset of users)
PLAYLIST_TRACKS_MIN = 5      # distinct tracks per playlist
PLAYLIST_TRACKS_MAX = 50

BATCH = 10_000  # rows per execute_values call

# ---------------------------------------------------------------------------
# Reference data for realistic values
# ---------------------------------------------------------------------------
GENRES = [
    "Rock", "Pop", "Hip-Hop", "Jazz", "Classical", "Electronic", "Metal",
    "Indie", "Folk", "R&B", "Country", "Reggae", "Blues", "Punk", "Soul",
    "Funk", "House", "Techno", "Ambient", "Alternative",
]

ADJ = ["Midnight", "Electric", "Crimson", "Silent", "Golden", "Broken",
       "Neon", "Velvet", "Wild", "Frozen", "Cosmic", "Hollow", "Lost",
       "Burning", "Silver", "Distant", "Savage", "Crystal"]
NOUN = ["Echo", "Riot", "Pulse", "Waves", "Shadows", "Engine", "Garden",
        "Kings", "Wolves", "Dreams", "Machine", "Empire", "Tigers",
        "Ghosts", "Saints", "Rebels", "Horizon", "Embers"]

UA_CITIES = ["Kyiv", "Lviv", "Kharkiv", "Odesa", "Dnipro", "Zaporizhzhia",
             "Vinnytsia", "Lutsk", "Ternopil", "Rivne"]
PL_CITIES = ["Warsaw", "Krakow", "Lodz", "Wroclaw", "Poznan", "Gdansk",
             "Szczecin", "Lublin", "Katowice", "Bydgoszcz"]
OTHER = {
    "Germany": ["Berlin", "Munich", "Hamburg", "Cologne"],
    "France": ["Paris", "Lyon", "Marseille", "Nice"],
    "USA": ["New York", "Los Angeles", "Chicago", "Austin"],
    "Spain": ["Madrid", "Barcelona", "Valencia", "Seville"],
    "Italy": ["Rome", "Milan", "Naples", "Turin"],
    "UK": ["London", "Manchester", "Leeds", "Bristol"],
}
SUBSCRIPTIONS = ["Free", "Premium"]  # CHECK constraint allows only these

PLAYLIST_ADJ = ["Chill", "Workout", "Focus", "Party", "Late Night", "Road Trip",
                "Morning", "Summer", "Throwback", "Acoustic", "Study", "Deep"]
PLAYLIST_NOUN = ["Vibes", "Mix", "Hits", "Sessions", "Favorites", "Beats",
                 "Jams", "Collection", "Anthems", "Tracks"]

DEVICE_TYPES = ['Mobile', 'Desktop', 'Smart Speaker', 'CarPlay', 'Other']
DEVICE_SUFFIXES = {
    'Mobile': ["'s iPhone", "'s Android", "'s Galaxy"],
    'Desktop': ["'s MacBook", "'s PC", "'s iMac"],
    'Smart Speaker': ["'s HomePod", "'s Echo", "'s Nest"],
    'CarPlay': ["'s Car"],
    'Other': ["'s Watch", "'s TV"]
}

# Maps to hold relationships for foreign keys
USER_SUBSCRIPTION = {}
USER_DEVICES = {}


def create_connection():
    """Create a PostgreSQL database connection."""
    try:
        connection = psycopg2.connect(
            host=HOST, port=PORT, user=USER, password=PASSWORD, dbname=DATABASE
        )
        connection.autocommit = False
        print("Connection to PostgreSQL DB successful")
        return connection
    except Error as e:
        print(f"The error '{e}' occurred")
        return None


def insert_batches(cur, query, rows):
    """Insert a list of tuples using execute_values in chunks of BATCH."""
    for i in range(0, len(rows), BATCH):
        execute_values(cur, query, rows[i:i + BATCH], page_size=BATCH)


def rand_timestamp(start, end):
    """Random datetime between two datetimes."""
    delta = int((end - start).total_seconds())
    return start + timedelta(seconds=random.randint(0, delta))


def rand_card_number():
    """16-digit card number formatted as #### #### #### ####."""
    return " ".join("".join(random.choices(string.digits, k=4)) for _ in range(4))


def generate_artists(cur):
    print(f"Generating {N_ARTIST:,} artists ...")
    rows = []
    for i in range(1, N_ARTIST + 1):
        name = f"{random.choice(ADJ)} {random.choice(NOUN)} {i}"
        rows.append((i, name, random.choice(GENRES)))
    insert_batches(
        cur,
        "INSERT INTO artist (artist_id, artist_name, genre) VALUES %s",
        rows,
    )


def generate_albums(cur):
    print(f"Generating {N_ALBUM:,} albums ...")
    start = datetime(1980, 1, 1)
    end = datetime(2024, 12, 31)
    rows = []
    for i in range(1, N_ALBUM + 1):
        artist_id = random.randint(1, N_ARTIST)
        rel = rand_timestamp(start, end).date()
        rows.append((i, artist_id, f"Album {i}", rel.isoformat()))
    insert_batches(
        cur,
        "INSERT INTO album (album_id, artist_id, album_title, release_date) VALUES %s",
        rows,
    )


def generate_tracks(cur):
    print(f"Generating {N_TRACK:,} tracks ...")
    track_no = {}  # album_id -> running track number
    rows = []
    for tid in range(1, N_TRACK + 1):
        album_id = random.randint(1, N_ALBUM)
        track_no[album_id] = track_no.get(album_id, 0) + 1
        title = f"Track {track_no[album_id]} (A{album_id})"
        duration = random.randint(120, 600)
        rows.append((tid, album_id, title, duration, track_no[album_id]))
        if len(rows) >= BATCH:
            insert_batches(
                cur,
                "INSERT INTO track (track_id, album_id, track_title, duration_sec, track_number) VALUES %s",
                rows,
            )
            rows = []
    if rows:
        insert_batches(
            cur,
            "INSERT INTO track (track_id, album_id, track_title, duration_sec, track_number) VALUES %s",
            rows,
        )


def generate_users(cur):
    print(f"Generating {N_USERS:,} users ...")
    rows = []
    for uid in range(1, N_USERS + 1):
        r = random.random()
        if r < 0.20:
            country, city = "Ukraine", random.choice(UA_CITIES)
        elif r < 0.40:
            country, city = "Poland", random.choice(PL_CITIES)
        else:
            country = random.choice(list(OTHER.keys()))
            city = random.choice(OTHER[country])
        username = f"user_{uid}"  # unique by construction
        sub = random.choice(SUBSCRIPTIONS)
        USER_SUBSCRIPTION[uid] = sub
        rows.append((uid, username, sub, city, country))
        if len(rows) >= BATCH:
            insert_batches(
                cur,
                "INSERT INTO users (user_id, username, subscription_type, city, country) VALUES %s",
                rows,
            )
            rows = []
    if rows:
        insert_batches(
            cur,
            "INSERT INTO users (user_id, username, subscription_type, city, country) VALUES %s",
            rows,
        )


def generate_billing(cur):
    """One billing row per Premium user only."""
    premium = [uid for uid, sub in USER_SUBSCRIPTION.items() if sub == "Premium"]
    print(f"Generating {len(premium):,} billing rows (Premium users only) ...")
    rows = []
    for uid in premium:
        rows.append((uid, rand_card_number()))
        if len(rows) >= BATCH:
            insert_batches(
                cur,
                "INSERT INTO user_billing_info (user_id, card_number) VALUES %s",
                rows,
            )
            rows = []
    if rows:
        insert_batches(
            cur,
            "INSERT INTO user_billing_info (user_id, card_number) VALUES %s",
            rows,
        )


def generate_devices(cur):
    print("Generating user devices ...")
    rows = []
    device_id = 1
    for uid in range(1, N_USERS + 1):
        num_devices = random.randint(1, 3)
        USER_DEVICES[uid] = []
        for _ in range(num_devices):
            dtype = random.choices(DEVICE_TYPES, weights=[60, 20, 10, 5, 5])[0]
            dname = f"User {uid}{random.choice(DEVICE_SUFFIXES[dtype])}"
            ts = rand_timestamp(datetime(2023, 1, 1), datetime(2024, 12, 31, 23, 59, 59))
            rows.append((device_id, uid, dname, dtype, ts.strftime("%Y-%m-%d %H:%M:%S")))
            USER_DEVICES[uid].append(device_id)
            device_id += 1
            if len(rows) >= BATCH:
                insert_batches(
                    cur,
                    "INSERT INTO user_devices (device_id, user_id, device_name, device_type, last_active) VALUES %s",
                    rows,
                )
                rows = []
    if rows:
        insert_batches(
            cur,
            "INSERT INTO user_devices (device_id, user_id, device_name, device_type, last_active) VALUES %s",
            rows,
        )


def generate_streams(cur):
    print(f"Generating {N_STREAM:,} streams ... (this is the big one)")
    start = datetime(2023, 1, 1)
    end = datetime(2024, 12, 31, 23, 59, 59)
    rows = []
    inserted = 0
    for sid in range(1, N_STREAM + 1):
        user_id = random.randint(1, N_USERS)
        track_id = random.randint(1, N_TRACK)
        # pick a random device for this user
        device_id = random.choice(USER_DEVICES[user_id])
        ts = rand_timestamp(start, end)
        rows.append((sid, user_id, track_id, ts.strftime("%Y-%m-%d %H:%M:%S"), device_id))
        if len(rows) >= BATCH:
            insert_batches(
                cur,
                "INSERT INTO stream_history (stream_id, user_id, track_id, stream_date, device_id) VALUES %s",
                rows,
            )
            inserted += len(rows)
            rows = []
            print(f"  ... {inserted:,}/{N_STREAM:,} streams inserted")
    if rows:
        insert_batches(
            cur,
            "INSERT INTO stream_history (stream_id, user_id, track_id, stream_date, device_id) VALUES %s",
            rows,
        )


def generate_playlists(cur):
    """Create N_PLAYLIST playlists owned by random users."""
    print(f"Generating {N_PLAYLIST:,} playlists ...")
    start = datetime(2023, 1, 1)
    end = datetime(2024, 12, 31, 23, 59, 59)
    rows = []
    for pid in range(1, N_PLAYLIST + 1):
        user_id = random.randint(1, N_USERS)
        name = f"{random.choice(PLAYLIST_ADJ)} {random.choice(PLAYLIST_NOUN)}"
        ts = rand_timestamp(start, end)
        rows.append((pid, user_id, name, ts.strftime("%Y-%m-%d %H:%M:%S")))
        if len(rows) >= BATCH:
            insert_batches(
                cur,
                "INSERT INTO playlist (playlist_id, user_id, playlist_name, created_at) VALUES %s",
                rows,
            )
            rows = []
    if rows:
        insert_batches(
            cur,
            "INSERT INTO playlist (playlist_id, user_id, playlist_name, created_at) VALUES %s",
            rows,
        )


def generate_playlist_tracks(cur):
    """5-50 distinct tracks per playlist (composite PK -> no duplicates)."""
    print("Generating playlist_tracks (5-50 distinct tracks per playlist) ...")
    rows = []
    inserted = 0
    for pid in range(1, N_PLAYLIST + 1):
        cnt = random.randint(PLAYLIST_TRACKS_MIN, PLAYLIST_TRACKS_MAX)
        track_ids = random.sample(range(1, N_TRACK + 1), cnt)
        for tid in track_ids:
            rows.append((pid, tid))
        if len(rows) >= BATCH:
            insert_batches(
                cur,
                "INSERT INTO playlist_tracks (playlist_id, track_id) VALUES %s",
                rows,
            )
            inserted += len(rows)
            rows = []
            print(f"  ... {inserted:,} playlist_tracks inserted")
    if rows:
        insert_batches(
            cur,
            "INSERT INTO playlist_tracks (playlist_id, track_id) VALUES %s",
            rows,
        )


def generate_liked_tracks(cur):
    print("Generating user_liked_tracks ...")
    rows = []
    inserted = 0
    start = datetime(2023, 1, 1)
    end = datetime(2024, 12, 31, 23, 59, 59)
    for uid in range(1, N_USERS + 1):
        if random.random() < 0.3:
            num_likes = random.randint(1, 15)
            liked_tracks = random.sample(range(1, N_TRACK + 1), num_likes)
            for tid in liked_tracks:
                ts = rand_timestamp(start, end)
                rows.append((uid, tid, ts.strftime("%Y-%m-%d %H:%M:%S")))
            if len(rows) >= BATCH:
                insert_batches(
                    cur,
                    "INSERT INTO user_liked_tracks (user_id, track_id, liked_at) VALUES %s",
                    rows,
                )
                inserted += len(rows)
                rows = []
    if rows:
        insert_batches(
            cur,
            "INSERT INTO user_liked_tracks (user_id, track_id, liked_at) VALUES %s",
            rows,
        )


def generate_artist_followers(cur):
    print("Generating artist_followers ...")
    rows = []
    inserted = 0
    start = datetime(2023, 1, 1)
    end = datetime(2024, 12, 31, 23, 59, 59)
    for uid in range(1, N_USERS + 1):
        if random.random() < 0.4:
            num_follows = random.randint(1, 10)
            follows = random.sample(range(1, N_ARTIST + 1), num_follows)
            for aid in follows:
                ts = rand_timestamp(start, end)
                rows.append((uid, aid, ts.strftime("%Y-%m-%d %H:%M:%S")))
            if len(rows) >= BATCH:
                insert_batches(
                    cur,
                    "INSERT INTO artist_followers (user_id, artist_id, followed_at) VALUES %s",
                    rows,
                )
                inserted += len(rows)
                rows = []
    if rows:
        insert_batches(
            cur,
            "INSERT INTO artist_followers (user_id, artist_id, followed_at) VALUES %s",
            rows,
        )


def reset_sequences(cur):
    """Keep SERIAL sequences in sync with the explicit ids we inserted."""
    print("Resetting SERIAL sequences ...")
    for table, col in [
        ("artist", "artist_id"),
        ("album", "album_id"),
        ("track", "track_id"),
        ("users", "user_id"),
        ("stream_history", "stream_id"),
        ("playlist", "playlist_id"),
        ("user_devices", "device_id"),
    ]:
        cur.execute(
            f"SELECT setval(pg_get_serial_sequence('{SCHEMA}.{table}', '{col}'), "
            f"(SELECT COALESCE(MAX({col}), 1) FROM {table}))"
        )


def insert_data():
    connection = create_connection()
    if connection is None:
        return
    try:
        with connection.cursor() as cur:
            # Make sure we operate inside the schema that holds the tables
            cur.execute(f"SET search_path TO {SCHEMA}, public")

            # Disable FK checks + speed up the bulk load for this session
            cur.execute("SET session_replication_role = 'replica'")

            generate_artists(cur)
            generate_albums(cur)
            generate_tracks(cur)
            generate_users(cur)
            generate_billing(cur)
            generate_devices(cur)          # New: Devices
            generate_streams(cur)          # Modified: Now uses devices
            generate_playlists(cur)
            generate_playlist_tracks(cur)
            generate_liked_tracks(cur)     # New: Likes
            generate_artist_followers(cur) # New: Followers
            reset_sequences(cur)

            cur.execute("SET session_replication_role = 'origin'")
        connection.commit()
        print("All data inserted successfully")
    except Error as e:
        connection.rollback()
        print(f"The error '{e}' occurred")
    finally:
        connection.close()


if __name__ == "__main__":
    insert_data()
