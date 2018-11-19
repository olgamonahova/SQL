SELECT ('ФИО: Монахова Ольга');

-- спользуя функцию определения размера таблицы, вывести top-5 самых больших таблиц базы
SELECT table_name, pg_size_pretty(pg_relation_size(table_name))
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema','pg_catalog')
ORDER BY pg_relation_size(table_name) DESC LIMIT 5;


-- предвыборка на меншьее количество записей

DROP TABLE IF EXISTS small_ratings;

SELECT * INTO small_ratings FROM (SELECT * FROM ratings LIMIT 100000) as tmp;


--INSERT INTO small_ratings (SELECT * FROM ratings LIMIT 100000);

--SELECT * FROM small_ratings LIMIT 10;

--\d ratings;

-- array_agg: собрать в массив все фильмы, просмотренные пользователем (без повторов)

--SELECT userID, array_agg(DISTINCT movieId) as user_views FROM ratings GROUP BY userID;



-- таблица user_movies_agg, в которую сохраните результат предыдущего запроса
DROP TABLE IF EXISTS user_movies_agg;


SELECT userID, user_views
INTO public.user_movies_agg
FROM
(SELECT userID, array_agg(DISTINCT movieId) as user_views FROM small_ratings GROUP BY userID)
as tpm;


---SELECT * FROM user_movies_agg LIMIT 3;

-- Используя следующий синтаксис, создайте функцию cross_arr оторая принимает на вход два массива arr1 и arr2.
-- Функциия возвращает массив, который представляет собой пересечение контента из обоих списков.
-- Примечание - по именам к аргументам обращаться не получится, придётся делать через $1 и $2.

CREATE OR REPLACE FUNCTION cross_arr (bigint[], bigint[])
RETURNS bigint[]
language sql
as $FUNCTION$
    SELECT ARRAY(
        SELECT UNNEST($1)
        INTERSECT
        SELECT UNNEST($2)
     );
$FUNCTION$;

-- проба пера
---SELECT * FROM cross_arr(array [1,2,3],array[2,3,4]);

-- Сформируйте запрос следующего вида: достать из таблицы всевозможные наборы u1, r1, u2, r2.
-- u1 и u2 - это id пользователей, r1 и r2 - соответствующие массивы рейтингов
-- ПОДСКАЗКА: используйте CROSS JOIN

--- проба пера



-- создаем вторую таблицу и меняем название столбцов, чтобы избежать одинаковых имен в таблице cross join
--SELECT * INTO public.user_movies_agg2 FROM user_movies_agg;


-- тренировка запроса
--SELECT agg.userId as u1, agg.userId2 as u2, agg.user_views as ar1, agg.user_views2 as ar2, cross_arr(agg.user_views,agg.user_views2) as crossed_arr from
--    (SELECT
--    *
--    from
--    user_movies_agg as T1
--    CROSS JOIN user_movies_agg2 as T2
--    WHERE T1.userid <> T2.userid2) as agg

-- сохранение пар и пересечений в public.common_user_views

DROP TABLE IF EXISTS common_user_views;

SELECT agg.userId as u1, agg.userId2 as u2, agg.user_views as ar1, agg.user_views2 as ar2, cross_arr(agg.user_views,agg.user_views2) as crossed_arr
INTO public.common_user_views
from
    (SELECT
    *
    from
    user_movieSELECT * FROM common_user_views_arr_len;s_agg as T1
    CROSS JOIN user_movies_agg2 as T2
    WHERE T1.userid <> T2.userid2) as agg;


--- сохраним длину массива в отдельный столбец

DROP TABLE IF EXISTS common_user_views_arr_len;

SELECT t.*, array_length(t.crossed_arr,1) as arr_len
INTO common_user_views_arr_len
FROM common_user_views as t;



SELECT * FROM common_user_views_arr_len;

--проверка выборки
SELECT * FROM common_user_views_arr_len WHERE u1 = 94, arr_len <> 0 ORDER BY arr_len DESC;

WITH tmp AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY t.u1 ORDER BY arr_len DESC) as cross_rank
FROM common_user_views_arr_len as t
WHERE arr_len <> 0)

SELECT * INTO tmp2 FROM tmp
WHERE tmp.cross_rank =1;


DROP TABLE IF EXISTS tmp2;

SELECT * FROM tmp2 LIMIT 1;

-- выбор TOP 10 пар с пересечениями

DROP TABLE IF EXISTS top10crossed;

SELECT * INTO top10crossed
FROM tmp2
ORDER BY tmp2.arr_len DESC LIMIT 10;

SELECT u1, arr_len FROM top10crossed;


-- Оберните запрос в CTE и примените к парам <ar1, ar2> функцию CROSS_ARR, которую вы создали
-- вы получите триплеты u1, u2, crossed_arr
-- созхраните результат в таблицу common_user_views
-- DROP TABLE IF EXISTS common_user_views;

--
--WITH user_pairs as (
--  SELECT 1 as u1, 2 as u2, 1 as ar1, 2 as ar2
--) SELECT u1, u2, cross_arr(ar1, ar2) INTO public.common_user_views FROM user_pairs;

-- Оставить как есть - это просто SELECT из таблички common_user_views для контроля результата
--SELECT * FROM common_user_views LIMIT 3;




-- Создайте по аналогии с cross_arr функцию diff_arr, которая вычитает один массив из другого.
-- Подсказка: используйте оператор SQL EXCEPT.
--CREATE OR REPLACE FUNCTION diff_arr (int[], int[]) RETURNS int[] language sql as $FUNCTION$ тело_функции ; $FUNCTION$;


CREATE OR REPLACE FUNCTION diff_arr (bigint[], bigint[])
RETURNS bigint[]
language sql
as $FUNCTION$
    SELECT ARRAY(
        SELECT UNNEST($1)
        EXCEPT
        SELECT UNNEST($2)
     );
$FUNCTION$;db.posts.find({author: ObjectId("5b571bf081d67789509607f1")})

-- создаем рекомендации для просмотра, что видел u2 и не видел u1

DROP TABLE IF EXISTS top10reco;

SELECT u1, diff_arr(ar2,crossed_arr) as diff_arr INTO top10reco
from top10crossed;


SELECT *
FROM
   (SELECT u1, diff_arr FROM top10reco) as T1
   INNER JOIN
   (SELECT * from user_movies_agg) as T2
   ON T1.u1 = T2.userid;


-- Сформируйте рекомендации - для каждой пары посоветуйте для u1 контент, который видел u2, но не видел u1 (в виде массива).
-- Подсказка: нужно заджойнить user_movies_agg и common_user_views и применить вашу функцию diff_arr к соответствующим полям.
-- с векторами фильмов
--SELECT * FROM common_user_views CROSS JOIN user_movies_agg LIMIT 10;


------------------------------------------------------------------------------------------------------------------
