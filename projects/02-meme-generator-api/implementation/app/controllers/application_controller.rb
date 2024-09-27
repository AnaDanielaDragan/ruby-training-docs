# frozen_string_literal: true

require 'sinatra/base'
require './app/models/meme'

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
    @meme = Meme.new
    @meme.image_url = @request_body_json['meme']['image_url']
    @meme.text = @request_body_json['meme']['text']

    begin
      @meme.create
    rescue StandardError
      status 400
    else
      redirect "/meme/#{@meme.file_name}", 303
    end
  end

  get '/meme/:file_name' do
    send_file(Meme.file_path(params[:file_name]))
  end
end
