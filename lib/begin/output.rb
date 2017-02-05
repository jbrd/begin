require 'colorize'

module Begin
  # All console output is routed through this module ensuring
  # it is formatted consistently
  module Output
    module_function

    def error(value)
      puts "ERROR: #{value}".colorize :red
    end

    def warning(value)
      puts "WARNING: #{value}".colorize :yellow
    end

    def action(value)
      puts value
    end

    def success(value)
      puts value.colorize :green
    end
  end
end
