require 'thor'

module MilkMaid
  class CLI < Thor
    desc 'monitor_batch', "Start Monitoring a batch"
    long_desc <<-DESC

    `monitor_batch BATCH_NAME` will create a batch called BATCH_NAME
    and begin monitoring it for 30 minutes

    DESC
    option :batch_name, :type => :string, :aliases => "-b"
    option :temperature, :type => :numeric, :required => :false, :default => 30, :aliases => '-t'
    option :duration, :type => :numeric, :required => false, :default => 30, :aliases => '-d'
    option :logger, :type => :string, :required => false, :default => 'Spreadsheet', :aliases => '-l'
    option :sensor, :type => :boolean, :required => false, :default => true, :aliases => '-s'
    option :nap, :type => :numeric, :required => false, :default => 5, :aliases => '-n'
    def monitor_batch
      batch_name = options.fetch(:batch_name, default_batch_name)
      temperature = options[:temperature].to_f
      duration = options[:duration].to_i * 60
      logger_type = options[:logger]
      sensor_type = options[:sensor]
      nap_time = options[:nap].to_i

      sensor = get_sensor(sensor_type)
      notifier = get_logger(logger_type)
      batch = ::MilkMaid::Batch.new(name: batch_name, temperature: temperature, duration: duration, notifier: notifier, sensor: sensor, nap_time: nap_time)

      puts batch.inspect

      batch.start
    rescue ::MilkMaid::SensorException => e
      puts e.message
    end

    default_task :monitor_batch

    no_commands do
      def default_batch_name
        Time.now.strftime("Batch-%Y-%m-%d %H:%M:%S")
      end

      def get_sensor(sensor_type)
        sensor_type ? ::MilkMaid::TemperatureSensor.new : ::MilkMaid::MockTemperatureSensor.new(options[:temperature].to_f - 20, options[:temperature].to_f + 30)
      end

      def get_logger(logger_type)
        case logger_type.upcase
        when 'CONSOLE'
          ::MilkMaid::ConsoleNotifier.new
        when 'WEB'
          ::MilkMaid::ParseNotifier.new
        when 'SPREADSHEET'
          ::MilkMaid::GoogleSheetNotifier.new
        end
      end
    end
  end
end
