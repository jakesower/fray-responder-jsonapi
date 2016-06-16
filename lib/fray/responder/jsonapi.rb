require 'dry-types'

module Types
  include Dry::Types.module
end


module Fray
  module Responder
    module Jsonapi
      def initialize(schema)
        @schema = schema
      end
    end
  end
end
