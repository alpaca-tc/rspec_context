# frozen_string_literal: true

require 'stringio'

module RSpecContext
  module RubyCompiler
    class << self
      def can_compile?(script)
        suppress_output do
          RubyVM::InstructionSequence.compile(script, nil, nil, nil, compile_options)
        end

        true
      rescue SyntaxError
        false
      end

      private

      def suppress_output
        original_stdout = $stdout.clone
        original_stderr = $stderr.clone

        null = File.open('/dev/null', 'w')
        $stdout.reopen(null)
        $stderr.reopen(null)

        yield
      ensure
        $stdout.reopen(original_stdout)
        $stderr.reopen(original_stderr)
        null.close
      end

      def compile_options
        {
          inline_const_cache: false,
          instructions_unification: false,
          operands_unification: false,
          peephole_optimization: false,
          specialized_instruction: false,
          stack_caching: false,
          tailcall_optimization: false,
          trace_instruction: false
        }
      end
    end
  end
end
