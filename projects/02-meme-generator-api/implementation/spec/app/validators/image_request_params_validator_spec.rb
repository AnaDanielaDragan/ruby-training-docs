# frozen_string_literal: true

require './app/validators/image_request_params_validator'
require 'json'

RSpec.describe ImageRequestParamsValidator do
  subject(:validator) { ImageRequestParamsValidator }

  let(:request_body) do
    {
      'meme' => {
        'image_url' => image_url,
        'text' => text
      }
    }
  end

  let(:image_url) { 'https://media.npr.org/assets/img/2021/08/11/gettyimages-1279899488_wide-f3860ceb0ef19643c335cb34df3fa1de166e2761-s1100-c50.jpg' }
  let(:text) { 'Start the way by organising your playground' }

  describe '.validate' do
    subject(:validate) { validator.validate(request_body) }

    it 'returns an image url and text' do
      expect(validate).to eq([image_url, text])
    end

    context 'giving an invalid request' do
      let(:request_body) { { 'cats' => 'miau' } }

      it 'raises RequestBodyValidatorError with Bad request message' do
        expect { validate }.to raise_error(RequestBodyValidatorError,
                                           'Bad request')
      end
    end
  end
end
