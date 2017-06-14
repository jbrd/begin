require 'spec_helper'

describe Begin::Path do
  it 'iterates directory contents' do
    Dir.mktmpdir do |d|
      path = Begin::Path.new d, '.', 'temp dir'
      File.write File.join(path, 'a'), 'abc'
      File.write File.join(path, '[b]'), 'def'
      File.write File.join(path, '{c}'), 'ghi'
      expect path.directory?
      s = Set.new
      path.dir_contents.each { |x| s.add(x) }
      expect s.include?('a')
      expect s.include?('[b]')
      expect s.include?('{c}')
      expect s.length == 3
    end
  end
end
