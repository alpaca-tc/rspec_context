# frozen_string_literal: true

module RSpecContext
  class RSpecMethod
    EXAMPLE_GROUP_METHODS = %i[
      example_group
      describe
      context

      fdescribe
      xdescribe

      fcontext
      xcontext

      specify
      fspecify
      xspecify
    ].freeze

    INCLUDE_CONTEXT_METHODS = %i[
      include_context
      include_examples
    ].freeze

    SHARED_GROUP_METHODS = %i[
      it_behaves_like
      it_should_behave_like
    ].freeze

    EXAMPLE_METHODS = %i[
      example
      it
      specify

      fexample
      fit
      fspecify

      xexample
      xit
      xspecify

      skip
      pending
    ].freeze

    MEMORIZED_METHODS = %i[
      subject
      let
      let!
    ].freeze

    METHOD_TYPE_MAP = {}.tap { |map|
      EXAMPLE_GROUP_METHODS.each do |method_name|
        map[method_name] = :example_group_method
      end

      INCLUDE_CONTEXT_METHODS.each do |method_name|
        map[method_name] = :include_context
      end

      SHARED_GROUP_METHODS.each do |method_name|
        map[method_name] = :shared_group_method
      end

      EXAMPLE_METHODS.each do |method_name|
        map[method_name] = :example_method
      end

      MEMORIZED_METHODS.each do |method_name|
        map[method_name] = :memorized_method
      end
    }.freeze

    attr_reader :spec_file, :method_name, :line_no, :rspec_prefix

    def initialize(spec_file, method_name, line_no, rspec_prefix: false)
      @spec_file = spec_file
      @method_name = method_name
      @line_no = line_no
      @rspec_prefix = rspec_prefix

      @broken = false
      range # check broken file
    end

    def name
      arguments[0]
    end

    def source
      indent = @spec_file.content_lines[line_no].match(/^\s*/)[0].length
      indent_remover = /^\s{#{indent}}/

      raw_body.map { |line| line.gsub(indent_remover, '') }.join("\n")
    end

    def arguments
      @arguments ||= if broken?
                       extract_arguments_with_regexp
                     else
                       extract_arguments_with_parser
                     end
    end

    def range
      @range ||= Range.new(line_no, end_line_no, false)
    end

    def cover?(other)
      range.begin <= other.range.begin && other.range.end <= range.end
    end

    def type
      METHOD_TYPE_MAP[method_name.to_sym]
    end

    def broken?
      @broken
    end

    def inspect
      %{#<#{self.class} #{method_name}(#{name}) #{range}>}
    end

    def to_h
      {
        name: name,
        arguments: arguments,
        method_name: method_name,
        type: type,
        begin: range.begin,
        end: range.end,
        broken: broken?
      }
    end

    private

    def raw_body
      @spec_file.content_lines[range]
    end

    def extract_arguments_with_parser
      require 'parser/current'
      expression = ::Parser::CurrentRuby.parse(source)

      nodes = [expression]

      while node = nodes.shift
        if node.type == :send && node.children[1] == method_name.to_sym
          arguments = node.children[2..-1]
          return arguments.map { |argument| strip_string_literal(argument.location.expression.source) }
        else
          nodes += node.children
        end
      end

      []
    end

    def strip_string_literal(string)
      string_literal = /("|')/
      string.gsub(/^#{string_literal}/, '').gsub(/#{string_literal}$/, '')
    end

    def extract_arguments_with_regexp
      Regexp.last_match[1].strip if /\A#{method_name}(.*?)(?:{|do)/ =~ raw_body[0].strip
    end

    def end_line_no
      current_line_no = line_no

      while current_line_no < @spec_file.content_lines.length
        script = @spec_file.content_lines[line_no..current_line_no].join("\n")
        return current_line_no if RubyCompiler.can_compile?(script)
        current_line_no += 1
      end

      @broken = true
      line_no
    end
  end
end
