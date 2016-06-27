module Fray::Responder::Jsonapi
  class Base
    def initialize(schema)
      @schema = schema
    end


    def call(dataset)
      inc = dataset.related.empty? ?
        {} :
        {'included' =>
          format_related(dataset.related)}

      payload = {
        'data' => format_resources(dataset.resources),
        # 'meta' => search_meta(dataset),
        # 'links' => page_links(dataset.meta.stats)
      }.merge(inc)

      Fray::Data::Response.new(
        code: '200',
        headers: {
          'Content-Type' => 'application/vnd.api+json'
        },
        body: JSON.generate(payload)
      )
    end


  private

    #
    # Receive something of the form:
    # {type => {id => {attributes => ..., relationships => ...}}}
    #
    def format_related(related)
      related.flat_map do |(type, resources)|
        resources.flat_map do |(id, body)|
          resource = {
            'id' => id,
            'type' => type,
            'attributes' => body['attributes'],
            'relationships' => body['relationships']
          }

          format_resource(resource)
        end
      end
    end


    def format_resources(resources)
      resources.map{|resource| format_resource(resource)}
    end


    def format_resource(resource)
      resource.merge(relationships(resource))
    end

    #
    # TODO: Include links
    #
    def relationships(resource)
      formatted = resource['relationships'].reduce({}) do |m,(type,ids)|
        d = ids.is_a?(Array) ?
          ids.map{|id| {'type' => type, 'id' => id}} :
          (ids.nil? ? nil : {'type' => type, 'id' => ids})

        m.merge({type => {'data' => d}})
      end

      {'relationships' => formatted}
    end

  end
end