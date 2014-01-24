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
DROP TABLE IF EXISTS role_in_group CASCADE;

DROP TABLE IF EXISTS supercovers CASCADE;

DROP FUNCTION IF EXISTS check_new_album_year();
DROP FUNCTION IF EXISTS check_if_track_artist_is_album_artist();
DROP FUNCTION IF EXISTS check_track_has_at_least_one_artist();
DROP FUNCTION IF EXISTS add_to_supercovers();

DROP VIEW IF EXISTS numcovers;
DROP VIEW IF EXISTS numcovers2;

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
       artistyear    int
);

CREATE TABLE albums (
       albumid      SERIAL NOT NULL PRIMARY KEY,
       name         text NOT NULL,
       artistid     integer NOT NULL REFERENCES artists,
       albumyear         int
);

CREATE TABLE tracks (
       trackid     SERIAL PRIMARY KEY,
       title       text NOT NULL,       
       trackyear   int
);

/**********************
 * Сущности кончились *
 **********************/

CREATE TABLE covers (
       original     integer NOT NULL REFERENCES tracks,
       cover        integer NOT NULL REFERENCES tracks PRIMARY KEY,
       UNIQUE(original, cover)
);

CREATE TABLE artist_plays_track (
       artistid                 integer NOT NULL REFERENCES artists,
       trackid                  integer NOT NULL REFERENCES tracks,
       UNIQUE(artistid, trackid)
);

CREATE TABLE track_in_album (
       trackid              integer NOT NULL REFERENCES tracks,
       albumid              integer NOT NULL REFERENCES albums,
       UNIQUE(trackid, albumid)
);

CREATE TABLE role_in_group (
       artistid            integer NOT NULL REFERENCES artists,
       personid            integer NOT NULL REFERENCES persons,
       roleid              integer NOT NULL REFERENCES roles,
       UNIQUE(artistid, personid, roleid)
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
       WHERE NEW.albumyear < artists.artistyear 
             AND NEW.artistid = artists.artistid;
   IF FOUND THEN
      RAISE EXCEPTION 'Bad <<%>>''s year', NEW.name;
   END IF;
   RETURN NEW;
END; 
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER album_released_after_group_establishment
       AFTER INSERT OR UPDATE ON albums
       DEFERRABLE INITIALLY DEFERRED
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

CREATE CONSTRAINT TRIGGER track_has_at_least_one_artist
       AFTER INSERT OR UPDATE ON tracks
       DEFERRABLE INITIALLY DEFERRED
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

CREATE CONSTRAINT TRIGGER album_released_after_group_establishment_apt
       AFTER INSERT OR UPDATE ON artist_plays_track
       DEFERRABLE INITIALLY DEFERRED
       FOR EACH ROW 
       EXECUTE PROCEDURE check_if_track_artist_is_album_artist();

CREATE CONSTRAINT TRIGGER album_released_after_group_establishment_tia
       AFTER INSERT OR UPDATE ON track_in_album
       DEFERRABLE INITIALLY DEFERRED
       FOR EACH ROW 
       EXECUTE PROCEDURE check_if_track_artist_is_album_artist();

/*********************************************************
 * Есть дерево (это не проверено) каверов. Храним корень *
 *********************************************************/

CREATE TABLE supercovers (
       superoriginal           integer REFERENCES tracks NOT NULL,
       trackid                 integer REFERENCES tracks NOT NULL,
       UNIQUE (superoriginal, trackid)
);

CREATE FUNCTION add_to_supercovers()
       RETURNS trigger AS
$$
BEGIN
    IF EXISTS (
       SELECT * FROM supercovers WHERE trackid = NEW.original
    ) THEN
        INSERT INTO supercovers(superoriginal, trackid)
               SELECT superoriginal, NEW.cover
               FROM supercovers s
               WHERE s.trackid = NEW.original;
    ELSE
        INSERT INTO supercovers(superoriginal, trackid) VALUES
               (NEW.original, NEW.cover);        
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fill_supercovers
       AFTER INSERT OR UPDATE ON covers
       FOR EACH ROW
       EXECUTE PROCEDURE add_to_supercovers();


/*********************************************
 * View: сколько у песни каверов в поддереве *
 *********************************************/

CREATE MATERIALIZED VIEW numcovers AS
       SELECT superoriginal AS trackid, count(*) AS cnt
       FROM supercovers
       GROUP BY superoriginal;

CREATE UNIQUE INDEX numcovers_tid ON numcovers (trackid); 

CREATE VIEW numcovers2 AS
       WITH RECURSIVE clcovers(orig, cov) AS (
            SELECT original AS orig, cover AS cov
            FROM covers
       UNION ALL
            SELECT c1.orig, c2.cover
            FROM clcovers c1 INNER JOIN covers c2 ON (cov = original)            
       )
       SELECT orig AS trackid, count(*) AS cnt
       FROM clcovers
       WHERE NOT EXISTS (
             SELECT *
             FROM covers
             WHERE cover = orig
       )
       GROUP BY orig;

