/* Глобально - есть таблица исполнителей(artists), альбомов(albums),
 * человеков(persons), ещё чего-нибудь можно
 * 
 * Альбом для какой-то группы в каком-то году
 * 
 */

DROP TABLE IF EXISTS persons;
DROP TABLE IF EXISTS albums CASCADE;
DROP TABLE IF EXISTS artists;
DROP FUNCTION IF EXISTS check_album_year();

CREATE TABLE artists (
       id            SERIAL PRIMARY KEY,
       name          text NOT NULL,
       year          int
);

CREATE TABLE albums (
       id           SERIAL PRIMARY KEY,
       name         text NOT NULL,
       artist       SERIAL NOT NULL REFERENCES artists,
       year         int
);

CREATE OR REPLACE FUNCTION check_new_album_year()
       RETURNS trigger as
$$ 
DECLARE
   bad albums.name%TYPE;
BEGIN
   SELECT NEW.name
       INTO bad
       FROM artists
       WHERE NEW.year < artists.year;
   RAISE NOTICE 'ololo %', bad;
   IF FOUND THEN
      RAISE EXCEPTION 'Bad <<%>>''s year', NEW.name;
   END IF;
   RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER album_released_after_group_establishment
       BEFORE INSERT OR UPDATE ON albums
       FOR EACH ROW 
       EXECUTE PROCEDURE check_new_album_year();

CREATE TABLE persons (
       id            SERIAL PRIMARY KEY,
       firstname     text,
       lastname      text
);

INSERT INTO artists (name, year) VALUES
       ('Ayreon', 1995);

INSERT INTO albums (name, artist, year) 
       SELECT 'The Human Equation', artists.id, 2004
       FROM artists 
       WHERE name = 'Ayreon';


SELECT * FROM albums;

SELECT * FROM artists;

