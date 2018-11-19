#!/bin/sh

# команда для загрузки файла в MONGO
/usr/bin/mongoimport --host $APP_MONGO_HOST --port $APP_MONGO_PORT --db movies --collection tags --file /data/simple_tags.json

#переключаемся на базу
#use db movies

# в файле agg.js три задачи
# - подсчитайте число элементов в созданной коллекции
db.tags.count()

# - подсчитайте число фильмов с конкретным тегом - `woman`
db.tags.find({name: "woman"}).count()


# - используя группировку данных ($groupby) вывести top-3 самых распространённых тегов
db.tags.aggregate(
                     [
                       { $group: { _id: "$name", count_tag: { $sum: 1 } } },
                       { $sort: { count_tag: -1 } },
                       { $limit: 3 }
                     ])

/usr/bin/mongo $APP_MONGOuse _HOST:$APP_MONGO_PORT/movies /home/agg.js