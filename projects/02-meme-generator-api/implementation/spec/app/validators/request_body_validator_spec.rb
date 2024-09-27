# frozen_string_literal: true

require './app/validators/request_body_validator'
require 'json'

RSpec.describe RequestBodyValidator do
  subject(:validator) { RequestBodyValidator }

  let(:request_body) do
    {
      'user' => {
        'username' => username,
        'password' => password
      }
    }
  end

  let(:username) { 'mr_bean' }
  let(:password) { 'test123' }

  describe '.validate' do
    subject(:validate) { validator.validate(request_body) }

    it 'returns a username and password' do
      expect(validate).to eq([username, password])
    end

    context 'giving an invalid request' do
      let(:request_body) { { 'cats' => 'miau' } }

      it 'raises RequestBodyValidatorError with Bad request message' do
        expect { validate }.to raise_error(RequestBodyValidatorError,
                                           'Bad request')
      end
    end

    context 'giving a blank username' do
      let(:username) { '' }

      it 'raises RequestBodyValidatorError with Username is blank message' do
        expect { validate }.to raise_error(RequestBodyValidatorError,
                                           'Username is blank')
      end
    end

    context 'giving a blank password' do
      let(:password) { '' }

      it 'raises RequestBodyValidatorError with Password is blank message' do
        expect { validate }.to raise_error(RequestBodyValidatorError,
                                           'Password is blank')
      end
    end
  end
end
