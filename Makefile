all: music


music:
	psql -f music.sql
	psql -f music-fill.sql
	python gen-inserts.py > music-upfill.sql
	psql -f music-upfill.sql
