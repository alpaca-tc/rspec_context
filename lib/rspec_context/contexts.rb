module RSpecContext
  class Contexts
    attr_reader :spec_file

    class << self
      def from_spec_file(spec_file)
        contexts = spec_file.candidates.map do |candidate|
          Context.from_candidate(spec_file, candidate)
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
