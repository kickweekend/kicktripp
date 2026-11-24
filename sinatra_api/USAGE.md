# Использование Sinatra API

## 1. Команды: как проект настроен и запускается

Рабочий каталог — sinatra_api. Пароль уже хранится локально в .env; показывать его в демонстрации не нужно.

```bash
# Установка зависимостей (не требуется перед каждым запуском)
bundle config set --local path vendor/bundle
bundle install

# Создание/обновление таблиц
bundle exec rake db:migrate
APP_ENV=test bundle exec rake db:migrate

# Начальные данные: файлы применяются один раз
bundle exec rake db:seed

# Версия миграций, сейчас 2
bundle exec rake db:version

# Примеры dataset, проекции, сортировки, фильтра и связей
bundle exec rake db:datasets

# Проверки
bundle exec rake test

# Запуск (терминал оставить открытым)
bundle exec rackup -o 127.0.0.1 -p 4567 config.ru
```

Для обычного запуска нужна только последняя команда. Для остановки — Ctrl+C. PostgreSQL должен быть запущен отдельно.

## 2. Прочитать данные — GET

Открой в браузере или Postman:

| Адрес после http://localhost:4567 | Результат |
|---|---|
| / | Название сервиса, storage=postgresql |
| /api/v1/users | Пользователи |
| /api/v1/trips | Поездки, в ответе видны ID |
| /api/v1/trips?title=2027&city=Tokyo | Фильтры по названию и городу |
| /api/v1/activities?title=музея | Поиск активностей |
| /api/v1/participations?read=true&invited=true | Рассмотренные заявки с приглашением |

В адресах ниже используй реальные ID из ответов. Например, для trip_id=1:

- /api/v1/trips/1 — поездка;
- /api/v1/trips/1/destinations — направления;
- /api/v1/trips/1/activities — активности;
- /api/v1/trips/1/expenses — расходы;
- /api/v1/trips/1/summary — бюджет;
- /api/v1/trips/1/users — пользователи, подавшие заявки на активности поездки.

Обычный успешный GET возвращает 200. Пустой список — [] с 200, отсутствующая запись — 404.

## 3. Добавить запись — POST

В Postman выбери метод **POST**, адрес **http://localhost:4567/api/v1/users**, затем **Body → raw → JSON**:

```json
{"name":"Demo","email":"demo-defense@example.test","interests":"museums","bio":"Люблю путешествия"}
```

Нажми Send. Ответ — **201 Created**, в нём id нового пользователя. При повторном создании с тем же email будет 422: email уникален. Можно изменить email или удалить этого пользователя, если у него нет связей.

Чтобы создать поездку, POST /api/v1/trips:

```json
{"user_id":1,"title":"Поездка для демонстрации","starts_on":"2027-06-01","ends_on":"2027-06-05","budget_amount":"15000.00","currency":"RUB","time_zone":"Europe/Moscow"}
```

Подставь user_id из списка пользователей. Запомни id созданной поездки. В примерах далее ID — число из ответа, не буквальное слово.

Те же запросы через терминал (сервер работает в другом терминале):

```bash
curl -i http://localhost:4567/api/v1/trips
curl -i -X POST http://localhost:4567/api/v1/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"Demo","email":"another-demo@example.test"}'
```

## 4. Изменить запись — PUT или PATCH

В Postman: **PUT http://localhost:4567/api/v1/trips/ID**, Body → raw → JSON:

```json
{"title":"Название изменено в демонстрации","description":"Проверка обновления"}
```

Ответ — 200 и обновлённый объект. Повтори GET по тому же адресу: изменение сохранено в БД. PATCH тоже поддерживается. В этом API оба метода обновляют переданные поля.

Через терминал, задав реальный ID:

```bash
trip_id=123
curl -i -X PATCH "http://localhost:4567/api/v1/trips/$trip_id" \
  -H 'Content-Type: application/json' -d '{"title":"Новое название"}'
```

Профиль меняется через PUT /api/v1/users/ID с полями bio/interests. Заявка — через PUT /api/v1/participations/ID с {"read":true,"invited":true}.

## 5. Удалить — DELETE

**DELETE http://localhost:4567/api/v1/trips/ID** — тела запроса не нужно. Ответ **204 No Content**, пустое тело нормально. Повторный GET вернёт 404, а список поездок больше не показывает эту запись.

Поездки и активности удаляются **мягко**: в БД остаётся строка с deleted=true. Скрытая поездка скрывает свои вложенные ресурсы. Расходы сохраняются в бюджете при удалении активности.

Expense и Participation удаляются физически. User, Destination и Place можно удалить физически только при отсутствии зависимых записей; иначе 422. Например, пользователь, владеющий даже мягко удалённой поездкой, не удаляется — внешний ключ сохраняется.

Показать это через curl:

```bash
curl -i -X DELETE "http://localhost:4567/api/v1/trips/$trip_id"
curl -i "http://localhost:4567/api/v1/trips/$trip_id"
```

Для удаления обычного пользователя без поездок/заявок: DELETE /api/v1/users/ID. После удаления он действительно отсутствует в БД.

## 6. Как добавить связанные данные

Везде POST, Body → raw → JSON. Сначала создай родителя, возьми его ID и используй в следующем адресе.

