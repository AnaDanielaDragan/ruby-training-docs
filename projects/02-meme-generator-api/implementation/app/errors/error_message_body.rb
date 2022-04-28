# frozen_string_literal: true

class ErrorMessageBody
  def self.create(message)
    message_body = { 'errors': [{ 'message': message }] }
    message_body.to_json
  end
end
