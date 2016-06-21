module Fray::Responder::Jsonapi
  class Base
    def initialize(schema)
      @schema = schema
    end


    def call(dataset)
      {
        'data' => []
      }
    end
  end
end