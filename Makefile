all: music


music:
	psql -f music.sql
	psql -f music-fill.sql
	python gen-inserts.py > music-tracks.sql
	psql -f music-tracks.sql
	python gen-inserts-roles.py > music-roles.sql
	psql -f music-roles.sql
