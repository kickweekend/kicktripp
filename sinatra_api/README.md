# kicktripp — Sinatra, практическая №2

Это отдельное API на Sinatra. В нём изучаются маршруты, параметры запросов, namespace и запуск через Rack. Rails из первой работы работает отдельно.

**Данные пока демонстрационные, в памяти:** две поездки. PostgreSQL не подключается, поэтому поездки из Rails здесь не появятся. Создание и изменение записей на этом этапе не реализуются.

## Запуск

Из папки `APIworks`:

```bash
cd project/sinatra_api
bundle config set --local path vendor/bundle
bundle install
bundle exec rackup -o 127.0.0.1 -p 4567 config.ru
```

При следующих запусках достаточно последней команды. Оставь терминал открытым. Остановка — `Ctrl+C`.

Открой в браузере: **http://localhost:4567/**, затем **http://localhost:4567/api/v1/trips**.

Sinatra использует порт **4567**, Rails — **3000**. Их можно запускать одновременно в разных терминалах. Пароль БД и `.env` для второй работы не нужны.

## Что показать на защите

Каждый адрес можно открыть в браузере или отправить в Postman методом **GET**.

| Адрес после http://localhost:4567 | Что показывает |
|---|---|
| `/` | JSON с названием kicktripp, фреймворком Sinatra и storage=demo |
| `/hello/Alex` | Именованный параметр `params[:name]` |
| `/hello-block/Maria` | Именованный параметр через аргумент блока |
| `/redirect` | Перенаправление 302 на `/hello/World` |
| `/meta/hello/world` | Параметр, захваченный регулярным выражением |
| `/meta/hello/world/123` | Тот же regex-маршрут с дополнительным хвостом |
| `/say/hello/to/world` | Маски splat: `{"parts":["hello","world"]}` |
| `/download/path/to/file.xml` | Разбор пути и расширения: `{"path":"path/to/file","extension":"xml"}` |
| `/demo/trips` | Маршрут без необязательного параметра |
| `/demo/trips.json` | Тот же маршрут, format=json |
| `/demo/trips.xml` | Тот же маршрут, format=xml; ответ всё равно JSON |
| `/order/special` | Первый подходящий маршрут: `matched=specific` |
| `/order/ordinary` | Общий маршрут с параметром: `matched=parameter` |
| `/api/v1/trips` | Список двух поездок в namespace `/api/v1` |
| `/api/v1/trips/1` | Одна демонстрационная поездка |
| `/api/v1/trips/999` | JSON с ошибкой отсутствующей поездки, HTTP 404 |
| `/api/v1/friends` | Маска внутри namespace, HTTP 404 |
| `/friends` | Неизвестный адрес вне namespace, HTTP 404 |

`/download/...` только разбирает адрес и не читает файлы с диска. Суффиксы json/xml в `/demo/trips` показывают работу необязательного параметра, а не переключают сериализацию на XML.

Браузер и Postman обычно сами переходят по редиректу. Чтобы увидеть исходный код 302 в терминале:

```bash
curl -i http://localhost:4567/redirect
curl -i http://localhost:4567/api/v1/trips
```

В Postman можно импортировать [коллекцию](../docs/kicktripp-sinatra.postman_collection.json), она настроена на порт 4567.

## Два стиля приложения из методички

Примеры запускаются по одному; останови предыдущий процесс через Ctrl+C, чтобы освободить порт.

**Классический стиль**, один файл с `require "sinatra"`:

```bash
bundle exec ruby examples/classic_app.rb
```

Либо тот же пример через Rack:

```bash
bundle exec rackup -o 127.0.0.1 -p 4567 examples/classic.ru
```

**Модульный стиль**, класс `Kicktripp::ModularApp < Sinatra::Base`:

```bash
bundle exec rackup -o 127.0.0.1 -p 4567 examples/modular.ru
```

Его также можно запустить напрямую: `bundle exec ruby examples/modular_app.rb`.

В каждом примере открой `/`, `/hello/Alex`, `/api/v1/hello/Maria`. Корневой ответ покажет `style=classic` или `style=modular`.

Итоговое приложение `app.rb` следует заключительной части методички: классический стиль, `run Sinatra::Application` в `config.ru`, маршруты и другие файлы разнесены по каталогам. Примеры в `examples/` не загружаются вместе с ним.

## Как устроен код

- `app.rb` — подключение библиотек и загрузка файлов.
- `config.ru` — точка запуска через Rack.
- `config/settings.rb` — локальный адрес, порт и Puma.
- `routes/01_basics.rb` — параметры, regex, splat, redirect и порядок маршрутов.
- `routes/02_trips.rb` — namespace, список и отдельная поездка.
- `models/demo_trips.rb` — демонстрационные данные, без ORM и БД.
- `helpers/json_helpers.rb` — JSON и Content-Type.
- `controllers/errors.rb` — обработчики ошибок.
- `lib/` — место для служебных задач следующей работы.
- `examples/` — отдельные примеры классического и модульного стилей.

В Rails многое создаётся генератором: структура, контроллеры, модели, конфигурация БД. В Sinatra мы сами задаём структуру и пишем пары «HTTP-метод + путь → Ruby-блок». Rack передаёт запрос приложению, Puma принимает HTTP-соединения.

В состав Gemfile включены pg, sequel и sequel-seed из конца методички. Они загружаются, но подключения к PostgreSQL нет. Миграции и реальные модели Sequel относятся к практической №3.

## Проверка

```bash
bundle exec rake test
```

Тестируются основное приложение и оба стиля примеров. Каждый классический вариант проверяется в отдельном процессе, чтобы они не смешивали общий `Sinatra::Application`.

Неизвестные адреса возвращают JSON и корректный HTTP 404. Защита Sinatra от недопустимого Host не отключена: используй `localhost` или `127.0.0.1`.
