require 'parse-ruby-client'

module Milkmaid
  module FirebaseNotifier
    class BatchRecord
      attr_accessor :name, :guid, :duration, :base_temperature, :batch_size, :status, :record

      CACHE_THRESHOLD = 20

      def initialize(batch_data = {})
        @firebase = ::Firebase::Client.new('https://blistering-inferno-5605.firebaseio.com/')

        batch_data.each { |key, value| send("#{key}=", value) }
        @status = 'Started'

        self.create_remote_record
      end

      def create_remote_record
        @response = @firebase.push("batches", {
          :guid => guid,
          :name => name,
          :duration => duration,
          :base_temperature => base_temperature,
          :batch_size => batch_size,
          :status => status
        })
      end

      def add_event(event_type, data = 0)
        events << ::Milkmaid::FirebaseNotifier::Event.new(name: event_name_from_type(event_type), data: data, timestamp: timestamp)
        return if cache_event(event_type)
        send_events!
      end

      def cache_event
        return false unless event_type == :temperature
        return false if @events.length < CACHE_THRESHOLD
        true
      end

      def close_batch
        @firebase.update("/batches/#{guid}", :status => 'Completed')
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
          @firebase.update("/batches/#{guid}/events", event)
        end

        @events = []
      end

      def timestamp
        Time.now
      end
    end

    class Event < Struct(:name, :data, :timestamp)
    end
  end
end
