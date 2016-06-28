require 'json'
require 'json-schema'

RSpec.describe Fray::Responder::Jsonapi do
  include_context 'care_bear_schema'

  let(:request) {
    Fray::Data::Request.new({
      resource_type: 'bears',
      root_uri: 'http://example.com',
      uri: 'http://example.com/bears',
      headers: {},
      query_parameters: {
        page: { 'number' => '1', 'size' => '10' },
        include: 'homes,powers'
      }
    })
  }

  let(:responder) {
    Fray::Responder::Jsonapi.build(care_bear_schema, request)
  }


  context "with an empty response" do
    let(:dataset) {
      Fray::Data::Dataset.new(
        resource_type: 'bears',
        resources: [],
        related: {}
      )
    }

    let(:result) {
      responder.(dataset)
    }


    it "conforms to the jsonapi schema" do
      expect(JSON.parse(result.body)).to match_schema(:jsonapi)
    end

    it 'responds with an empty jsonapi response' do
      expect(result).to be_instance_of(Fray::Data::Response)

      body = JSON.parse(result.body)
      expect(body['data']).to eq([])
    end

    it 'will not have page links included' do
      body = JSON.parse(result.body)
      expect(body['links']).to_not have_key('first')
    end
  end


  context "with a straightforward response" do
    let(:dataset) {
      Fray::Data::Dataset.new(
        resource_type: 'bears',
        resources: [
          { id: '1',
            type: 'bears',
            attributes: {
              'name' => 'Tenderheart',
              'gender' => 'male',
              'belly_badge' => 'heart',
              'fur_color' => 'tan' },
            relationships: {
              'homes' => '1',
              'powers' => ['1', '2']
            }}
        ],
        related: {
          'homes' => {
            '1' => {
              attributes: {
                'name' => 'Care-a-lot',
                'location' => {"latitude"=>39.097579, "longitude"=>-77.228504},
                "caringMeter" => 0.99 },
              relationships: {
                'bears' => ['1', '2', '3']}}},
          'powers' => {
            '1' => {
              attributes: {
                'name' => 'Care Bear Stare',
                'description' => 'Powerful attack with a caring beam.'},
              relationships: {
                'bears' => ['1', '2', '3']}},
            '2' => {
              attributes: {
                'name' => 'Magic Mirror',
                'description' => 'Spy on others, cast spells, check hair.'},
              relationships: {}}}},
        statistics: {
          count: 1,
          total_count: 1
        },
        meta: {
          'generator': 'fray'
        }
      )
    }

    let(:result) {
      responder.(dataset)
    }


    it "creates a Fray::Data::Response" do
      expect(result).to be_instance_of(Fray::Data::Response)
    end

    it "returns a 200 status code" do
      expect(result.status).to eq('200')
    end

    it "returns the proper json api content type" do
      expect(result.headers['Content-Type']).to eq('application/vnd.api+json')
    end

    it "conforms to the jsonapi schema" do
      expect(JSON.parse(result.body)).to match_schema(:jsonapi)
    end

    it "contains the correct data" do
      body = JSON.parse(result.body)
      data = body['data'].first

      expect(data).to eq({
        'id' => '1',
        'type' => 'bears',
        'attributes' => {
          'name' => 'Tenderheart',
          'gender' => 'male',
          'belly_badge' => 'heart',
          'fur_color' => 'tan' },
        'relationships' => {
          'homes' => {
            'data' => {'type' => 'homes', 'id' => '1' }},
          'powers' => {
            'data' => [
              {'type' => 'powers', 'id' => '1'},
              {'type' => 'powers', 'id' => '2'}]}}
      })
    end

    it "properly formats related resources" do
      body = JSON.parse(result.body)
      included = body['included']

      expect(included).to include({
        'type' => 'homes',
        'id' => '1',
        'attributes' => {
          'name' => 'Care-a-lot',
          'location' => {"latitude"=>39.097579, "longitude"=>-77.228504},
          "caringMeter" => 0.99 },
        'relationships' => {
          'bears' => {
            'data' => [
              {'type' => 'bears', 'id' => '1'},
              {'type' => 'bears', 'id' => '2'},
              {'type' => 'bears', 'id' => '3'}]}}
      })

      expect(included).to include({
        'type' => 'powers',
        'id' => '2',
        'attributes' => {
          'name' => 'Magic Mirror',
          'description' => 'Spy on others, cast spells, check hair.'},
        'relationships' => {}
      })
    end

    it "includes pagination links" do
      body = JSON.parse(result.body)
      links = body['links']

      expect(links).to have_key('first')
      expect(links).to have_key('last')

      expect(links['first']).to include(URI.encode('page[number]=1'))
      expect(links['last']).to include(URI.encode('page[number]=1'))
    end

    it "preserves meta data" do
      body = JSON.parse(result.body)
      meta = body['meta']

      expect(meta['generator']).to eq('fray')
    end
  end


  context "with a single error" do
    let(:error) {
      Fray::Data::Error.new(
        status: '500',
        badkey: 'Kiss me goodbye',
        title: 'Stick around'
      )
    }

    let(:result) {
      responder.(error)
    }


    it "returns the proper json api content type" do
      expect(result.headers['Content-Type']).to eq('application/vnd.api+json')
    end

    it "conforms to the jsonapi schema" do
      expect(JSON.parse(result.body)).to match_schema(:jsonapi)
    end

    it "returns appropriate error keys" do
      body = JSON.parse(result.body)

      expect(body['errors']).to eq([
        { 'status' => '500', 'title' => 'Stick around' }
      ])
    end
  end


  context "with multiple errors" do
    let(:error) {
      Fray::Data::ErrorSet.new([
        Fray::Data::Error.new({
          status: '500',
          badkey: 'Kiss me goodbye',
          title: 'Stick around'
        }),
        Fray::Data::Error.new({
          status: '400',
          title: 'Bad input'
        })
      ])
    }

    let(:result) {
      responder.(error)
    }


    it "returns the proper json api content type" do
      expect(result.headers['Content-Type']).to eq('application/vnd.api+json')
    end

    it "conforms to the jsonapi schema" do
      expect(JSON.parse(result.body)).to match_schema(:jsonapi)
    end

    it "returns a 500" do
      expect(result.status).to eq('500')
    end

    it "returns appropriate error keys" do
      body = JSON.parse(result.body)

      expect(body['errors']).to eq([
        { 'status' => '500', 'title' => 'Stick around' },
        { 'status' => '400', 'title' => 'Bad input' }
      ])
    end
  end

end
