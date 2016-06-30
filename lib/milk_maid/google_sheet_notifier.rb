module MilkMaid
  class GoogleSheetNotifier < ::MilkMaid::ConsoleNotifier
    attr_accessor :batch_record

    def batch_completed
      super
      batch_record.complete!
      ::MilkMaid::SpreadsheetWriter.write_spreadsheet("./session.json", "Pasteurization Batch #{Time.now}", batch_record)
    end

    def batch_started(batch_data = {})
      super(batch_data)
      @batch_record = ::MilkMaid::BatchRecord.new(batch_data)
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

  class BatchRecord
    attr_accessor :name, :guid, :duration, :base_temperature, :batch_size, :status, :record

    def initialize(batch_data = {})
      batch_data.each { |key, value| send("#{key}=", value) }
      @status = 'Started'
    end

    def add_event(event_type, data = 0)
      events << ::MilkMaid::Event.new(event_name_from_type(event_type), data, timestamp)
    end

    def complete!
      add_event(:batch_completed)
      @status = 'Completed'
    end

    def event_name_from_type(event)
      event.to_s.split(/_/).map(&:capitalize).join(' ')
    end

    def events
      @events ||= []
    end

    def timestamp
      Time.now
    end
  end

  class Event < Struct.new(:name, :data, :timestamp)
  end
end
