# kicktripp

REST API для планирования путешествий на Ruby on Rails и PostgreSQL. Сервис хранит поездки, направления, места, активности, расходы и заявки участников. Возвращает JSON; пользовательского интерфейса нет.

## Возможности

- Создание, чтение, изменение и удаление записей.
- Фильтрация поездок по названию и городу, активностей по названию, месту, статусу и дате.
- Профили путешественников и заявки на участие с признаками read/invited.
- Вложенные ресурсы и проверка связей между ними.
- Проверка дат, валют и денежных сумм; сводка бюджета.
- Мягкое удаление поездок и активностей, JSON-ошибки 400/404/422.

## Требования

Ruby 3.4.13, Bundler 4.0.3, PostgreSQL. Rails 8.1.4.1 и остальные зависимости зафиксированы в Gemfile.lock. Проверено с PostgreSQL 18.7.

## Настройка

Создайте отдельную роль PostgreSQL и две базы от имени администратора:

```sh
sudo -u postgres createuser --login --no-superuser --no-createdb --no-createrole --pwprompt kicktripp_rails
sudo -u postgres createdb -O kicktripp_rails kicktripp_rails_development
sudo -u postgres createdb -O kicktripp_rails kicktripp_rails_test
```

В каталоге приложения:

```sh
cd rails_api
bundle config set --local path vendor/bundle
bundle install
cp .env.example .env
```

Заполните PGPASSWORD в локальном .env. Файл исключён из Git; пароль не публикуйте. Имена БД и параметры подключения при необходимости меняются в этом же файле. PostgreSQL должен быть запущен локально.

```sh
bin/rails db:migrate
RAILS_ENV=test bin/rails db:migrate
bin/rails db:seed
bin/rails server -b 127.0.0.1
```

Оставьте терминал с сервером открытым. В браузере откройте http://localhost:3000/api/v1/trips — получите список поездок. Главной страницы нет; / возвращает 404. Остановка сервера — Ctrl+C.

Seeds создают поездку «Япония 2027», направление Tokyo, музей, активность, расход 1000 JPY и заявку участника. Повторный запуск обновляет демонстрационные записи без очистки остальных данных. В тестовом окружении seeds пропускаются.

## Запросы

```sh
curl -i http://localhost:3000/api/v1/trips
curl -i 'http://localhost:3000/api/v1/trips?city=Tokyo'
curl -i http://localhost:3000/api/v1/users
curl -i http://localhost:3000/api/v1/activities
```

Для чтения одной поездки, её активностей, расходов и бюджета используйте ID из ответа списка:

- GET /api/v1/trips/:id
- GET /api/v1/trips/:id/activities
- GET /api/v1/trips/:id/expenses
- GET /api/v1/trips/:id/summary

[Примеры CRUD и обработки ошибок](docs/api-examples.md). [Коллекция Postman](docs/kicktripp.postman_collection.json): импортируйте JSON и заполните переменные ID реальными значениями.

## Проверка

```sh
bin/rails test
bin/rails zeitwerk:check
bin/rails routes
```

14 тестов, 158 утверждений. Перед тестами явно применяйте миграции к отдельной тестовой БД; автоматическое пересоздание базы отключено, роль приложения не требует CREATEDB.

Код: app/models — связи и валидации; app/controllers/api/v1 — явные CRUD-действия; app/serializers — поля JSON; config/routes.rb — маршруты; db/migrate — схема; db/seeds.rb — демонстрационные данные.

## Ограничения

Локальный демонстрационный сервис без аутентификации и разграничения ролей. user_id передаётся явно. Общей блокировки для конкурентного изменения нескольких ресурсов нет. Перед публичным развёртыванием эти ограничения нужно устранить. Разные валюты не конвертируются; расходы имеют валюту поездки. Денежные суммы хранятся numeric(14,2), лишние дробные знаки округляются PostgreSQL.
