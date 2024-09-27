# frozen_string_literal: true

require 'sinatra/base'
require './app/models/meme'
require './app/clients/authentication_client'
require './app/validators/request_body_validator'
require './app/validators/image_request_params_validator'
require './app/errors/error_message_body'

class ApplicationController < Sinatra::Base
  module ContentType
    JSON = 'application/json'
  end

  before do
    @request_body_json = JSON.parse(request.body.read) if request.content_type == ContentType::JSON
    request.body.rewind
  end

  get '/' do
    status 200
  end

  post '/memes' do
    token = (request.env['HTTP_AUTHORIZATION'] || '').split[1]
    return status 401 unless AuthenticationClient.authorized?(token)

    meme = Meme.new
    meme.image_url, meme.text = ImageRequestParamsValidator.validate(@request_body_json)
    meme.create

    redirect "/meme/#{meme.file_name}", 303

  rescue InvalidFileUriError
    status 400
    body 'Invalid image URL provided.'
  end

  get '/meme/:file_name' do
    send_file(Meme.file_path(params[:file_name]))
  end

  post '/signup' do
    username, password = RequestBodyValidator.validate(@request_body_json)
    user_token = AuthenticationClient.create_user(username, password)

    status 201
    body user_token
  rescue RequestBodyValidatorError => e
    status 400
    body ErrorMessageBody.create(e.message)
  rescue UserAlreadyExistsError
    status 409
  end

  post '/login' do
    username = @request_body_json['user']['username']
    password = @request_body_json['user']['password']

    user_token = AuthenticationClient.login_user(username, password)

    status 200
    body user_token
  rescue IncorrectUserCredentialsError
    status 400
    body ErrorMessageBody.create('Incorrect user credentials')
  end
end
