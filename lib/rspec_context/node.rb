# frozen_string_literal: true

module RSpecContext
  class Node
    attr_accessor :rspec_method, :parent, :children

    def initialize(rspec_method, parent: nil, children: [])
      @rspec_method = rspec_method
      @parent = parent
      @children = children
    end
  end
end
