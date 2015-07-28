require 'milkmaid/batch'
require 'milkmaid/cli'
require 'milkmaid/console_notifier'
require 'milkmaid/parse_notifier'
require 'milkmaid/remote_notifier/batch_record'
require 'milkmaid/firebase_notifier/batch_record'
require 'milkmaid/temperature_sensor'
require 'milkmaid/version'

CONFIG_DIR = File.join(File.dirname(__FILE__), '..', 'config')

module Milkmaid
end
