module RspecContext
  class Node
    attr_accessor :candidate, :parent, :children

    def initialize(candidate, parent: nil, children: [])
      @candidate = candidate
      @parent = parent
      @children = children
    end
  end
end
