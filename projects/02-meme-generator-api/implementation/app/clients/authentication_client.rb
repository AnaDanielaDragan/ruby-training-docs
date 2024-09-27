# frozen_string_literal: true

require './app/clients/db_client'
require './app/errors/incorrect_user_credentials_error'
require 'bcrypt'
require 'securerandom'

class AuthenticationClient
  class << self
    def create_user(username, password)
      db_client = DBClient.instance
      db_client.create_user(username, encrypt_password(password))

      token = generate_token
      db_client.create_token(username, token)

      result = { "user": { "token": token } }
      result.to_json
    end

    def delete_user(username)
      db_client = DBClient.instance
      db_client.delete_user(username)
      db_client.delete_token(username)
    end

    def login_user(username, password)
      db_client = DBClient.instance

      validate_user(username, password)

      token = generate_token
      db_client.create_token(username, token)

      result = { "user": { "token": token.to_s } }
      result.to_json
    end

    def authorized?(token)
      db_client = DBClient.instance
      db_client.get_token(token)
    end

    private

    def validate_user(username, password)
      db_client = DBClient.instance
      raise IncorrectUserCredentialsError unless db_client.get_user(username)

      validate_password(username, password)
    end

    def validate_password(username, password)
      db_client = DBClient.instance
      result = db_client.get_password(username)
      raise IncorrectUserCredentialsError unless compare_passwords(result[0], password)
    end

    def compare_passwords(encrypted_password, plain_password)
      BCrypt::Password.new(encrypted_password) == plain_password
    end

    def encrypt_password(password)
      BCrypt::Password.create(password).to_s
    end

    def generate_token
      SecureRandom.hex(16)
    end
  end
end
