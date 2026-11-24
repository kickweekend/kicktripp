namespace :db do
  task :connection do
    require_relative "../../config/database"
    Sequel.extension :migration
  end
  task models: :connection do
    require_relative "../../models/init"
  end
  desc "Применить миграции; необязательный аргумент — целевая версия"
  task :migrate, [:version] => :connection do |_task, args|
    options = args[:version] ? { target: Integer(args[:version]) } : {}
    Sequel::Migrator.run(Kicktripp::DB, File.expand_path("../../db/migrations", __dir__), options)
    puts "Migrated: #{Kicktripp::DB[:schema_info].first[:version]}"
  end
  desc "Показать версию схемы"
  task version: :connection do
    version = Kicktripp::DB.table_exists?(:schema_info) ? Kicktripp::DB[:schema_info].first[:version] : 0
    puts "Schema version: #{version}"
  end
  desc "Откатить миграции до версии (по умолчанию 0); ALLOW_DESTRUCTIVE=1"
  task :rollback, [:version] => :connection do |_task, args|
    abort "Set ALLOW_DESTRUCTIVE=1; development/test only" unless ENV["ALLOW_DESTRUCTIVE"] == "1" && Kicktripp::ENVIRONMENT != "production"
    target = Integer(args[:version] || 0)
    Kicktripp::DB.transaction do
      Sequel::Migrator.run(Kicktripp::DB, File.expand_path("../../db/migrations", __dir__), target: target)
      Kicktripp::DB.drop_table?(:schema_seeds) if target.zero?
    end
  end
  desc "Пересоздать схему учебной БД; ALLOW_DESTRUCTIVE=1"
  task reset: :connection do
    abort "Set ALLOW_DESTRUCTIVE=1; development/test only" unless ENV["ALLOW_DESTRUCTIVE"] == "1" && Kicktripp::ENVIRONMENT != "production"
    migrations = File.expand_path("../../db/migrations", __dir__)
    Kicktripp::DB.transaction do
      Sequel::Migrator.run(Kicktripp::DB, migrations, target: 0)
      Kicktripp::DB.drop_table?(:schema_seeds)
      Sequel::Migrator.run(Kicktripp::DB, migrations)
    end
    puts "Schema reset"
  end
  desc "Загрузить начальные данные через sequel-seed (каждый файл один раз)"
  task seed: :models do
    abort "Seeds are development/test only" if Kicktripp::ENVIRONMENT == "production"
    Sequel.extension :seed
    Sequel::Seed.setup(Kicktripp::ENVIRONMENT.to_sym)
    Kicktripp::DB.transaction { Sequel::Seeder.apply(Kicktripp::DB, File.expand_path("../../seeds", __dir__)) }
    puts "Seeds ready; applied files: #{Kicktripp::DB[:schema_seeds].count}"
  end
  task environment: :models
  desc "Показать dataset, фильтры и связи на демо-данных"
  task datasets: :models do
    dataset = Kicktripp::DB[:trips]
    puts "Trips count: #{dataset.count}"
    puts "Ordered projection: #{dataset.select(:id, :title).order(:title).all.inspect}"
    puts "By title: #{Kicktripp::Trip.visible.by_title('2027').all.map(&:to_api).inspect}"
    trip = Kicktripp::Trip.visible.first
    puts "Activities: #{trip.activities_dataset.count}" if trip
  end
end
