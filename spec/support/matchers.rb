require 'json-schema'

RSpec::Matchers.define :match_schema do |schema_name|
  match do |actual|
    schema = SchemaValidators.send(schema_name)
    JSON::Validator.validate(schema, actual)
  end

  failure_message do |actual|
    schema = SchemaValidators.send(schema_name)

    "#{actual.inspect} does not match the #{schema_name} schema\n\n" +
    JSON::Validator.fully_validate(schema, actual).join("\n")
  end
end
