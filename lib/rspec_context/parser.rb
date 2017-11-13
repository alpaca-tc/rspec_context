# frozen_string_literal: true

module RSpecContext
  class Parser
    def initialize(spec_file)
      @spec_file = spec_file
    end

    def parse_spec_file
      rspec_methods = [
        RSpecMethod::EXAMPLE_GROUP_METHODS,
        RSpecMethod::EXAMPLE_METHODS,
        RSpecMethod::INCLUDE_CONTEXT_METHODS,
        RSpecMethod::SHARED_GROUP_METHODS,
        RSpecMethod::MEMORIZED_METHODS
      ].flatten

      filter = /^\s*(?<rspec_prefix>RSpec\.)?(?<method_name>#{rspec_methods.join('|')})/

      rspec_methods = []
      @spec_file.content_lines.each_with_index do |line, line_no|
        next unless line.match(filter)

        rspec_prefix = !Regexp.last_match[:method_name].nil?
        method_name = Regexp.last_match[:method_name]

        rspec_method = RSpecMethod.new(@spec_file, method_name, line_no, rspec_prefix: rspec_prefix)
        rspec_methods.push(rspec_method)
      end

      rspec_methods
    end
  end
end
