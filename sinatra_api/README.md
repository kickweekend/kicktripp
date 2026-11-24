# kicktripp — Sinatra REST API

API планирования путешествий: те же сущности и основные операции, что в Rails-приложении, но на Sinatra + Sequel + PostgreSQL. Фронтенда нет: запросы отправляются из браузера, Postman или curl, ответы — JSON.

**[Памятка для защиты: команды, создание, изменение и удаление](USAGE.md)**.

## Запуск в настроенном окружении

Из корня репозитория:

```bash
cd sinatra_api
bundle exec rackup -o 127.0.0.1 -p 4567 config.ru
```

Терминал оставьте открытым. Остановка — Ctrl+C. Откройте http://localhost:4567/api/v1/trips. Rails остаётся на порту 3000, Sinatra — на 4567. У них разные базы: изменения в одном приложении не изменяют данные другого.

## Первоначальная настройка / новая копия проекта

Установите Ruby 3.4.13, Bundler и PostgreSQL. Создайте роль и отдельные БД:

```bash
sudo -u postgres createuser --login --no-superuser --no-createdb --no-createrole --pwprompt kicktripp_sinatra
sudo -u postgres createdb -O kicktripp_sinatra kicktripp_sinatra_development
sudo -u postgres createdb -O kicktripp_sinatra kicktripp_sinatra_test
```

В sinatra_api:

```bash
bundle config set --local path vendor/bundle
bundle install
cp -n .env.example .env
```

Заполните пароль роли в PGPASSWORD локального .env. Этот файл не публикуется. Для существующего окружения повторно создавать роль и БД не нужно.

```bash
bundle exec rake db:migrate
APP_ENV=test bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake db:version
bundle exec rake test
```

## Что сделано

- Модели User, Trip, Destination, Place, Activity, Expense, Participation и их связи.
- CRUD, фильтрация, вложенные маршруты и бюджет /api/v1/trips/:id/summary.
- Профили пользователей, заявки участников, read/invited.
- Проверки дат, часовых поясов, валют, сумм и связей внутри поездки.
- Soft delete поездок и активностей, JSON-ошибки 400/404/422.
- Миграции Sequel, rake-задачи, timestamps, datasets, seeds через sequel-seed с историей schema_seeds.

Список маршрутов и примеры — в [памятке](USAGE.md). [Коллекция полного API для Postman](../docs/kicktripp-sinatra-rest.postman_collection.json) создаёт отдельные записи для демонстрации и сохраняет их ID в переменных коллекции. Старая коллекция второй работы остаётся для упражнений с маршрутами.

## Структура

- app.rb, config.ru — загрузка и запуск Sinatra::Application.
- config/database.rb — отдельное подключение PostgreSQL из .env.
- models/ — модели Sequel::Model, ассоциации и валидации.
- db/migrations/ — создание таблиц и отдельная миграция deleted.
- seeds/ — файлы с возрастающими датами: очистка и заполнение связанных таблиц.
- lib/tasks/db.rb — migrate/version/rollback/reset/seed/datasets.
- routes/ — явные GET/POST/PUT/PATCH/DELETE блоки по ресурсам.
- helpers/ — JSON, разрешённые входные поля, поиск записей внутри родителя.
- controllers/errors.rb — обработчики ошибок.
- examples/ — классический и модульный однофайловые примеры из работы №2; не требуют БД.
- test/ — REST-сценарии, ограничения БД, основы маршрутизации и оба примера.

Проверка второго этапа сохранена до изменений: [тег sinatra-basics](https://github.com/kickweekend/kicktripp/tree/sinatra-basics). Теперь основное приложение работает с PostgreSQL, а не с массивом demo-данных.

## Данные и ограничения

Seeds: три пользователя, две поездки, два направления, место, две активности, расход 1000 JPY и три заявки с разными read/invited. Каждый seed-файл применяется один раз; повторный db:seed сохраняет пользовательские изменения. Принудительное пересоздание демонстрационных данных описано отдельно в памятке и удаляет текущие данные Sinatra.

Денежные поля numeric(14,2), суммы в JSON — строки. Валюта расходов совпадает с поездкой; конвертации нет. Даты и время проверяются в IANA-часовом поясе поездки; входное время ISO 8601 обязательно содержит Z или смещение. Сохраняется UTC.

API локальный, без аутентификации и разграничения ролей. Конкурентные изменения разных ресурсов не защищены общей блокировкой поездки — как и в текущем Rails API. Гарантии связей в БД обеспечивают внешние ключи и ограничения. Production-развёртывание и GraphQL не реализованы.

Проверено: 31 тест, 303 утверждения; 28 сценариев коллекции прошли через настоящий HTTP на test-БД.
