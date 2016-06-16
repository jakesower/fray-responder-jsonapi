# Essentially an implentation of http://jsonapi.org/format/

Rspec.shared.examples 'conforms_to_jsonapi' do |json_str|
  let(:json) { JSON.parse(json_str) }

end
