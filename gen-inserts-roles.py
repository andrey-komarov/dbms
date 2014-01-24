import csv

with open('music-roles.csv') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        fname, lname, artist, role = row
        print ("""BEGIN;
        
INSERT INTO persons (first_name, last_name)
    SELECT '{fname}', '{lname}'
    WHERE NOT EXISTS (
        SELECT * FROM persons
        WHERE first_name = '{fname}' AND last_name='{lname}'
    );

INSERT INTO role_in_group (artistid, personid, roleid)
    SELECT artistid, personid, roleid
    FROM artists, persons, roles
    WHERE artists.name = '{artist}'
          AND persons.first_name = '{fname}'
          AND persons.last_name = '{lname}'
          AND role = '{role}';

COMMIT;
""".format(**locals()))
