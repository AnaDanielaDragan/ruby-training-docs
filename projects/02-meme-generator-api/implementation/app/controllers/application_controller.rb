# frozen_string_literal: true

require 'sinatra/base'
require './app/models/meme'
require './app/clients/authentication_client'
require './app/validators/request_body_validator'

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
    meme.image_url = @request_body_json['meme']['image_url']
    meme.text = @request_body_json['meme']['text']
    meme.create

    redirect "/meme/#{meme.file_name}", 303
    # TODO: Catch a specific error. Move download code that raises private method
    # call to a separate classs, and raise specific error there
  rescue StandardError => e
    pp e
    status 400
  end

  get '/meme/:file_name' do
    send_file(Meme.file_path(params[:file_name]))
  end

  post '/signup' do
    @username = @request_body_json['user']['username']
    @password = @request_body_json['user']['password']
  rescue StandardError
    status 400
  else
    if @username.empty? # TODO: Introduce a validator class
      # TODO: Extract error serialization to avoid duplication
      @blank_username_error = { errors: [{ message: 'Username is blank' }] }
      status 400
      @blank_username_error.to_json
    elsif @password.empty?
      @blank_password_error = { errors: [{ message: 'Password is blank' }] }
      status 400
      body @blank_password_error.to_json
    else
      begin
        @user_token = AuthenticationClient.create_user(@username, @password) # TODO: Look at ServiceObject pattern
      rescue UserAlreadyExistsError
        status 409
      else
        status 201
        body @user_token
      end
    end
  end

  post '/login' do
    @username = @request_body_json['user']['username']
    @password = @request_body_json['user']['password']

    begin
      @user_token = AuthenticationClient.login_user(@username, @password)
    rescue IncorrectUserCredentialsError
      @incorrect_user_credentials_error = { errors: [{ message: 'Incorrect user credentials' }] }
      status 400
      body @incorrect_user_credentials_error.to_json
    else
      status 200
      body @user_token
    end
  end
end
