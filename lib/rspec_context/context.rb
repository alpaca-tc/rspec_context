# frozen_string_literal: true

module RSpecContext
  class Context
    class << self
      def from_rspec_method(spec_file, rspec_method)
        binding.pry
        nested_rspec_methods = spec_file.rspec_methods.each { |_rspec_method| _rspec_method.cover?(rspec_method) && _rspec_method != rspec_method }
        nested_rspec_methods.sort_by! { |_rspec_method| _rspec_method.range.begin }

        new(spec_file, rspec_method, nested_rspec_methods)
      end
    end

    attr_reader :spec_file, :rspec_method, :nested_rspec_methods

    def initialize(spec_file, rspec_method, nested_rspec_methods)
      @spec_file = spec_file
      @rspec_method = rspec_method
      @nested_rspec_methods = nested_rspec_methods
    end

    def to_context_hash
      binding.pry
      # {
      #   it: [1],
      #   before: [1, 1],
      #   context: [1],
      #   describe: [1],
      #   let: [1, 1, 1, 1]
      # }
    end
  end
end
