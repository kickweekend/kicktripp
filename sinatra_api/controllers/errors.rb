not_found do
  json_response(@not_found_response || { error: "route_not_found", path: request.path_info })
end
error JSON::ParserError do
  status 400
  json_response(error: "bad_request", message: "Invalid JSON")
end
error Sequel::ValidationFailed do
  status 422
  json_response(errors: env["sinatra.error"].model.errors.to_hash)
end
error Sequel::InvalidValue, Sequel::MassAssignmentRestriction do
  status 422
  json_response(error: "invalid_value")
end
error Sequel::UniqueConstraintViolation, Sequel::ForeignKeyConstraintViolation, Sequel::CheckConstraintViolation, Sequel::NotNullConstraintViolation do
  status 422
  json_response(error: "conflict_with_existing_data")
end
error do
  status 500
  json_response(error: "internal_server_error")
end
