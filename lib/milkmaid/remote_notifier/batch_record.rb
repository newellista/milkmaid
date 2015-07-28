require 'parse-ruby-client'

module Milkmaid
  module RemoteNotifier
    class BatchRecord
      attr_accessor :name, :guid, :duration, :base_temperature, :batch_size, :status, :record

      def initialize
        Parse.init(
          :application_id => 'JxuqdmEaI0DYwxcDV1imv2S64PWMLNjJq3wpGcVC',
          :api_key => 'dsEh8Uqc3gwT9kYcG6OvR9W6pRlzcZlG6X9NeClS'
        )
      end

      def start(batch_data = {})
        batch_data.each { |key, value| send("#{key}=", value) }
        @status = 'Started'
        self.create_remote_record
      end

      def create_remote_record
        @record = ::Parse::Object.new('BatchRecords')
        @record[:name] = name
        @record[:guid] = guid
        @record[:duration] = duration
        @record[:base_temperature] = base_temperature
        @record[:batch_size] = batch_size
        @record[:status] = status

        @record.save
      end

      def add_event(event_type, data = 0)
        events << ::Milkmaid::RemoteNotifier::Event.new(name: event_name_from_type(event_type), data: data, timestamp: timestamp)
        return if event_type == :temperature
        send_events!
      end

      def close_batch
        @record[:status] = 'Completed'
        @record.save
      end

      def complete!
        add_event(:batch_completed)
        close_batch
      end

      def event_name_from_type(event)
        event.to_s.split(/_/).map(&:capitalize).join(' ')
      end

      def events
        @events ||= []
      end

      def send_events!
        events.each do |event|
          event.save
          @record.array_add_relation("BatchRecordEvents", event.pointer)
          @record.save
        end

      end

      def timestamp
        Time.now
      end
    end

    class Event < ::Parse::Object
      def initialize(params = {})
        super('Events')
        self[:name] = params.fetch(:name)
        self[:data] = params.fetch(:data)
        self[:timestamp] = params.fetch(:timestamp)
      end
    end
  end
end
