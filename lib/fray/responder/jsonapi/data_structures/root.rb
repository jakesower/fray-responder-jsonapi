require 'dry-validation'

module Fray::Responder::Jsonapi
  module Validators
    ERROR_PATH = Pathname(__dir__).join('../../../../../config/errors.yml').realpath.freeze

    module Predicates
      include Dry::Logic::Predicates

      # predicate(:is_hash?) do |value|
      #   value.is_a?(Hash)
      # end

      predicate(:matches_schema?) do |schema, value|
        result = schema.(value)
        message = result.messages
        result.success?
      end

      predicate(:array_of?) do |schema, value|
        value.all?(schema.(value).success?)
      end

      predicate(:elt_or_array_of?) do |schema, value|
        matches_schema?(value, schema)
      end
    end


    Resource = Dry::Validation.Schema do
      key(:id).required(:str?)
      key(:type).required(:str?)
      optional(:attributes)
      # key(:relationships).maybe { schema(Relationships) }
      # key(:links).maybe { schema(Links) }
      # key(:meta).maybe { hash? }

      # rule(reserved_attributes_keys: [:attributes]) do |attributes|
      #   !attributes.has_key?('relationships') && !attributes.has_key?('links')
      # end
    end


    RootSchema = Dry::Validation.Schema do
      configure do
        config.predicates = Predicates
        configure { config.messages_file = ERROR_PATH }
      end

      optional(:data){ matches_schema?(Resource) }

      # key(:data).maybe{ (array?.then(each(schema(Resource)))) | schema(Resource) }
      # key(:errors).maybe { array?.then(each(schema(Error))) }
      optional(:meta).required { type?(Hash) }
      # key(:links).maybe { schema(Links) }
      # key(:jsonapi).maybe do
      #   key(:version).maybe(:str?)
      #   key(:meta).maybe(:hash?)
      # end
      # key(:included).maybe { each(schema(Resource)) }

      # rule(top_key_required: [:data, :meta]) do |data, meta|
      #   data.filled? | meta.filled?# | meta.filled?
      # end

      # rule(no_data_and_errors: [:data, :errors]) do |data, errors|
      #   data ^ errors
      # end

      # rule(data_has_homogenous_resources: [:data]) do |data|
      #   # TODO
      # end
    end




    # Relationships = Dry::Validation.Schema do
    #   key(:links).maybe { schema(Links) }
    #   key(:data).maybe { null? | 
    #                      array?.then(each(schema(ResourceIdentifier))) |
    #                      schema(ResourceIdentifier) }
    #   key(:meta).maybe { hash? }

    #   # probably a better way to do this
    #   rule(has_at_least_one_key: [:links, :data, :meta]) do |links, data, meta|
    #     links | data | meta
    #   end
    # end


    # RelatedResource = Dry::Validation.Schema do
    #   key(:self).maybe { str? } # url? would be nicer
    # end


    # ResourceIdentifier = Dry::Validation.Schema do
    #   key(:id).required.str?
    #   key(:type).required.str?
    #   key(:meta).maybe{ hash? }
    # end


    # Error = Dry::Validation.Schema do
    #   key(:id).maybe
    #   key(:links).schema{ Links }
    #   key(:status).maybe(:str?)
    #   key(:code).maybe(:str?)
    #   key(:title).maybe(:str?)
    #   key(:detail).maybe(:str?)
    #   key(:source).maybe do
    #     key(:pointer).maybe(:str?)
    #     key(:parameter).maybe(:str?)
    #   end
    #   key(:meta){ hash? }
    # end
  end
end
