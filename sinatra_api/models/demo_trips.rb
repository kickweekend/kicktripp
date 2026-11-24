module Kicktripp
  # Это демонстрационные данные в памяти, не модель ActiveRecord или Sequel.
  module DemoTrips
    DATA = [
      { id: 1, title: "Япония 2027", starts_on: "2027-04-01", ends_on: "2027-04-10", currency: "JPY" }.freeze,
      { id: 2, title: "Поездка в Казань", starts_on: "2027-06-01", ends_on: "2027-06-05", currency: "RUB" }.freeze
    ].freeze

    def self.all
      DATA
    end

    def self.find(id)
      DATA.find { |trip| trip[:id].to_s == id }
    end
  end
end
