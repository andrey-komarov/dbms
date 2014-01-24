import csv

with open('music-input.csv') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        artist, album, year, title = row
        print ("""BEGIN;

INSERT INTO albums (name, artistid, year)
    SELECT '{album}', artistid, {year}
    FROM artists
    WHERE name = '{artist}'
        AND NOT EXISTS (
            SELECT * FROM albums WHERE name = '{album}'
        );

INSERT INTO tracks (title, year) VALUES
    ('{title}', {year});

INSERT INTO artist_plays_track (artistid, trackid)
    SELECT artistid, trackid
    FROM artists, tracks
    WHERE name = '{artist}' AND title = '{title}';

INSERT INTO track_in_album (trackid, albumid)
    SELECT trackid, albumid
    FROM tracks, albums
    WHERE title = '{title}' AND name = '{album}';

COMMIT;
""".format(**locals()))
