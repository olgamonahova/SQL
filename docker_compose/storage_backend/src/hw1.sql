SELECT ('ФИО: Монахова Ольга');
-- 1.1 SELECT , LIMIT - выбрать 10 записей из таблицы rating
--- Для всех дальнейших запросов выбирать по 10 записей 
SELECT *    
FROM ratings
LIMIT 10;

-- 1.2 WHERE, LIKE - выбрать из таблицы links всё записи, у которых imdbid оканчивается на "42", а поле movieid между 100 и 1000
SELECT *
FROM links
WHERE
    links.imdbid like '%42' AND links.movieid>=99 AND links.movieid<=1001
LIMIT 10;


