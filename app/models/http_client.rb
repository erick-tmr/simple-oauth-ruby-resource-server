# frozen_string_literal: true

class HttpClient
  def initialize(base_url, json: true, jwt: nil)
    @conn = Faraday.new(base_url) do |f|
      if json
        f.request :json
        f.response :json
      end

      f.request :authorization, 'Bearer', jwt if jwt
    end
  end

  def get(path, params: nil, headers: nil)
    @conn.get(path, params, headers)
  end

  def post(path, body: nil, headers: nil)
    @conn.post(path, body, headers)
  end
end
