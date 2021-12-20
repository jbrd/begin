# frozen_string_literal: true

require 'spec_helper'

describe Begin::Path do
  it 'iterates directory contents' do
    Dir.mktmpdir do |d|
      path = Begin::Path.new d, '.', 'temp dir'
      File.write File.join(path, 'a'), 'abc'
      File.write File.join(path, '[b]'), 'def'
      File.write File.join(path, '{c}'), 'ghi'
      expect(path.directory?).to eq true
      s = Set.new
      path.dir_contents.each { |x| s.add(x) }
      expect(s.include?(Begin::Path.new('a', path, 'a'))).to eq true
      expect(s.include?(Begin::Path.new('[b]', path, '[b]'))).to eq true
      expect(s.include?(Begin::Path.new('{c}', path, '{c}'))).to eq true
      expect(s.length).to eq 3
    end
  end
end
