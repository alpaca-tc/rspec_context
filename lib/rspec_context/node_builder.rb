# frozen_string_literal: true

module RSpecContext
  class NodeBuilder
    def initialize(rspec_methods)
      @rspec_methods = rspec_methods.sort_by(&:line_no)
    end

    def build_nodes
      nodes = @rspec_methods.map { |rspec_method| Node.new(rspec_method) }

      nodes.each do |node|
        nodes.each do |child_node|
          next if node == child_node
          next unless node.rspec_method.cover?(child_node.rspec_method)
          next if !child_node.parent.nil? && node.rspec_method.line_no < child_node.parent.rspec_method.line_no

          child_node.parent = node
        end
      end

      parent_with_children = nodes.group_by(&:parent)

      nodes.each do |node|
        children = parent_with_children[node]
        next unless children

        node.children = children.sort_by { |child_node| child_node.rspec_method.line_no }
      end

      nodes
    end
  end
end
