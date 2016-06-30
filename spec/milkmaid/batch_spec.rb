require 'spec_helper'

describe ::MilkMaid::Batch do
  before do
    allow_any_instance_of(Temperature).to receive(:display).and_return('TEST_SENSOR')
    allow_any_instance_of(Temperature).to receive(:name).and_return("SENSOR1")
    allow_any_instance_of(Temperature).to receive(:reading).and_return(40)
  end

  let(:sensor) { ::MilkMaid::TemperatureSensor.new }

  context 'temperature stays steady' do
    it 'logs temperatures' do
      notifier = double('Notifier')

      batch = ::MilkMaid::Batch.new(
        name: 'Test Batch',
        temperature: 40,
        duration: 5,
        notifier: notifier,
        sensor: sensor,
        nap_time: 5
      )

      expect(notifier).to receive(:batch_started)
      expect(notifier).to receive(:temperature_reached)
      expect(notifier).to receive(:log_temperature).with(40).at_least(:once)
      expect(notifier).to receive(:batch_completed)
      expect(notifier).to receive(:post_warning).exactly(0).times

      batch.start
    end
  end

  context 'temperature drops below threshold' do
    it 'posts a warning' do
      notifier = double('Notifier')

      batch = ::MilkMaid::Batch.new(
        name: 'Test Batch',
        temperature: 40,
        duration: 5,
        notifier: notifier,
        sensor: sensor,
        nap_time: 5
      )

      allow(sensor).to receive(:reading).and_return(30)
      allow(batch).to receive(:compare_temperature).and_return(true)

      expect(notifier).to receive(:batch_started)
      expect(notifier).to receive(:temperature_reached)
      expect(notifier).to receive(:log_temperature).with(30).at_least(:once)
      expect(notifier).to receive(:batch_completed)
      expect(notifier).to receive(:post_warning).with(30, 40).at_least(1).times

      batch.start
    end
  end
end
