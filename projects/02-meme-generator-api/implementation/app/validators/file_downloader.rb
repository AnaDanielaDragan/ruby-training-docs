# frozen_string_literal: true

require 'open-uri'

class FileDownloader
  def self.download_file(uri, path)
    uri.open do |file_from_uri|
      File.open(path, 'wb') do |file|
        file.write(file_from_uri.read)
      end
    end
  rescue StandardError
    raise InvalidFileUriError
  end
end
