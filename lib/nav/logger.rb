require "fluent-logger"
require "request_store"
require "logger"
require "socket"

require "nav/logger/base_logger"
require "nav/logger/console_logger"
require "nav/logger/default_logger"
require "nav/logger/test_logger"
require "nav/logger/version"

module Nav
  module_function

  def logger
    @logger ||= create_logger
  end

  def logger=(new_logger)
    @logger = new_logger
  end

  def create_logger
    environment = ENV["RACK_ENV"] || ENV["APP_ENV"] || "development"

    case environment
    when "development"
      Logger::ConsoleLogger.new
    when "test"
      Logger::TestLogger.new
    else
      Logger::DefaultLogger.new
    end
  end
end