| Что | Адрес после /api/v1 | Пример тела |
|---|---|---|
| Направление | /trips/TRIP_ID/destinations | {"country":"Russia","city":"Kazan","arrival_on":"2027-06-01","departure_on":"2027-06-05"} |
| Место | /trips/TRIP_ID/destinations/DESTINATION_ID/places | {"name":"Кремль","category":"sight"} |
| Активность | /trips/TRIP_ID/activities | {"title":"Прогулка","starts_at":"2027-06-02T10:00:00+03:00","ends_at":"2027-06-02T12:00:00+03:00","place_id":PLACE_ID} |
| Расход | /trips/TRIP_ID/expenses | {"title":"Билет","category":"tickets","amount":"500.00","currency":"RUB","spent_on":"2027-06-02","activity_id":ACTIVITY_ID} |
| Заявка участника | /participations | {"user_id":USER_ID,"activity_id":ACTIVITY_ID} |

Слова TRIP_ID и остальные нужно заменить числами. Поля place_id и activity_id у расхода необязательны. Даты должны входить в поездку, валюта расхода должна совпадать с валютой поездки, место и активность — принадлежать этой же поездке.

Для каждого ресурса работают GET списка, GET /ID, PUT/PATCH /ID, DELETE /ID. У /api/v1/activities вне поездки доступны только чтение и фильтры. Заявки пользователя: /users/ID/participations; заявки активности: /activities/ID/participations; участники: /activities/ID/users.

## 7. Как показать ошибки

- GET /api/v1/trips/999999999 → 404.
- POST /api/v1/users с {"name":"Bad","email":"bad"} → 422.
- POST расхода с amount=-1 или другой currency → 422.
- Неверный JSON, например {broken → 400.
- Активность без смещения часового пояса в starts_at/ends_at → 400.
- Место из чужой поездки в активности → 422; чужой ID во вложенном URL → 404.

Так можно показать, что приложение проверяет данные, а не просто записывает всё подряд.

## 8. Консоль Sequel и подтверждение мягкого удаления

В другом терминале, из sinatra_api:

```bash
bundle exec ruby scripts/console.rb
```

В консоли:

```ruby
DB[:trips].select(:id, :title, :deleted).order(:id).all
DB[:trips].where(deleted: true).all
Kicktripp::Trip.visible.by_title("2027").all.map(&:to_api)
Kicktripp::Trip.first.activities_dataset.all
DB[:schema_info].all
DB[:schema_seeds].all
```

У мягко удалённой записи deleted=true, хотя GET уже возвращает 404. Физическое удаление можно проверить DB[:users].where(id: ЧИСЛО).first — вернёт nil. Выход из консоли — exit.

## 9. Откат и пересоздание (удаляют данные)

Не нужны перед обычным запуском. Для демонстрации используй **только тестовую БД**, не development с сохранёнными записями:

```bash
APP_ENV=test ALLOW_DESTRUCTIVE=1 bundle exec rake 'db:rollback[1]'
APP_ENV=test bundle exec rake db:migrate
APP_ENV=test ALLOW_DESTRUCTIVE=1 bundle exec rake db:reset
```

rollback[1] откатывает только вторую миграцию (deleted). reset пересоздаёт все таблицы. После сброса demo-данные можно заново загрузить db:seed с нужным APP_ENV. Production этим задачам запрещён.

## 10. Что показать в коде

- routes/03_trips.rb — GET/POST/PUT/PATCH/DELETE.
- models/trip.rb — Sequel::Model, связи, фильтры и проверки.
- lib/model_support.rb — timestamps и JSON-поля, метод mark_deleted.
- config/database.rb — подключение из переменных окружения; .env не открывать на проекторе.
- db/migrations/ — таблицы и отдельное добавление deleted.
- seeds/ и lib/tasks/db.rb — начальные данные и команды Rake.

До добавления БД было сохранено состояние второй работы: [sinatra-basics на GitHub](https://github.com/kickweekend/kicktripp/tree/sinatra-basics). GraphQL не добавлялся. Оба приложения локальные, без авторизации пользователей и ролей администратора.

## 11. Коллекция Postman: что это и как импортировать

Коллекция — папка сохранённых запросов: HTTP-методы, адреса, заголовки и JSON-тела. Поэтому не нужно каждый раз вводить запрос вручную. Она не запускает сервер — Sinatra нужно запустить отдельно.

Наш файл: docs/kicktripp-sinatra-rest.postman_collection.json. Он содержит 28 последовательных шагов: создать пользователя/поездку/связанные записи, прочитать, изменить, проверить ошибки и удалить. ID сохраняются автоматически в переменных коллекции. Значение {{trip_id}} в адресе — подстановка ID, а не текст для ручной замены.

1. Запусти Sinatra на порту 4567.
2. Открой Postman и свой workspace.
3. Нажми Import; в новых версиях кнопка может называться Use resources or import → Import.
4. Выбери JSON-файл коллекции или перетащи его в окно импорта.
5. После импорта открой слева коллекцию «kicktripp Sinatra — полный REST API».
6. Открывай запросы с 01 по 28, нажимай Send и смотри статус и Body. Для защиты удобнее выполнять по одному.

Для импорта выберите docs/kicktripp-sinatra-rest.postman_collection.json из этого репозитория.

В переменных коллекции base_url уже задан как http://localhost:4567. Для этой коллекции пароль БД не нужен: к PostgreSQL подключается само приложение через локальный .env. Не импортируй .env вместо коллекции.

Запросы 03–10 создают собственные записи. Запросы 21–28 показывают удаление, поэтому выполняются после создания. HTTP 404 и 422 в именах последних запросов — ожидаемые результаты демонстрации, а не поломка сервера. Чтобы повторить весь сценарий, начни заново с 01; адреса email создаются уникальными. Ранние demo-записи seeds сценарий не удаляет.

Методы, адреса и тела всех 28 запросов проверены автоматически через реальный HTTP на тестовой БД; интерфейс Postman вручную агентом не запускался.

[Официальная инструкция импорта Postman](https://learning.postman.com/docs/getting-started/importing-and-exporting/importing-data).
