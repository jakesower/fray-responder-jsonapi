module Fray::Responder::Jsonapi
  class DatasetHandler
    def initialize(schema, request)
      @schema = schema
      @request = request
    end


    def call(dataset)
      inc = dataset.related.empty? ?
        {} : {'included' => format_related(dataset.related)}

      meta = dataset.meta ? {'meta' => dataset.meta} : {}

      payload = {
        'data' => format_resources(dataset.resources),
        'links' => page_links(dataset.statistics)
      }.merge(inc).merge(meta)

      Fray::Data::Response.new(
        status: '200',
        headers: { 'Content-Type' => 'application/vnd.api+json' },
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
          format_resource({
            'id' => id,
            'type' => type,
            'attributes' => body['attributes'],
            'relationships' => body['relationships']
          })
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


    def page_links(stats)
      return {} if stats.nil? ||
        !stats.has_key?('total_count') ||
        !@request.query_parameters.has_key?('page')

      this_page = @request.query_parameters['page']['number'].to_i
      page_size = @request.query_parameters['page']['size'].to_i
      num_pages = (stats['total_count'].to_f / page_size).ceil

      page_link = ->(p) { @request.query_parameters.merge({
        'page' => {'number' => p, 'size' => page_size}
      })}

      {}.merge(
        { 'first' => generate_link(page_link.(1)) }
      ).merge(
        (this_page > 1) ?
          { 'prev' => generate_link(page_link.(this_page - 1)) } :
          {}
      ).merge(
        (this_page < num_pages) ?
          { 'next' => generate_link(page_link.(this_page + 1)) } :
          {}
      ).merge(
        { 'last' => generate_link(page_link.(num_pages)) }
      )
    end

    #
    # Params get mapped to query parameters here--allows for nesting one
    # level deep, e.g. params['page']['number'] = 3 => page[number]=3
    #
    def generate_link(params)
      q = params.reduce([]) do |m,(k,v)|
        if v.is_a?(Hash)
          m + v.reduce([]) do |mm,(kk,vv)|
            mm + [ "#{k}[#{kk}]=#{URI.escape(vv.to_s)}" ]
          end
        else
          m + [ "#{k}=#{URI.escape(v.to_s)}" ]
        end
      end

      q.empty? ?
        @request.uri :
        "#{@request.uri}?#{q.join('&')}"
    end
  end
end
