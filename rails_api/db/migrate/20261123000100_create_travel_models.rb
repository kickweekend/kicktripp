class CreateTravelModels < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :interests, null: false, default: ""
      t.text :bio
      t.timestamps
    end
    add_index :users, "lower(email)", unique: true, name: "users_email_unique"
    create_table :trips do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.decimal :budget_amount, precision: 14, scale: 2, null: false, default: 0
      t.string :currency, null: false, default: "RUB"
      t.string :time_zone, null: false, default: "UTC"
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
    add_check_constraint :trips, "ends_on >= starts_on", name: "trip_dates"
    add_check_constraint :trips, "budget_amount >= 0", name: "trip_budget"
    create_table :destinations do |t|
      t.references :trip, null: false, foreign_key: true
      t.string :country, null: false
      t.string :city, null: false
      t.date :arrival_on, null: false
      t.date :departure_on, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_check_constraint :destinations, "departure_on >= arrival_on AND position >= 0", name: "destination_dates_position"
    create_table :places do |t|
      t.references :destination, null: false, foreign_key: true
      t.string :name, null: false
      t.string :category, null: false
      t.string :address
      t.text :description
      t.timestamps
    end
    create_table :activities do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :place, foreign_key: true
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.text :notes
      t.string :status, null: false, default: "planned"
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
    add_check_constraint :activities, "ends_at >= starts_at", name: "activity_dates"
    add_check_constraint :activities, "status IN ('planned', 'completed', 'cancelled')", name: "activity_status"
    create_table :expenses do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :activity, foreign_key: true
      t.string :title, null: false
      t.string :category, null: false
      t.decimal :amount, precision: 14, scale: 2, null: false
      t.string :currency, null: false
      t.date :spent_on, null: false
      t.timestamps
    end
    add_check_constraint :expenses, "amount >= 0", name: "expense_amount"
    create_table :participations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true
      t.boolean :read, null: false, default: false
      t.boolean :invited, null: false, default: false
      t.timestamps
    end
    add_index :participations, [:user_id, :activity_id], unique: true
  end
end
