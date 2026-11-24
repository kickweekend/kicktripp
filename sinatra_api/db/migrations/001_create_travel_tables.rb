Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :name, null: false
      String :email, null: false
      String :interests, null: false, default: ""
      String :bio, text: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index Sequel.function(:lower, :email), unique: true, name: :users_email_unique
    end
    create_table(:trips) do
      primary_key :id
      foreign_key :user_id, :users, null: false, index: true
      String :title, null: false
      String :description, text: true
      Date :starts_on, null: false
      Date :ends_on, null: false
      BigDecimal :budget_amount, size: [14, 2], null: false, default: 0
      String :currency, null: false, default: "RUB"
      String :time_zone, null: false, default: "UTC"
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      constraint(:trip_dates) { ends_on >= starts_on }
      constraint(:trip_budget) { budget_amount >= 0 }
    end
    create_table(:destinations) do
      primary_key :id
      foreign_key :trip_id, :trips, null: false, index: true
      String :country, null: false
      String :city, null: false
      Date :arrival_on, null: false
      Date :departure_on, null: false
      Integer :position, null: false, default: 0
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      constraint(:destination_dates) { departure_on >= arrival_on }
      constraint(:destination_position) { position >= 0 }
    end
    create_table(:places) do
      primary_key :id
      foreign_key :destination_id, :destinations, null: false, index: true
      String :name, null: false
      String :category, null: false
      String :address
      String :description, text: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    create_table(:activities) do
      primary_key :id
      foreign_key :trip_id, :trips, null: false, index: true
      foreign_key :place_id, :places, index: true
      String :title, null: false
      DateTime :starts_at, null: false
      DateTime :ends_at, null: false
      String :notes, text: true
      String :status, null: false, default: "planned"
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      constraint(:activity_dates) { ends_at >= starts_at }
      constraint(:activity_status, Sequel.lit("status IN ('planned', 'completed', 'cancelled')"))
    end
    create_table(:expenses) do
      primary_key :id
      foreign_key :trip_id, :trips, null: false, index: true
      foreign_key :activity_id, :activities, index: true
      String :title, null: false
      String :category, null: false
      BigDecimal :amount, size: [14, 2], null: false
      String :currency, null: false
      Date :spent_on, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      constraint(:expense_amount) { amount >= 0 }
    end
    create_table(:participations) do
      primary_key :id
      foreign_key :user_id, :users, null: false, index: true
      foreign_key :activity_id, :activities, null: false, index: true
      TrueClass :read, null: false, default: false
      TrueClass :invited, null: false, default: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index [:user_id, :activity_id], unique: true
    end
  end
end
