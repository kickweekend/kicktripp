Sequel.migration do
  change do
    alter_table(:trips) { add_column :deleted, TrueClass, null: false, default: false }
    alter_table(:activities) { add_column :deleted, TrueClass, null: false, default: false }
  end
end
