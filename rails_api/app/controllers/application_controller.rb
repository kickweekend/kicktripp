class ApplicationController < ActionController::API
  wrap_parameters false
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "not_found" }, status: :not_found
  end
  rescue_from ActionController::ParameterMissing, ActionController::BadRequest, ActionDispatch::Http::Parameters::ParseError do |error|
    render json: { error: "bad_request", message: error.message }, status: :bad_request
  end
  rescue_from ActiveRecord::RecordInvalid do |error|
    render json: { errors: error.record.errors.to_hash }, status: :unprocessable_entity
  end
  rescue_from ActiveRecord::RecordNotUnique, ActiveRecord::InvalidForeignKey do
    render json: { error: "conflict_with_existing_data" }, status: :unprocessable_entity
  end

  def not_found
    render json: { error: "route_not_found" }, status: :not_found
  end
  private

  # Значение пользователя передаётся параметром SQL, символы LIKE экранируются.
  def text_filter(scope, field, value)
    return scope if value.blank?
    scope.where("#{field} ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(value)}%")
  end

  def boolean_filter(scope, key)
    return scope unless params.key?(key)
    unless %w[true false].include?(params[key].to_s)
      raise ActionController::BadRequest, "#{key} must be true or false"
    end
    scope.where(key => params[key].to_s == "true")
  end
end
