require 'yaml'

module Begin
  # The root-level template configuration structure. A class representation
  # of the template config file (.begin.yml)
  class Config
    @tags = []

    attr_reader :tags

    def initialize(tags)
      @tags = tags
    end

    def self.from_file(path)
      if path.exists?
        config = YAML.load_file path
        tags = HashTag.from_config_hash(config)
        Config.new tags
      else
        {}
      end
    end
  end

  # Represents an expected mustache tag, as defined in the template config.
  # Every type of tag has a key name (as inserted into the mustache context),
  # and a human-readable label (as presented to the user).
  class Tag
    @key = ''
    @label = ''
    @array = false

    attr_reader :key
    attr_reader :label
    attr_reader :array

    def initialize(key, label, array)
      @key = key
      @label = label
      @array = array
    end

    def self.from_config(key, value)
      return HashTag.from_config(key, value) if value.include? 'tags'

      ValueTag.from_config(key, value)
    end
  end

  # Represents a tag with a single value. Value tags can have a default value
  # assigned in the config. If the user chooses not to enter a value, the
  # default value is substituted instead.
  class ValueTag < Tag
    @default = ''

    attr_reader :default

    def initialize(key, label, array, default)
      super key, label, array
      @default = default
    end

    def self.from_config(key, value)
      array = value.include?('array') ? value['array'] : false
      label = value.include?('label') ? value['label'] : key
      default = value.include?('default') ? value['default'] : ''
      ValueTag.new key, label, array, default
    end
  end

  # Represents a nested object hash tag. On encountering a hash tag, the user
  # is prompted to enter a value for each member of the hash.
  class HashTag < Tag
    @children = []

    attr_reader :children

    def initialize(key, label, array, children)
      super key, label, array
      @children = children
    end

    def self.from_config_hash(config)
      return [] unless config.include?('tags') && config['tags'].is_a?(Hash)

      config['tags'].each.map do |key, value|
        raise "Invalid template. Expected value of '#{key}' to be a Hash" \
          unless value.is_a? Hash

        Tag.from_config key, value
      end
    end

    def self.from_config(key, value)
      array = value.include?('array') ? value['array'] : false
      label = value.include?('label') ? value['label'] : key
      children = value.include?('tags') ? from_config_hash(value) : []
      HashTag.new key, label, array, children
    end
  end
end
