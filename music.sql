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
DROP TABLE IF EXISTS track_in_album CASCADE;

DROP FUNCTION IF EXISTS check_new_album_year();
DROP FUNCTION IF EXISTS check_if_track_artist_is_album_artist();
DROP FUNCTION IF EXISTS check_track_has_at_least_one_artist();

/************
 * Сущности *
 ************/

CREATE TABLE persons (
       personid      SERIAL NOT NULL PRIMARY KEY,
       first_name    text NOT NULL,
       last_name     text
);

CREATE TABLE roles (
       roleid      SERIAL NOT NULL PRIMARY KEY,
       role        text NOT NULL,
       UNIQUE(role)
);

CREATE TABLE artists (
       artistid      SERIAL NOT NULL PRIMARY KEY,
       name          text NOT NULL,
       year          int
);

CREATE TABLE albums (
       albumid      SERIAL NOT NULL PRIMARY KEY,
       name         text NOT NULL,
       artistid     integer NOT NULL REFERENCES artists,
       year         int
);

CREATE TABLE tracks (
       trackid     SERIAL PRIMARY KEY,
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
       artistid                 integer NOT NULL REFERENCES artists,
       trackid                  integer NOT NULL REFERENCES tracks,
       UNIQUE(artistid, trackid)
);

CREATE TABLE track_in_album (
       trackid              integer NOT NULL REFERENCES tracks,
       albumid              integer NOT NULL REFERENCES albums
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
       
/************************************
 * У песни хотя бы один исполнитель *
 ************************************/
CREATE FUNCTION check_track_has_at_least_one_artist()
       RETURNS trigger AS
$$
DECLARE
   bad record;
BEGIN
   SELECT NEW.title 
       INTO bad
       FROM artist_plays_track at
       WHERE NEW.trackid = at.trackid;
   IF NOT FOUND THEN
      RAISE EXCEPTION 'Nobody plays <<%>> :(', NEW.title;
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER track_has_at_least_one_artist
       BEFORE INSERT OR UPDATE ON tracks
       FOR EACH ROW 
       EXECUTE PROCEDURE check_track_has_at_least_one_artist();


/**********************************************************
 * Если песня в альбоме, то этот альбом исполняет один из *
 * исполнителей песни                                     *
 **********************************************************/
CREATE FUNCTION check_if_track_artist_is_album_artist()
       RETURNS trigger AS
$$
DECLARE
   bad record;
BEGIN
   SELECT * INTO bad
            FROM track_in_album t NATURAL JOIN albums
            WHERE artistid NOT IN (
                  SELECT artistid
                         FROM artist_plays_track at
                         WHERE t.trackid = at.trackid
            );
   IF FOUND THEN
      RAISE EXCEPTION 'Track''s artist is not in any of albums'' artists';
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER album_released_after_group_establishment_apt
       BEFORE INSERT OR UPDATE ON artist_plays_track
       FOR EACH ROW 
       EXECUTE PROCEDURE check_if_track_artist_is_album_artist();

CREATE TRIGGER album_released_after_group_establishment_tia
       BEFORE INSERT OR UPDATE ON track_in_album
       FOR EACH ROW 
       EXECUTE PROCEDURE check_if_track_artist_is_album_artist();


