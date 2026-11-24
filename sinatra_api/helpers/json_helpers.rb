module Kicktripp
  module JsonHelpers
    def json_response(data)
      JSON.generate(data)
    end
  end
end

helpers Kicktripp::JsonHelpers
before { content_type :json }
