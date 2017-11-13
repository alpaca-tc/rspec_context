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
      @contexts ||= Contexts.from_spec_file(self)
    end

    def rspec_methods
      @rspec_methods ||= Parser.parse_spec_file(self)
    end

    def inspect
      "#<#{self.class}:#{@file_path}>"
    end

    def to_s
      "#<#{self.class}:#{@file_path}>"
    end
  end
end
