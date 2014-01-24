
BEGIN;

INSERT INTO artists (name, artistyear) VALUES
       ('Depeche Mode', NULL);

INSERT INTO albums (name, artistid, albumyear) VALUES
       ('Violator', currval('artists_artistid_seq'), 1990);

INSERT INTO tracks (title, trackyear) VALUES
       ('Personal Jesus', 1990);

INSERT INTO artist_plays_track (artistid, trackid) VALUES
       (currval('artists_artistid_seq'), 
        currval('tracks_trackid_seq'));

INSERT INTO track_in_album (trackid, albumid) VALUES
       (currval('tracks_trackid_seq'), currval('albums_albumid_seq'));

COMMIT;



BEGIN;

INSERT INTO artists (name, artistyear) VALUES
       ('Marylin Manson', NULL);

INSERT INTO tracks (title, trackyear) VALUES
       ('Personal Jesus', NULL);

INSERT INTO artist_plays_track (artistid, trackid) VALUES
       (currval('artists_artistid_seq'), 
        currval('tracks_trackid_seq'));

COMMIT;



BEGIN;

INSERT INTO covers(original, cover)
       SELECT dm.trackid, mm.trackid
       FROM (tracks NATURAL JOIN artist_plays_track NATURAL JOIN artists) dm,
            (tracks NATURAL JOIN artist_plays_track NATURAL JOIN artists) mm
       WHERE dm.name = 'Depeche Mode'
             AND mm.name = 'Marylin Manson'
             AND dm.title = mm.title
             AND dm.title = 'Personal Jesus';

COMMIT;



BEGIN;

INSERT INTO artists (name, artistyear) VALUES
       ('Richard Cheese', NULL);

INSERT INTO tracks (title, trackyear) VALUES
       ('Personal Jesus', NULL);

INSERT INTO artist_plays_track (artistid, trackid) VALUES
       (currval('artists_artistid_seq'), 
        currval('tracks_trackid_seq'));

COMMIT;



BEGIN;

INSERT INTO covers(original, cover)
       SELECT mm.trackid, rc.trackid
       FROM (tracks NATURAL JOIN artist_plays_track NATURAL JOIN artists) mm,
            (tracks NATURAL JOIN artist_plays_track NATURAL JOIN artists) rc
       WHERE mm.name = 'Marylin Manson'
             AND rc.name = 'Richard Cheese'
             AND rc.title = mm.title
             AND rc.title = 'Personal Jesus';

COMMIT;



BEGIN;

INSERT INTO artists (name) VALUES
       ('Golden Earring'),
       ('Ария');

INSERT INTO tracks(title) VALUES
       ('Going to the Ride'),
       ('Беспечный ангел');

INSERT INTO artist_plays_track (artistid, trackid) VALUES
       (currval('artists_artistid_seq'), currval('tracks_trackid_seq')),
       (currval('artists_artistid_seq') - 1, currval('tracks_trackid_seq') - 1);
       
INSERT INTO covers(original, cover) VALUES
       (currval('tracks_trackid_seq') - 1, currval('tracks_trackid_seq'));

COMMIT;
