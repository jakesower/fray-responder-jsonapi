RSpec.describe Fray::Responder::Jsonapi do
  context "with a straightforward response" do
    let(:dataset) {
      Fray::Data::Dataset.new(
        resource_type: 'bears',
        resources: [
          { id: '1',
            type: 'bears',
            attributes: {
              'name' => 'Tenderheart',
              'belly_symbol' => 'heart',
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
                'bears' => { '1', '2', '3' }}}}
          'powers' => {
            '1' => {
              attributes: {
                'name' => 'Care Bear Stare',
                'description' => 'Powerful attack with a caring beam.'},
              relationships: {
                'bears' => { '1', '2', '3' }}},
            '2' => {
              attributes: {
                'name' => 'Magic Mirror',
                'description' => 'Spy on others, cast spells, look at self.'}}}},
        meta: {}
      )
    }

  end


end
