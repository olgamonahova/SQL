#/bin/sh


psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS  castings"


echo "Загружаем  castings.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE castings (
    casting_Id bigint,
    Dancer varchar(40),
    Age int,
    Style varchar(30),
    Passed boolean,
    Season int,
    City varchar(20)
  );'


psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy castings FROM '/data/tancy/castings.csv' DELIMITER ',' CSV HEADER"
