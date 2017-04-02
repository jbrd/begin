module Begin
  # All console input is routed through this module
  module Input
    module_function

    def prompt(msg)
      STDOUT.write msg
      begin
        return STDIN.gets.chomp
      rescue Interrupt
        STDOUT.puts ''
        raise
      end
    end
  end
end
