# frozen_string_literal: true

module RSpecContext
  class SpecFile
    def initialize(file_path)
      @file_path = file_path
    end

    def content_lines
      @content ||= File.read(@file_path).split("\n")
    end

    def contexts
      @contexts ||= nodes.map { |node| Context.new(node) }
    end

    def nodes
      @nodes ||= NodeBuilder.new(rspec_methods).build_nodes
    end

    def rspec_methods
      @rspec_methods ||= Parser.new(self).parse_spec_file
    end

    def inspect
      "#<#{self.class}:#{@file_path}>"
    end

    def to_s
      "#<#{self.class}:#{@file_path}>"
    end
  end
end
