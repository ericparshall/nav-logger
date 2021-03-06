module Nav
  module Logger
    class BaseLogger
      attr_reader :fluent_logger

      def level
        return @level if defined? @level
        self.level = ENV["LOG_LEVEL"] || "info"
        @level
      end

      def level_name(lookup = level)
        ::Logger::SEV_LABEL[lookup]
      end

      def level_symbol
        level_name.downcase.to_sym
      end

      def level=(new_level)
        if new_level.is_a? Integer
          @level = new_level
        else
          lookup = new_level.to_s.upcase
          @level = ::Logger::SEV_LABEL.index lookup
        end
      end

      def debug(message, hash = {})
        add ::Logger::DEBUG, message, hash.dup
      end

      def info(message, hash = {})
        add ::Logger::INFO, message, hash.dup
      end

      def warn(message, hash = {})
        add ::Logger::WARN, message, hash.dup
      end

      def error(message, hash = {})
        add ::Logger::ERROR, message, hash.dup
      end

      def fatal(message, hash = {})
        add ::Logger::FATAL, message, hash.dup
      end

      def post(tag, hash)
        full_hash = generate_log_hash hash
        @fluent_logger.post tag, full_hash
      end

      def log_tag(secondary_tag)
        [app_tag, secondary_tag.downcase].compact.join "."
      end

      private

        def add(severity, message, hash)
          severity = severity.nil? ? ::Logger::UNKNOWN : severity.to_i
          return true if severity < level

          severity_name = level_name severity

          hash[:level] = severity_name
          hash[:message] = message

          log_hash = generate_log_hash hash

          @fluent_logger.post log_tag(severity_name), log_hash
        end

        def app_tag
          return @app_tag if defined? @app_tag
          @app_tag = defined?(::APP_PREFIX) ? ::APP_PREFIX.downcase : nil
        end

        def environment
          @environment ||= ENV["RACK_ENV"] || ENV["APP_ENV"] || "development"
        end

        def hostname
          @hostname ||= Socket.gethostname
        end

        def generate_log_hash(input = {})
          hash = input.merge RequestStore.store
          hash.merge! ts: Time.now.to_f,
                      environment: environment,
                      hostname: hostname,
                      pid: pid
        end

        def pid
          @pid ||= Process.pid
        end
    end
  end
end
