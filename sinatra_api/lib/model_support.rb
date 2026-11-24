module Kicktripp
  module ModelSupport
    def self.included(model)
      model.plugin :validation_helpers
      model.plugin :defaults_setter, cache: true
      model.plugin :timestamps, update_on_create: true
    end

    def to_api
      self.class::API_FIELDS.to_h do |field|
        value = self[field]
        value = case value
        when BigDecimal then value.to_s("F")
        when Time, DateTime then value.to_time.utc.iso8601(3)
        when Date then value.iso8601
        else value
        end
        [field, value]
      end
    end

    def money_validation(field)
      value = self[field]
      errors.add(field, "must be a nonnegative amount below 10^12") unless value && value >= 0 && value < 1_000_000_000_000
    end

  end
end
