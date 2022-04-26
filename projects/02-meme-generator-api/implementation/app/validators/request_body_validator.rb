# frozen_string_literal: true

require './app/errors/request_body_validator_error'

class RequestBodyValidator
  def self.validate(request_body)
    @username = request_body['user']['username']
    @password = request_body['user']['password']
  rescue StandardError
    raise RequestBodyValidatorError.new, 'Bad request'
  else
    raise RequestBodyValidatorError.new, 'Username is blank' if @username.empty?
    raise RequestBodyValidatorError.new, 'Password is blank' if @password.empty?

    [@username, @password]
  end
end
