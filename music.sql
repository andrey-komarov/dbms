/* Глобально - есть таблица исполнителей(artists), альбомов(albums),
 * человеков(persons), ещё чего-нибудь можно
 * 
 * Альбом для какой-то группы в каком-то году
 * 
 */

DROP TABLE IF EXISTS tracks CASCADE;
DROP TABLE IF EXISTS albums CASCADE;
DROP TABLE IF EXISTS artists CASCADE;
DROP TABLE IF EXISTS persons CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

DROP TABLE IF EXISTS covers CASCADE;
DROP TABLE IF EXISTS artist_plays_track CASCADE;
DROP TABLE IF EXISTS artist_plays_album CASCADE;
DROP TABLE IF EXISTS track_in_album CASCADE;

DROP FUNCTION IF EXISTS check_new_album_year();

/************
 * Сущности *
 ************/

CREATE TABLE persons (
       id            SERIAL NOT NULL PRIMARY KEY,
       first_name    text NOT NULL,
       last_name     text
);

CREATE TABLE roles (
       id          SERIAL NOT NULL PRIMARY KEY,
       role        text NOT NULL,
       UNIQUE(role)
);

CREATE TABLE artists (
       id            SERIAL NOT NULL PRIMARY KEY,
       name          text NOT NULL,
       year          int
);

CREATE TABLE albums (
       id           SERIAL NOT NULL PRIMARY KEY,
       name         text NOT NULL,
       artist       integer NOT NULL REFERENCES artists,
       year         int
);

CREATE TABLE tracks (
       id          SERIAL PRIMARY KEY,
       title       text NOT NULL,       
       year        int
);

/**********************
 * Сущности кончились *
 **********************/

CREATE TABLE covers (
       original     integer NOT NULL REFERENCES tracks,
       cover        integer NOT NULL REFERENCES tracks,
       UNIQUE(original, cover)
);

CREATE TABLE artist_plays_track (
       artist                   integer NOT NULL REFERENCES artists,
       track                    integer NOT NULL REFERENCES tracks,
       UNIQUE(artist, track)
);

CREATE TABLE artist_plays_album (
       artist                   integer REFERENCES artists,
       album                    integer REFERENCES albums,
       UNIQUE(artist, album)
);

CREATE TABLE track_in_album (
       track                integer NOT NULL REFERENCES tracks,
       album                integer NOT NULL REFERENCES albums
);

/**********************
 * Таблички кончились *
 **********************/

/*********************************************************
 * Год выпуска альбома не больше года образования группы *
 *********************************************************/
CREATE FUNCTION check_new_album_year()
       RETURNS trigger AS
$$ 
DECLARE
   bad albums.name%TYPE;
BEGIN
   SELECT NEW.name
       INTO bad
       FROM artists
       WHERE NEW.year < artists.year;
   IF FOUND THEN
      RAISE EXCEPTION 'Bad <<%>>''s year', NEW.name;
   END IF;
   RETURN NEW;
END; 
$$ LANGUAGE plpgsql;

CREATE TRIGGER album_released_after_group_establishment
       BEFORE INSERT OR UPDATE ON albums
       FOR EACH ROW 
       EXECUTE PROCEDURE check_new_album_year();

/**********************************************************
 * Если песня в альбоме, то этот альбом исполняет один из *
 * исполнителей песни                                     *
 **********************************************************/
/* CREATE FUNCTION check_if_track_artist_is_album_artist()
       RETURNS trigger AS
$$
DECLARE
   bad record;
BEGIN
   SELECT * INTO bad
            FROM tracks as t,
                                  
            WHERE EXISTS (
                  SELECT 
   FOR album IN 
       SELECT albums.id
              FROM albums
              WHERE albums.id = NEW.id
   SELECT albums.id
          INTO album_id
          FROM albums
          WHERE NEW.
END;
$$ LANGUAGE plpgsql;
*/

INSERT INTO artists (name, year) VALUES
       ('Ayreon', 1995);

INSERT INTO albums (name, artist, year) 
       SELECT 'The Human Equation', artists.id, 2004
       FROM artists 
       WHERE name = 'Ayreon';

SELECT * FROM albums;

SELECT * FROM artists;

