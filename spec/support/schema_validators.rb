require 'json'

module SchemaValidators
  class << self
    @@schemas = {}

    dir = File.dirname(File.expand_path(__FILE__))
    Dir["#{dir}/schema_validators/*.json"].each do |path|
      m = File.basename(path, '.json')

      define_method m do
        @@schemas[m] ||= begin
          JSON.parse(File.read(path))
        end
      end
    end
  end
end
