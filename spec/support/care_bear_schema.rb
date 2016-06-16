shared_context 'care_bear_schema' do
  let(:care_bear_schema) {
    { 'bears' => {
        'resource' => 'bears',
        'attributes' => ['name', 'bellySymbol', 'furColor'],
        'relationships' => {
          'one' => ['home'],
          'many' => ['powers']
        }
      },
      'homes' => {
        'resource' => 'homes',
        'attributes' => ['name', 'location', 'caringMeter'],
        'readonly_attributes' => [],
        'relationships' => {
          'one' => [],
          'many' => ['bears']
        }
      },
      'powers' => {
        'resource' => 'powers',
        'attributes' => ['name', 'description'],
        'readonly_attributes' => [],
        'relationships' => {
          'one' => [],
          'many' => ['bears']
        }
      }
    }
  }
end