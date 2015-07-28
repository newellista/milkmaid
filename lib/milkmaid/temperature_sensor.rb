require 'w1temp'

module Milkmaid
  class SensorException < RuntimeError; end

  class TemperatureSensor
    def initialize
      @sensor = Temperature.new

      fail ::Milkmaid::SensorException.new 'Sensor not available' unless @sensor.display
    end

    def name
      return "No sensor attached" unless @sensor.display
      @sensor.name
    end

    def reading
      return "No sensor attached" unless @sensor.display
      @sensor.reading
    end
  end

  class MockTemperatureSensor
    def initialize(low_temp, high_temp)
      @low_temp = low_temp.to_i
      @high_temp = high_temp.to_i
    end

    def name
      'MockTemperatureSensor'
    end

    def reading
      rand(@low_temp..@high_temp)
    end
  end
end
