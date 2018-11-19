SELECT ('ФИО: Монахова Ольга');

---ВАША КОМАНДА СОЗДАНИЯ ТАБЛИЦЫ

--- psql --host $APP_POSTGRES_HOST -U postgres -c 'CREATE TABLE keywords (id bigint,tags text);


--- КОМАНДА ЗАЛИВКИ ДАННЫХ В ТАБЛИЦу

--- psql --host $APP_POSTGRES_HOST -U postgres -c \
--- "\\copy keywords FROM '/data/keywords.csv' DELIMITER ',' CSV HEADER"
--- "\\copy keywords FROM '/data/keywords.csv' DELIMITER ',' CSV HEADER"



-- ЗАПРОС 1 - самые популярные фильмы
  SELECT
        movieid,
        AVG(rating) as avg_rating
    FROM ratings
    GROUP BY movieid
    HAVING COUNT(rating)>50
    ORDER BY AVG(rating) DESC, movieid ASC
    LIMIT 150;


--  ЗАПРОС 2 - надо заджойнить на keywords
WITH top_rated
AS (

---Запрос 1
    SELECT
        movieid,
        AVG(rating) as avg_rating
    FROM ratings
    GROUP BY movieid
    HAVING COUNT(rating)>50
    ORDER BY AVG(rating) DESC, movieid ASC
    LIMIT 150)

---Запрос 2
SELECT r.movieid,k.tags

FROM

    (SELECT * from top_rated) as r
    LEFT JOIN
    (SELECT * from keywords) as k
    ON r.movieid = k.movieid

-- ЗАПРОС 3 - модифицируем ЗАПРОС 2 чтобы сохранить данные в таблицу



WITH top_rated
AS (


    SELECT
        movieid,
        AVG(rating) as avg_rating
    FROM ratings
    GROUP BY movieid
    HAVING COUNT(rating)>50
    ORDER BY AVG(rating) DESC, movieid ASC
    LIMIT 150)


SELECT r.movieid,k.tags
INTO top_rated_tags

FROM

    (SELECT * from top_rated) as r
    LEFT JOIN
    (SELECT * from keywords) as k
    ON r.movieid = k.movieid



--- КОМАНДА ВЫГРУЗКИ ТАБЛИЦЫ В ФАЙЛ
\copy (SELECT * FROM top_keywords) TO '/data/tags.tsv' DELIMITER E'\t';




