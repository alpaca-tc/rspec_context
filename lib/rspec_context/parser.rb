module RSpecContext
  class Parser
    EXAMPLE_GROUP_METHODS = %i[
      example_group
      describe
      context

      fdescribe
      xdescribe

      fcontext
      xcontext

      specify
      fspecify
      xspecify
    ]

    INCLUDE_CONTEXT_METHODS = %i[
      include_context
      include_examples
    ]

    SHARED_GROUP_METHODS = %i[
      it_behaves_like
      it_should_behave_like
    ]

    EXAMPLE_METHODS = %i[
      example
      it
      specify

      fexample
      fit
      fspecify

      xexample
      xit
      xspecify

      skip
      pending
    ]

    MEMORIZED_METHODS = %i[
      subject
      let
      let!
    ]

    def self.parse_spec_file(spec_file)
      new(spec_file).parse
    end

    def initialize(spec_file)
      @spec_file = spec_file
    end

    def parse
      rspec_methods = EXAMPLE_GROUP_METHODS + EXAMPLE_METHODS + INCLUDE_CONTEXT_METHODS + SHARED_GROUP_METHODS + MEMORIZED_METHODS
      filter = /^\s*(?<rspec_prefix>RSpec\.)?(?<method_name>#{rspec_methods.join('|')})/

      candidates = []
      @spec_file.content_lines.each_with_index do |line, line_no|
        next unless line.match(filter)

        rspec_prefix = Regexp.last_match[:method_name].nil?
        method_name = Regexp.last_match[:method_name]
        type = find_type(method_name)

        candidate = Candidate.new(@spec_file, type, method_name, line_no, rspec_prefix: rspec_prefix)
        candidates.push(candidate)
      end

      candidates
    end

    private

    def type_map
      @type_map ||= {}.tap do |map|
        EXAMPLE_GROUP_METHODS.each do |method_name|
          map[method_name] = :example_group_method
        end

        INCLUDE_CONTEXT_METHODS.each do |method_name|
          map[method_name] = :include_context
        end

        SHARED_GROUP_METHODS.each do |method_name|
          map[method_name] = :shared_group_method
        end

        EXAMPLE_METHODS.each do |method_name|
          map[method_name] = :example_method
        end

        MEMORIZED_METHODS.each do |method_name|
          map[method_name] = :memorized_method
        end
      end
    end

    def find_type(method_name)
      type_map[method_name.to_sym]
    end
  end
end
