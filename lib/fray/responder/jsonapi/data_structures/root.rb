module Fray::Responder::Jsonapi
  RootSchema = Dry::Validation.Schema do
    key(:data).maybe{ (array?.then(each(schema(Resource)))) | schema(Resource) }
    key(:errors).maybe { array?.then(each(schema(Error))) }
    key(:meta).maybe { hash? }
    key(:links).maybe { schema(Links) }
    key(:jsonapi).maybe do
      key(:version).maybe(:str?)
      key(:meta).maybe(:hash?)
    end
    key(:included).maybe { each(schema(Resource)) }

    rule(top_key_required: [:data, :errors, :meta]) do |data, errors, meta|
      data | errors | meta
    end

    rule(no_data_and_errors: [:data, :errors]) do |data, errors|
      data ^ errors
    end

    rule(data_has_homogenous_resources: [:data]) do |data|
      # TODO
    end
  end


  Resource = Dry::Validation.Schema do
    key(:id).required(:str?)
    key(:type).required(:str?)
    key(:attributes).maybe
    key(:relationships).maybe { schema(Relationships) }
    key(:links).maybe { schema(Links) }
    key(:meta).maybe { hash? }

    rule(reserved_attributes_keys: [:attributes]) do |attributes|
      !attributes.has_key?('relationships') && !attributes.has_key?('links')
    end
  end


  Relationships = Dry::Validation.Schema do
    key(:links).maybe { schema(Links) }
    key(:data).maybe { null? | 
                       array?.then(each(schema(ResourceIdentifier))) |
                       schema(ResourceIdentifier) }
    key(:meta).maybe { hash? }

    # probably a better way to do this
    rule(has_at_least_one_key: [:links, :data, :meta]) do |links, data, meta|
      links | data | meta
    end
  end


  RelatedResource = Dry::Validation.Schema do
    key(:self).maybe { str? } # url? would be nicer
  end


  ResourceIdentifier = Dry::Validation.Schema do
    key(:id).required.str?
    key(:type).required.str?
    key(:meta).maybe{ hash? }
  end


  Error = Dry::Validation.Schema do
    key(:id).maybe
    key(:links).schema{ Links }
    key(:status).maybe(:str?)
    key(:code).maybe(:str?)
    key(:title).maybe(:str?)
    key(:detail).maybe(:str?)
    key(:source).maybe do
      key(:pointer).maybe(:str?)
      key(:parameter).maybe(:str?)
    end
    key(:meta){ hash? }
  end
end
