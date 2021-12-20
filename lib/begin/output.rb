# frozen_string_literal: true

require 'colorize'

module Begin
  # All console output is routed through this module ensuring
  # it is formatted consistently
  module Output
    module_function

    def error(value)
      warn "ERROR: #{value}".colorize :red
    end

    def warning(value)
      STDOUT.puts "WARNING: #{value}".colorize :yellow
    end

    def info(value)
      STDOUT.puts value
    end

    def action(value)
      STDOUT.puts "#{value}..."
    end

    def success(value)
      STDOUT.puts value.colorize :green
    end

    def newline
      STDOUT.puts ''
    end
  end
end
