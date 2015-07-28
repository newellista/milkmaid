require 'spec_helper'

describe ::Milkmaid::TemperatureSensor do
  before do
    allow_any_instance_of(Temperature).to receive(:display).and_return('TEST_SENSOR')
    allow_any_instance_of(Temperature).to receive(:name).and_return("SENSOR1")
    allow_any_instance_of(Temperature).to receive(:reading).and_return(40)
  end

  let(:sensor) { ::Milkmaid::TemperatureSensor.new }

  context 'test sensor' do
    it 'has a name' do
      expect(sensor.name).to eq("SENSOR1")
    end

    it 'reads a temperature' do
      expect(sensor.reading).to eq(40)
    end
  end
end
