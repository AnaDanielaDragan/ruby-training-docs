# frozen_string_literal: true

require 'open-uri'
require './app/errors/invalid_file_uri_error'

class FileDownloader
  def self.download_file(image_url, path)
    uri = URI.parse(image_url)
    uri.open do |file_from_uri|
      File.open(path, 'wb') do |file|
        file.write(file_from_uri.read)
      end
    end
  rescue URI::InvalidURIError
    raise InvalidFileUriError
  end
end
