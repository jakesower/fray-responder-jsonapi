require 'json'

RSpec.describe Fray::Responder::Jsonapi do
  include_context 'care_bear_schema'

  let(:responder) {
    Fray::Responder::Jsonapi.build(care_bear_schema)
  }

  context "with an empty response" do
    let(:dataset) {
      Fray::Data::Dataset.new(
        resource_type: 'bears',
        resources: [],
        related: nil,
        meta: nil
      )
    }

    it 'responds with an empty jsonapi response' do
      result = responder.(dataset)
      expect(result).to be_instance_of(Fray::Data::Response)

      body = JSON.parse(result.body)
      expect(body['data']).to eq([])
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
              'homes' => ['1'],
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
                'description' => 'Spy on others, cast spells, check hair.'}}}},
        meta: {}
      )
    }

    let(:result) {
      responder.(dataset)
    }

    it "creates a Fray::Data::Response" do
      expect(result).to be_instance_of(Fray::Data::Response)
    end

    it "returns a 200 code" do
      expect(result.code).to eq('200')
    end

    it "properly formats the body of the response" do
      body = JSON.parse(result.body)
      expect(body['data']).to eq([
        { "type" => "bears",
          "id" => "1",
          "attributes" => {
            'name' => 'Tenderheart',
            'gender' => 'male',
            'belly_badge' => 'heart',
            'fur_color' => 'tan' }}]
      )
    end
  end

end
