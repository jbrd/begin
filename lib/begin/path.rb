module Begin
  # The canonical file path representation used throughout the application.
  # Paths are immediately expanded into absolute file paths on construction
  class Path
    def initialize(path, parent_dir = nil)
      @path = File.expand_path path, parent_dir
    end

    def to_s
      @path
    end

    def to_str
      @path
    end
  end
end
