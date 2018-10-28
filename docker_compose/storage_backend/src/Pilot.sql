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
INTO top_rated_tags

FROM

    (SELECT * from top_rated) as r
    LEFT JOIN
    (SELECT * from keywords) as k
    ON r.movieid = k.movieid

\copy (SELECT * FROM top_rated_tags) TO 'data/top_rated_tags.tsv' DELIMETER E'\t';