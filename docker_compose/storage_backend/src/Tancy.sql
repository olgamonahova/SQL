
-- данные по проекту Танцы на ТНТ за 2-ой, 3-ий и 4-ый сезоны сезона

-- таблица с кастингами
-- участники приходили с номерами в определенном  - Style, например, вог, хип-хоп, контемп и.т.д.
-- в конце нвыступления наставники оглашали свое решение, проходит участник в следующий этап отбора или нет - Passed
-- инфо об участнике на момент кастинга - Имя Фамилия (иногда ник) и возраст.
-- кастинги проходили в разных городах России, с каждым годом география расширялась которые проходили в разных городах - City.

  CREATE TABLE castings (
    casting_Id bigint,
    Dancer varchar(100),
    Age int,
    Style varchar(50),
    Passed int,
    Season int,
    City varchar(30)
  );


psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy castings FROM '/data/castings.csv' DELIMITER ';' CSV HEADER;


-- после нескольких этапов отбора наставники набирали в свои команды участников,
-- по 2-м и 3-м сезоне наставниками были Мигель и Егор Дружинин, в 4-м - Мигель и Татьяна Денисова

CREATE TABLE teams (
    Dancer_Id bigint,
    Dancer varchar(100),
    Age int,
    City varchar(30),
    Season int,
    Team varchar(30)
  );

psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy teams FROM '/data/teams.csv' DELIMITER ';' CSV HEADER;


-- дальше начинались отчетные концерты, в которых задействованы хореографы и танцроры (Role),
-- в одном номере могло быть несколько танцоров и несколько хореографов, иногда танцоры сами ставили себе хореографию.
-- в концерте номера пронумерованы по порядку, есть дата концерта

CREATE TABLE acts (
    Act_Id bigint,
    Act_in_series int,
    Act_date date,
    Person_Id bigint,
    Role varchar(30)
  );


psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy acts FROM '/data/acts.csv' DELIMITER ';' CSV HEADER;


--таблица acts разделена на 2, отдельно для танцоров и хореографов, которые трудились над номерами

CREATE TABLE acts_d (
    Act_Id bigint,
    Act_in_series int,
    Act_date date,
    Person_Id bigint
  );

CREATE TABLE acts_ch (
    Act_Id bigint,
    Act_in_series int,
    Act_date date,
    Person_Id bigint
  );


psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy acts_d FROM '/data/acts_d.csv' DELIMITER ';' CSV HEADER;
psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy acts_ch FROM '/data/acts_ch.csv' DELIMITER ';' CSV HEADER;


-- список хореографов, которые что-либо ставили. Здесь есть в том числе и участники танцоры.

CREATE TABLE choreographers (
    Choreo_Id bigint,
    Choreographer varchar(100)
  );

psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy choreographers FROM '/data/choreographers.csv' DELIMITER ';' CSV HEADER;


-- список финалистов и итоговых мест
CREATE TABLE finals (
    Finalist_Id bigint,
    Place int,
    Dancer_Id bigint,
    Team varchar(30),
    Dancer varchar(100),
    Season int
  );


psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy finals FROM '/data/finals.csv' DELIMITER ';' CSV HEADER;

-- данные из агентства с рейтингом выпусков, связаны с таблицей Acts по дате.
CREATE TABLE ratings (
    Series bigint,
    Series_date date,
    rating varchar(5),
    Season int
  );

psql --host $APP_POSTGRES_HOST  -U postgres -c "\\copy ratings FROM '/data/ratings.csv' DELIMITER ';' CSV HEADER;

-- волшебное преобразование колонки rating из текста в число с 1 цифрой после запятой
ALTER TABLE ratings ALTER COLUMN rating TYPE numeric(10,1)
USING translate(rating, ',', '.')::numeric;


-- Запрос 1
-- шансы на прохождение кастинга в каждом сезоне

 SELECT
      season,
      avg(passed) as avg_passed
  FROM castings
  GROUP BY season
  ORDER BY AVG(passed) DESC;

