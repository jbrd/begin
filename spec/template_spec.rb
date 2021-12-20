# frozen_string_literal: true

require 'spec_helper'

describe Begin::Template do
  it 'copies file with tags in name' do
    Dir.mktmpdir do |source|
      source_path = Begin::Path.new source, '.', 'src dir'
      Dir.mktmpdir do |dest|
        dest_path = Begin::Path.new dest, '.', 'dest dir'
        template = Begin::Template.new source_path
        File.write File.join(source_path, '{{foo}}'), 'abc'
        context = { 'foo' => 'bar' }
        template.run dest_path, context
        dest_file = Begin::Path.new('bar', dest_path, 'dest file')
        dest_file.ensure_exists
        expect(File.read(dest_file)).to eq 'abc'
      end
    end
  end
end

describe Begin::Template do
  it 'copies file with tags in parent directory name' do
    Dir.mktmpdir do |source|
      source_path = Begin::Path.new source, '.', 'src dir'
      source_subdir_path = Begin::Path.new '{{foo}}', source_path, 'src subdir'
      source_subdir_path.make_dir
      Dir.mktmpdir do |dest|
        dest_path = Begin::Path.new dest, '.', 'dest dir'
        template = Begin::Template.new source_path
        File.write File.join(source_subdir_path, '{{foo}}'), 'abc'
        context = { 'foo' => 'bar' }
        template.run dest_path, context
        dest_file = Begin::Path.new('bar/bar', dest_path, 'dest file')
        dest_file.ensure_exists
        expect(File.read(dest_file)).to eq 'abc'
      end
    end
  end
end

describe Begin::Template do
  it 'fails to process file if tag results in empty file name' do
    Dir.mktmpdir do |source|
      source_path = Begin::Path.new source, '.', 'src dir'
      Dir.mktmpdir do |dest|
        dest_path = Begin::Path.new dest, '.', 'dest dir'
        template = Begin::Template.new source_path
        File.write File.join(source_path, '{{foo}}'), 'abc'
        context = { 'foo' => '' }
        expect { template.run(dest_path, context) }.to raise_error
      end
    end
  end
end

describe Begin::Template do
  it 'fails to process directory if tag results in empty directory name' do
    Dir.mktmpdir do |source|
      source_path = Begin::Path.new source, '.', 'src dir'
      subdir_path = Begin::Path.new '{{foo}}', source_path, 'src subdir'
      subdir_path.make_dir
      Dir.mktmpdir do |dest|
        dest_path = Begin::Path.new dest, '.', 'dest dir'
        template = Begin::Template.new source_path
        context = { 'foo' => '' }
        expect { template.run(dest_path, context) }.to raise_error
      end
    end
  end
end
