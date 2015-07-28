module Milkmaid
  class ConsoleNotifier
    def batch_completed
      puts "#{Time.now} - Batch Completed"
    end

    def batch_started(_)
      puts "#{Time.now} - Batch Started"
    end

    def log_temperature(temperature)
      puts "#{Time.now} - Temperature reading: #{temperature}"
    end

    def post_warning(current_temperature, base_temperature)
      puts "#{Time.now} - WARNING: Current Temperature: #{current_temperature} Base Temperature: #{base_temperature}"
    end

    def temperature_reached
      puts "#{Time.now} - Temperature reached!"
    end
  end
end
