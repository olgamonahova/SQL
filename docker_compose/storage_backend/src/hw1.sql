SELECT ('ФИО: Монахова Ольга');

--- 1.1 SELECT , LIMIT - выбрать 10 записей из таблицы rating
--- Для всех дальнейших запросов выбирать по 10 записей 
SELECT *    
FROM ratings
LIMIT 10;

--- 1.2 WHERE, LIKE - выбрать из таблицы links всё записи, у которых imdbid оканчивается на "42", а поле movieid между 100 и 1000
SELECT *
FROM links
WHERE
    links.imdbid like '%42' AND links.movieid>=99 AND links.movieid<=1001
LIMIT 10;

---2.1 INNER JOIN выбрать из таблицы links все imdb_id, которым ставили рейтинг 5
SELECT links.imdbid
FROM links
INNER JOIN ratings
    ON links.movieid=ratings.movieid
WHERE ratings.rating = 5
LIMIT 10;

--- 3.1 COUNT() Посчитать число фильмов без оценок
SELECT 
   count(links.movieid)
FROM public.links
LEFT JOIN public.ratings
        ON links.movieid=ratings.movieid
WHERE ratings.movieid IS NULL;

--- 3.2 GROUP BY, HAVING вывести top-10 пользователей, у который средний рейтинг выше 3.5
SELECT
    userId,
    AVG(rating) as avg_rating
FROM public.ratings
GROUP BY userId
HAVING AVG(rating) > 3.5
LIMIT 10;

--- 4.1 Подзапросы: достать 10 imbdId из links у которых средний рейтинг больше 3.5. Нужно подсчитать средний рейтинг по все пользователям, которые попали под условие - то есть в ответе должно быть одно число.

SELECT AVG(avg_rating) as avg_rating_from_selected_users

FROM (
SELECT userid, AVG(rating) as avg_rating

FROM        
            (SELECT r.movieid
                FROM ratings AS r
                GROUP BY r.movieid
                HAVING AVG(r.rating)>3.5
                ) AS movie
        
             INNER JOIN 
        
            (SELECT * 
                FROM ratings) AS u
         
             ON movie.movieid= u.movieid

GROUP BY userid
) as tmp_table;

--- 4.2 Common Table Expressions: посчитать средний рейтинг по пользователям, у которых более 10 оценок


WITH tmp_table

AS (
          
          SELECT userid, 
                 COUNT(to_char(to_timestamp(timestamp), 'YYYY/MM/DD')) as num_r,
                 AVG(rating) as avg_rating
                FROM ratings
                GROUP BY userid
                HAVING COUNT(to_char(to_timestamp(timestamp), 'YYYY/MM/DD')) > 10
              
    )        

SELECT AVG(avg_rating) as avg_rating_from_selected_users 
FROM tmp_table; 
