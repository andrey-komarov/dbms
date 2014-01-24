INSERT INTO artists (name, artistyear) VALUES
       ('Ayreon', 1995),
       ('Metallica', 1981);

INSERT INTO roles (role) VALUES
       ('vocals'),
       ('rhythm guitar'),
       ('lead guitar'),
       ('bass'),
       ('drums');

INSERT INTO persons (first_name, last_name) VALUES
       ('James', 'Hetfield'),
       ('Lars', 'Ulrich'),
       ('Dave', 'Mustaine'),
       ('Kirk', 'Hammett'),
       ('Ron', 'McGovney'),
       ('Cliff', 'Burton'),
       ('Jason', 'Newsfed');
       
SELECT * FROM albums;

SELECT * FROM artists;

SELECT * FROM tracks;

SELECT * FROM artist_plays_track;

SELECT * FROM track_in_album;
