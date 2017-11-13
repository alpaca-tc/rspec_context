# frozen_string_literal: true

module RSpecContext
  class Contexts
    attr_reader :spec_file

    class << self
      def from_spec_file(spec_file)
        contexts = spec_file.rspec_methods.map do |rspec_method|
          Context.from_rspec_method(spec_file, rspec_method)
        end

        new(spec_file, contexts)
      end
    end

    attr_reader :spec_file, :contexts

    def initialize(spec_file, contexts = [])
      @spec_file = spec_file
      @contexts = contexts
    end
  end
end
