# frozen_string_literal: true

module RSpecContext
  class Parser
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

    def self.parse_spec_file(spec_file)
      instance = new(spec_file)
      instance.build_nodes(instance.parse_rspec_methods)
    end

    def initialize(spec_file)
      @spec_file = spec_file
    end

    def build_nodes(rspec_methods)
      ancending = rspec_methods.sort_by(&:line_no)
      nodes = ancending.map { |rspec_method| Node.new(rspec_method) }

      nodes.each do |node|
        children = nodes.select { |child_node| node.rspec_method.cover?(child_node.rspec_method) && node != child_node }

        children.each do |child_node|
          next if !child_node.parent.nil? && node.rspec_method.line_no < child_node.parent.rspec_method.line_no
          child_node.parent = node
        end
      end

      by_parent = nodes.group_by(&:parent)
      nodes.each do |node|
        children = by_parent[node]
        next unless children

        node.children = children.sort_by { |child_node| child_node.rspec_method.line_no }
      end

      nodes.select { |node| node.parent.nil? }
    end

    def parse_rspec_methods
      rspec_methods = EXAMPLE_GROUP_METHODS + EXAMPLE_METHODS + INCLUDE_CONTEXT_METHODS + SHARED_GROUP_METHODS + MEMORIZED_METHODS
      filter = /^\s*(?<rspec_prefix>RSpec\.)?(?<method_name>#{rspec_methods.join('|')})/

      rspec_methods = []
      @spec_file.content_lines.each_with_index do |line, line_no|
        next unless line.match(filter)

        rspec_prefix = !Regexp.last_match[:method_name].nil?
        method_name = Regexp.last_match[:method_name]
        type = find_type(method_name)

        rspec_method = RSpecMethod.new(@spec_file, type, method_name, line_no, rspec_prefix: rspec_prefix)
        rspec_methods.push(rspec_method)
      end

      rspec_methods
    end

    private

    def type_map
      @type_map ||= {}.tap do |map|
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
      end
    end

    def find_type(method_name)
      type_map[method_name.to_sym]
    end
  end
end
