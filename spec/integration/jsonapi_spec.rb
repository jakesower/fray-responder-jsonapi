RSpec.describe Fray::Responder::Jsonapi do
  include_context 'care_bear_schema'

  let(:responder) {
    Fray::Responder::Jsonapi.build(care_bear_schema)
  }

  context "with an empty response" do
    let(:dataset) {
      Fray::Data::Dataset.new(
        resource_type: 'bears',
        resources: []
      )
    }

    it 'responds with an empty jsonapi response' do
      result = responder.(dataset)
      expect(result).to eq({
        'data' => []
      })
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
                'bears' => [ '1', '2', '3' ]}}},
          'powers' => {
            '1' => {
              attributes: {
                'name' => 'Care Bear Stare',
                'description' => 'Powerful attack with a caring beam.'},
              relationships: {
                'bears' => [ '1', '2', '3' ]}},
            '2' => {
              attributes: {
                'name' => 'Magic Mirror',
                'description' => 'Spy on others, cast spells, check hair.'}}}},
        meta: {}
      )
    }

  end

end
