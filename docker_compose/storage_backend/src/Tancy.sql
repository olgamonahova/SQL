psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy castings FROM '/data/tancy/castings.csv' DELIMITER ',' CSV HEADER"



bash /home/load_tancy_data.sh



CREATE TABLE castings (
    casting_Id bigint,
    Dancer varchar(40),
    Age int,
    Style varchar(30),
    Passed boolean,
    Season int,
    City varchar(20)
  );

