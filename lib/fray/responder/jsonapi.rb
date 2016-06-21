require 'fray'

require 'fray/responder/jsonapi/base'

# require 'fray/responder/jsonapi/data_structures/root'

module Fray::Responder
  module Jsonapi
    def self.build(schema)
      Base.new(schema)
    end
  end
end
