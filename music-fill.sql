BEGIN;

INSERT INTO artists (name, year) VALUES
       ('Ayreon', 1995);

INSERT INTO albums (name, artistid, year) 
       SELECT 'The Human Equation', artists.artistid, 2004
       FROM artists 
       WHERE name = 'Ayreon';

INSERT INTO tracks (title, year) VALUES
       ('Day One: Vigil', 2004);
/*       ('Day Two: Isolation', 2004),
       ('Day Three: Pain', 2004),
       ('Day Four: Mystery', 2004),
       ('Day Five: Voices', 2004),
       ('Day Six: Childhood', 2004),
       ('Day Seven: Hope', 2004),
       ('Day Eight: School', 2004),
       ('Day Nine: Playground', 2004),
       ('Day Ten: Memories', 2004),
       ('Day Eleven: Love', 2004);
       */

INSERT INTO artist_plays_track (artistid, trackid)
       SELECT artistid, trackid
       FROM artists, tracks
       WHERE name = 'Ayreon' AND title = 'Day One: Vigil';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day One: Vigil' AND name = 'The Human Equation';
/*       
INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Two: Isolation' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Three: Pain' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Four: Mystery' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Five: Voices' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Six: Childhood' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Seven: Hope' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Eight: School' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Nine: Playground' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Ten: Memories' AND name = 'The Human Equation';

INSERT INTO track_in_album (trackid, albumid)
       SELECT trackid, albumid
       FROM tracks, albums
       WHERE title = 'Day Eleven: Love' AND name = 'The Human Equation';
*/

COMMIT;

SELECT * FROM albums;

SELECT * FROM artists;

SELECT * FROM tracks;

SELECT * FROM artist_plays_track;

SELECT * FROM track_in_album;
