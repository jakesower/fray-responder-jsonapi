require 'fray'
require 'fray/responder/jsonapi/dataset_handler'
require 'fray/responder/jsonapi/error_handler'
require 'fray/responder/jsonapi/base'

module Fray::Responder
  module Jsonapi
    def self.build(schema, request)
      Base.new(schema, request)
    end
  end
end
