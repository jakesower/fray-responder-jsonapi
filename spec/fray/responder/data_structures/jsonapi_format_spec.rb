require 'spec_helper'

Rspec.describe Fray::Responder::Jsonapi::Root do
  let(:valid_json) do
    [
      {'data' => []},
      {'errors' => []},
      {'meta' => {}},
      
    ]
  end
  

end