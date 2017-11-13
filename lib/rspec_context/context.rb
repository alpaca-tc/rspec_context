# frozen_string_literal: true

require 'json'

module RSpecContext
  class Context
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def tree
      node.to_h
    end

    # rubocop:disable all
    def to_context_hash
      parent_node = node

      example_group_methods = []
      include_contexts = []
      shared_group_methods = {}
      example_methods = []
      memorize_methods = {}

      while parent_node
        case parent_node.rspec_method.type
        when :example_group_method
          example_group_methods.unshift(parent_node.to_h)
        when :example_method
          example_methods.unshift(parent_node.to_h)
        end

        parent_node.children.each do |child_node|
          case child_node.rspec_method.type
          when :memorized_method
            memorize_methods[child_node.rspec_method.name] ||= child_node.to_h
          when :shared_group_method
            shared_group_methods[child_node.rspec_method.name] ||= child_node.to_h
          when :include_context
            include_contexts.unshift(child_node.to_h)
          end
        end

        parent_node = parent_node.parent
      end

      {
        example_group_methods: example_group_methods,
        include_contexts: include_contexts,
        shared_group_methods: shared_group_methods,
        example_methods: example_methods,
        memorize_methods: memorize_methods
      }
    end
    # rubocop:enable all
  end
end
