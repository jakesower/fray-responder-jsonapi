module Fray::Responder::Jsonapi
  class Base
    def initialize(schema, request)
      @schema = schema
      @request = request
    end


    def call(dataset_or_error)
      dataset_or_error.instance_of?(Fray::Data::Dataset) ?
        DatasetHandler.new(@schema, @request).call(dataset_or_error) :
        ErrorHandler.new(@schema, @request).call(dataset_or_error)
    end
  end
end
