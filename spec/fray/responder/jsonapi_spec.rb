require 'spec_helper'

Rspec.describe Fray::Responder::Jsonapi do
  include_context 'care_bear_schema'
    
  subject(:responder) { Fray::Responder::Jsonapi.new(care_bear_schema) }

  

end