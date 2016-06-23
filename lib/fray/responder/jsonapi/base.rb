module Fray::Responder::Jsonapi
  class Base
    def initialize(schema)
      @schema = schema
    end


    def call(dataset)
      Fray::Data::Response.new(
        code: 200,
        headers: {},
        body: JSON.generate({ 'data' => [] })
      )
    end
  end
end