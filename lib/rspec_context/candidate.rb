require 'ripper'

module RSpecContext
  class Candidate
    module CleanRoom
      def method_missing(*); end

      def const_missing(name)
        if name == :RSpec
          self
        else
          ::Class.new.tap do |klass|
            klass.extend(LikeString)
            klass.extend(CleanRoom)
            klass.__name = name

            const_set(name, klass)
          end
        end
      end
    end

    module LikeString
      def __name=(name)
        @__name = name
      end

      def to_s
        @__name.to_s
      end

      def inspect
        to_s
      end
    end

    attr_reader :spec_file, :type, :method_name, :line

    def initialize(spec_file, type, method_name, line)
      @spec_file = spec_file
      @method_name = method_name
      @type = type
      @line = line
    end

    def name
      arguments[0]
    end

    def strip_body
      indent = @spec_file.content_lines[line].match(/^\s*/)[0].length
      indent_remover = /^\s{#{indent}}/

      raw_body.map { |_line| _line.gsub(indent_remover, '') }.join("\n")
    end

    def raw_body
      @spec_file.content_lines[range]
    end

    def arguments
      @arguments ||= arguments_extractor.tap { |klass| klass.class_eval(raw_body.join("\n")) }.instance_variable_get(:@__args) || []
      binding.pry;
    end

    def range
      @range ||= Range.new(line, end_line, false)
    end

    def cover?(other)
      range.begin <= other.range.begin && other.range.end <= range.end
    end

    private

    def arguments_extractor
      @arguments_extractor ||= Class.new.tap do |klass|
        klass.extend(CleanRoom)

        klass.class_eval(<<-METHOD, __FILE__, __LINE__ + 1)
          def self.#{@method_name}(*args)
            @__args ||= args
          end
        METHOD
      end
    end

    def extract_name(string)
      /^\s*#{type}/
    end

    def end_line
      current_line = line

      while current_line < @spec_file.content_lines.length
        script = @spec_file.content_lines[line..current_line].join("\n")
        return current_line if RubyCompiler.can_compile?(script)
        current_line += 1
      end
    end
  end
end