-- Запрос 2
-- Топ 5 танцевальных направлений в 3-м сезоне с наибольшим % прохождения кастинга, которые были представлены не менее 10 номерами
WITH season_4

AS (
    SELECT * FROM castings WHERE season=4
)

  SELECT
      style,
      avg(passed) as avg_passed,
      count(style) as num_style
  FROM season_4
  GROUP BY style
  HAVING COUNT(style)>10
  ORDER BY AVG(passed) DESC
  LIMIT 5;

-- Запрос 3
-- ТОП 5 хореографов и количество номеров в порядке убывания, поставленных ими только для финалистов

-- 3.1 выбираем все номера финалистов
SELECT act_id,act_in_series,act_date,person_id INTO tmp1 FROM
    (SELECT dancer_id from finals) as f
    INNER JOIN
    (SELECT act_id,act_in_series,act_date,person_id from acts_d) as a
    ON f.dancer_id = a.person_id
;

--DROP TABLE tmp2;

-- 3.2 связываем с хореогрофами, которые поставили номера
SELECT tmp.act_id, tmp.act_date, tmp.person_id as dancer_id, ch.person_id as choreo_id INTO tmp2 FROM
(SELECT * FROM tmp1) as tmp
INNER JOIN
(SELECT * FROM acts_ch) as ch
ON tmp.act_id = ch.act_id;


-- 3.3 подтягиваем имена хореографов и подсчитваем кол-во поставленных номеров, группируем номера по хореографам
WITH res AS

(
    SELECT tmp.act_id,tmp.dancer_id,tmp.choreo_id,ch.choreographer  FROM
        (SELECT * FROM tmp2) as tmp
        INNER JOIN
        (SELECT * FROM choreographers) as ch
        ON tmp.choreo_id = ch.choreo_id
)
SELECT res.choreographer, count(res.act_id)
FROM res
GROUP BY choreographer
ORDER BY count(act_id) DESC
LIMIT 5
;

-- Запрос 4
-- Список номеров, которые танцоры ставили себе сами в 3-м сезоне


    SELECT * FROM
        (
        SELECT act_id, d.dancer FROM

                (SELECT * FROM acts_d) as ad
                INNER JOIN
                (SELECT dancer_id, dancer FROM teams WHERE season = 3)  as d
                ON ad.person_id = d.dancer_id

        ) as te
        INNER JOIN
        (SELECT * FROM choreographers) as ch
        on te.dancer = ch.choreographer;

-- Запрос 5
-- 3 выпуска с максимальными рейтингоми в каждом из сезонов

WITH tmp AS (

SELECT ratings.*,
  ROW_NUMBER() OVER (PARTITION BY Season ORDER BY rating DESC) as series_rate
FROM ratings
)

SELECT season, series_date, rating FROM tmp WHERE series_rate <=3;

-- Запрос 6
-- Количество номеров, которые были подготовлены несколькими хореографами

SELECT count(*) FROM

    (SELECT act_id
    FROM acts_ch
    GROUP BY act_id
    HAVING count(person_id)>1) as tmp
;


-- Запрос 7
-- Средний возраст участников в командах в 3-м сезоне

SELECT team, avg(age)
FROM teams
GROUP BY  team
ORDER BY avg(age) ASC
LIMIT 3;

-- Запрос 8
-- Средний возраст пришедших на кастинг участников
SELECT season, avg(age)
FROM castings
GROUP BY season
ORDER BY season ASC;

-- 9 самых юных участников кастинга
SELECT dancer,age FROM castings ORDER BY age ASC limit 10;

-- 10. top 5 самых популярных и top 5 самых редких стилей, с которыми приходили на кастинги

SELECT * FROM (
    (SELECT castings.style, count(style) as num FROM castings
    GROUP BY castings.style
    HAVING count(style) > 0
    ORDER BY count(style) ASC
    LIMIT 10)

  UNION

    (SELECT castings.style, count(style) as num FROM castings
    GROUP BY castings.style
    HAVING count(style) > 0
    ORDER BY count(style) DESC
    LIMIT 10)
) as tmp
ORDER BY num DESC;