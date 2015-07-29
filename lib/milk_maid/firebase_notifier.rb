module MilkMaid
  class FirebaseNotifier < ::MilkMaid::ConsoleNotifier
    attr_accessor :batch_record

    def batch_completed
      super
      batch_record.complete!
    end

    def batch_started(batch_data = {})
      super(batch_data)
      batch_record = ::MilkMaid::FirebaseNotifier::BatchRecord.new(batch_data)
    end

    def log_temperature(temperature)
      super(temperature)
      batch_record.add_event(:temperature, temperature)
    end

    def post_warning(current_temperature, base_temperature)
      super(current_temperature, base_temperature)
      batch_record.add_event(:temperature_warning, current_temperature)
    end

    def temperature_reached
      super
      batch_record.add_event(:threshold_reached)
    end

  end
end
