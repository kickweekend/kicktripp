Служебные задачи PostgreSQL/Sequel находятся в tasks/db.rb.
Команды: bundle exec rake db:migrate, db:version, db:seed, db:datasets.
Откат и reset требуют ALLOW_DESTRUCTIVE=1 и удаляют данные; при проверке используются только с APP_ENV=test.
