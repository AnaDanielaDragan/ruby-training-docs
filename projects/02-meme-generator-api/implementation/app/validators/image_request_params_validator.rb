# frozen_string_literal: true

require './app/errors/request_body_validator_error'

class ImageRequestParamsValidator
  def self.validate(request_body)
    @image_url = request_body['meme']['image_url']
    @text = request_body['meme']['text']
  rescue StandardError
    raise RequestBodyValidatorError.new, 'Bad request'
  else
    [@image_url, @text]
  end
end
