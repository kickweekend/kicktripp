# Контракт и ручная проверка API

Базовый адрес: http://127.0.0.1:3000. Тела POST/PUT/PATCH — плоский JSON с Content-Type: application/json. Примеры показывают ожидаемый контракт; идентификаторы выбираются из фактических ответов, а не предполагаются равными 1.

| Ресурс | Маршруты |
|---|---|
| Путешественники | /api/v1/users и /api/v1/users/:id — GET/POST/GET/PUT/PATCH/DELETE |
| Поездки | /api/v1/trips и /api/v1/trips/:id — CRUD |
| Направления | /api/v1/trips/:trip_id/destinations[/:id] — CRUD |
| Места | /api/v1/trips/:trip_id/destinations/:destination_id/places[/:id] — CRUD |
| Активности | /api/v1/trips/:trip_id/activities[/:id] — CRUD; /api/v1/activities[/:id] — чтение |
| Расходы | /api/v1/trips/:trip_id/expenses[/:id] — CRUD |
| Заявки | /api/v1/participations[/:id] — CRUD |
| Заявки пользователя | GET /api/v1/users/:user_id/participations |
| Заявки активности | GET /api/v1/activities/:activity_id/participations; также вложенный маршрут внутри trip |
| Участники | GET /api/v1/activities/:activity_id/users и /api/v1/trips/:trip_id/users |
| Бюджет | GET /api/v1/trips/:id/summary |
| Учебное мягкое удаление | PUT /api/v1/trips/:id/mark_deleted и PUT /api/v1/trips/:trip_id/activities/:id/mark_deleted |

Фильтры: users — name/interests; trips — title/city/user_id/on; activities — title/place/status/on; participations — read/invited. Текстовые фильтры частичные, регистр не учитывается, % и _ воспринимаются буквально. Фильтры объединяются через AND, параметры разделяются &. on — ISO дата YYYY-MM-DD. Ответ списка — массив, пустая выборка — [] с HTTP 200. Сортировка по id по возрастанию.

## Последовательность запросов

В Postman можно повторить те же методы и адреса, выбрать Body → raw → JSON и сохранить запросы в коллекцию kicktripp.

```sh
curl -i http://127.0.0.1:3000/api/v1/users
curl -i 'http://127.0.0.1:3000/api/v1/trips?title=2027&city=Tokyo'
curl -i -X POST http://127.0.0.1:3000/api/v1/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"Demo","email":"demo@example.test","interests":"museums","bio":"Городские путешествия"}'
```

Последний запрос возвращает 201 и объект User с id. Подставьте его как USER_ID:

```sh
curl -i -X POST http://127.0.0.1:3000/api/v1/trips \
  -H 'Content-Type: application/json' \
  -d '{"user_id":USER_ID,"title":"Новая поездка","starts_on":"2027-06-01","ends_on":"2027-06-05","currency":"RUB","budget_amount":"10000.00","time_zone":"Europe/Moscow"}'
```

USER_ID в JSON нужно заменить числом. Далее установите переменные оболочки по реальным ID из ответов:

```sh
trip_id=123
activity_id=456
participation_id=789
curl -i "http://127.0.0.1:3000/api/v1/trips/$trip_id"
curl -i -X PATCH "http://127.0.0.1:3000/api/v1/trips/$trip_id" \
  -H 'Content-Type: application/json' -d '{"description":"Проверка обновления"}'
curl -i -X POST "http://127.0.0.1:3000/api/v1/trips/$trip_id/activities" \
  -H 'Content-Type: application/json' \
  -d '{"title":"Прогулка","starts_at":"2027-06-02T10:00:00+03:00","ends_at":"2027-06-02T12:00:00+03:00"}'
curl -i "http://127.0.0.1:3000/api/v1/trips/$trip_id/activities"
curl -i -X PUT "http://127.0.0.1:3000/api/v1/participations/$participation_id" \
  -H 'Content-Type: application/json' -d '{"read":true,"invited":true}'
curl -i 'http://127.0.0.1:3000/api/v1/participations?read=true&invited=true'
curl -i "http://127.0.0.1:3000/api/v1/trips/$trip_id/summary"
curl -i -X DELETE "http://127.0.0.1:3000/api/v1/trips/$trip_id/activities/$activity_id"
```

Создание заявки: POST /api/v1/participations с {"user_id":USER_ID,"activity_id":ACTIVITY_ID}. Обновление профиля: PUT /users/:id с полем bio.

## Ошибки

```sh
curl -i http://127.0.0.1:3000/api/v1/trips/999999999
curl -i http://127.0.0.1:3000/nonexistent
curl -i -X POST http://127.0.0.1:3000/api/v1/users \
  -H 'Content-Type: application/json' -d '{"name":"Invalid","email":"bad"}'
curl -i -X POST http://127.0.0.1:3000/api/v1/users \
  -H 'Content-Type: application/json' -d '{broken'
```

Ожидаются соответственно 404 {"error":"not_found"}, 404 {"error":"route_not_found"}, 422 {"errors":{...}} и 400 {"error":"bad_request","message":...}. Успешное чтение/обновление — 200, создание — 201, удаление — 204 без тела. В JSON явно перечисляются поля сериализатора; внутренние детали исключений БД не возвращаются.

## Soft delete в консоли

После DELETE запомненной активности: Activity.find(ACTIVITY_ID).deleted должно быть true. Через GET она уже недоступна (404). Для Trip аналогично. Повторный DELETE даёт 404, поскольку обычный API работает только с видимыми записями. Учебный alias PUT mark_deleted выполняет тот же метод.
