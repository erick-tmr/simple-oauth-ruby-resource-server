# frozen_string_literal: true

module JwtValidatable
  JWT_ERRORS = [JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidAudError].freeze

  def validate_jwt(jwt)
    payload, _header = JWT.decode(jwt, nil, true, {
                                    algorithm: 'RS256',
                                    iss: "#{ENV['IUGU_BASE_URL']}/",
                                    verify_iss: true,
                                    aud: ["Iugu.Platform.#{ENV['IUGU_CLIENT_ID']}"],
                                    verify_aud: true,
                                    jwks:
                                  })
    payload
  end

  def jwks
    @jwks ||= JSON.parse(Faraday.get(ENV['IUGU_JWKS_URL']).body)
  end
end
