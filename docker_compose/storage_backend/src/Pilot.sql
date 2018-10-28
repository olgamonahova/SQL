
---Простой пример - функция ROW_NUMBER(). Эта функция нумерует строки внутри окна.
---Пронумеруем контент для каждого пользователя в порядке убывания рейтингов.


SELECT
  userId, movieId, rating,
  ROW_NUMBER() OVER (PARTITION BY userId ORDER BY rating DESC) as movie_rank
FROM (
    SELECT DISTINCT
        userId, movieId, rating
    FROM ratings
    WHERE userId <>1 LIMIT 1000
) as sample
ORDER BY
    userId,
    rating DESC,
    movie_rank
LIMIT 20;
