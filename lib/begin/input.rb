module Begin
  # All console input is routed through this module
  module Input
    module_function

    def prompt(msg)
      STDOUT.write msg
      begin
        value = STDIN.gets
        raise EOFError if value.nil?
        return value.chomp
      rescue
        STDOUT.puts ''
        raise
      end
    end

    def prompt_user_for_tag(tag, level = 0, in_array = false)
      indent = '  ' * level
      array_msg = in_array ? ' (CTRL+D to stop)' : ''
      case tag
      when HashTag
        Output.info "#{indent}#{tag.label}#{array_msg}:"
        prompt_user_for_tag_values tag.children, level + 1
      when ValueTag
        prompt "#{indent}#{tag.label}#{array_msg}: "
      end
    end

    def prompt_user_for_array_tag(tag, level = 0)
      result = []
      loop do
        begin
          value = prompt_user_for_tag tag, level, true
          result.push value
        rescue EOFError
          break
        end
      end
      result
    end

    def prompt_user_for_tag_values(tags, level = 0)
      context = {}
      tags.each do |x|
        context[x.key] = prompt_user_for_array_tag(x, level) if x.array
        context[x.key] = prompt_user_for_tag(x, level) unless x.array
      end
      context
    end
  end
end
