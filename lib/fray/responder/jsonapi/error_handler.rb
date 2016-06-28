module Fray::Responder::Jsonapi
  class ErrorHandler
    JSONAPI_KEYS = [ :id, :links, :status, :code, :title, :detail, :source,
                     :meta ]

    def initialize(schema, request)
      @schema = schema
      @request = request
    end


    def call(raw_error)
      # JSON API always wants an array of errors
      errors = raw_error.is_a?(Fray::Data::Error) ?
        Fray::Data::ErrorSet.new([raw_error]) :
        raw_error

      body = { 'errors' => errors.map{|e| format_error(e)} }

      Fray::Data::Response.new(
        status: determine_status(errors),
        headers: { 'Content-Type' => 'application/vnd.api+json' },
        body: JSON.generate(body)
      )
    end


  private

    def determine_status(errors)
      case
      when errors.uniq.size == 1
        errors.first.status
      when errors.any?{|e| e.status == '500'}
        '500'
      when errors.any?{|e| e[0] == '5'}
        '500'
      else
        '400'
      end
    end


    def format_error(error)
      error_hash = error.to_h

      JSONAPI_KEYS.reduce({}) do |m,k|
        error_hash.has_key?(k) ? m.merge({k => error[k]}) : m
      end
    end

  end
end
