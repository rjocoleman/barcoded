module Barcoded
  class Service < Sinatra::Base
    helpers Sinatra::RequestHelpers
    helpers Sinatra::ResponseHelpers
    register Sinatra::RespondWith
    register Sinatra::CrossOrigin
    include Sinatra::ExceptionHandler

    enable :logging

    before '/barcodes' do
      normalize_params!
      valid_request!
      supported!
      allow_cross_origin if cors_enabled?
    end

    post '/barcodes' do
      create_barcode(encoding, data)
      created
    end

    get '/img/*/*.*' do |encoding, data, format|
      barcode = create_barcode(encoding, URI.unescape(data))
      image   = BarcodeImageFactory.build(barcode, format, options)
      send_image image, format
    end

    get '/ping' do
      healthy_response
    end

    private

    def create_barcode(encoding, value)
      barcode = BarcodeFactory.build(encoding, value)
      raise InvalidBarcodeData unless barcode.valid?
      barcode
    end
  end
end
