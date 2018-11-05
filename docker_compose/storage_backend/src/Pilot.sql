CREATE RULE ratings_insert_2 AS ON INSERT TO ratings_parted
WHERE ( userId % 2 = 0 )
DO INSTEAD INSERT INTO ratings_parted_2 VALUES ( NEW.* );

CREATE RULE ratings_insert_3 AS ON INSERT TO ratings_parted
WHERE ( userId % 2 <> 0 )
DO INSTEAD INSERT INTO ratings_parted_3 VALUES ( NEW.* );


INSERT INTO ratings_parted (
    SELECT *
    FROM ratings
    WHERE userid=3
);


INSERT INTO ratings_parted (
    SELECT *
    FROM ratings
    WHERE userid=6
);

-- создаем таблицу, у которой значения являются массивами
CREATE TABLE holiday_picnic (
     holiday varchar(50), -- строковое значение
     sandwich text[], -- массив
     side text[] [], -- многомерный массив
     dessert text ARRAY, -- массив
     beverage text ARRAY[4] -- массив из 4-х элементов
);

-- вставляем значения массивов в таблицу
INSERT INTO holiday_picnic VALUES
     ('Labor Day',
     '{"roast beef","veggie","turkey"}',
     '{
        {"potato salad","green salad"},
        {"chips","crackers"}
     }',
     '{"fruit cocktail","berry pie","ice cream"}',
     '{"soda","juice","beer","water"}'
     );

SELECT sandwich from holiday_picnic;


-- размер таблицы
SELECT pg_relation_size('ratings');


-- таблицы в порядке убывания размера
SELECT table_name, pg_size_pretty(pg_relation_size(table_name))
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema','pg_catalog')
ORDER BY pg_relation_size(table_name) DESC LIMIT 5;