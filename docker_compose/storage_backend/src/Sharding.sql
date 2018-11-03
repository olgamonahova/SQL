--Партиционировать таблицу links на 2 партиции: чётные movieId в одной партиции, нечётные в другой.
--\d links; посмотреть информацию


CREATE TABLE links_parted_2 (
    CHECK ( movieid % 2 = 0 ) --четные
) INHERITS (links);

--правило-триггер для четных

CREATE RULE links_insert_2 AS ON INSERT TO links
WHERE ( movieid % 2 = 0 )
DO INSTEAD INSERT INTO links_parted_2 VALUES ( NEW.* );
--Проверим, как все работает


CREATE TABLE links_parted_1 (
    CHECK ( movieid % 2 <> 0 ) --нечетные
) INHERITS (links);

--правило-триггер для нечетных

CREATE RULE links_insert_1 AS ON INSERT TO links
WHERE ( movieid % 2 <> 0 )
DO INSTEAD INSERT INTO links_parted_1 VALUES ( NEW.* );


INSERT INTO links ( -- добавляем нечетные
    SELECT *
    FROM links
    WHERE movieid % 2 <>0
);

INSERT INTO links ( -- добавляем четные
    SELECT *
    FROM links
    WHERE movieid % 2 =0
);