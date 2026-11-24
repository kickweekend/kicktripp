not_found do
  json_response(@not_found_response || { error: "not_found", path: request.path_info })
end

error do
  json_response(error: "internal_server_error")
end
