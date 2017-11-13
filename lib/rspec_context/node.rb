# frozen_string_literal: true

module RSpecContext
  class Node
    attr_accessor :rspec_method, :parent, :children

    def initialize(rspec_method, parent: nil, children: [])
      @rspec_method = rspec_method
      @parent = parent
      @children = children
    end

    def context
      @context ||= Context.new(self)
    end

    def top_node?
      parent.nil?
    end

    def to_h
      {
        rspec_method: rspec_method.to_h
      }
    end
  end
end
