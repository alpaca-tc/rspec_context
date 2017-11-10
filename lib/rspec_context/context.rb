module RSpecContext
  class Context
    class << self
      def from_candidate(spec_file, candidate)
        nested_candidates = spec_file.candidates.each { |_candidate| _candidate.cover?(candidate) && _candidate != candidate }
        nested_candidates.sort_by! { |_candidate| _candidate.range.begin }

        new(spec_file, candidate, nested_candidates)
      end
    end

    attr_reader :spec_file, :candidate, :nested_candidates

    def initialize(spec_file, candidate, nested_candidates)
      @spec_file = spec_file
      @candidate = candidate
      @nested_candidates = nested_candidates
    end

    def to_context_hash
      binding.pry;
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
