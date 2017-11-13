# frozen_string_literal: true

module RSpecContext
  class Parser
    def initialize(spec_file)
      @spec_file = spec_file
    end

    def parse_spec_file
      method_extractor = /^\s*(?<rspec_prefix>RSpec\.)?(?<method_name>#{rspec_method_names.join('|')})/
      rspec_methods = []

      @spec_file.content_lines.each_with_index do |line, line_no|
        next unless line.match(method_extractor)

        rspec_prefix = !Regexp.last_match[:method_name].nil?
        method_name = Regexp.last_match[:method_name]

        rspec_method = RSpecMethod.new(@spec_file, method_name, line_no, rspec_prefix: rspec_prefix)
        rspec_methods.push(rspec_method)
      end

      rspec_methods
    end

    private

    def rspec_method_names
      [
        RSpecMethod::EXAMPLE_GROUP_METHODS,
        RSpecMethod::EXAMPLE_METHODS,
        RSpecMethod::INCLUDE_CONTEXT_METHODS,
        RSpecMethod::SHARED_GROUP_METHODS,
        RSpecMethod::MEMORIZED_METHODS
      ].flatten
    end
  end
end
