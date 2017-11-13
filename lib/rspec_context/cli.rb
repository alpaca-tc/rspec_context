require 'optparse'
require 'json'

module RSpecContext
  class Cli
    def initialize(argv)
      @argv = argv
      @file_path = nil
      @command = :tree

      parse_options
    end

    def run
      case @command
      when :tree
        unless @file_path
          $stderr.puts("file_path not exists")
          exit
        end

        spec_file = SpecFile.new(@file_path)
        top_node = spec_file.nodes.find(&:top_node?)
        context = Context.new(top_node)
        puts JSON.dump(context.tree)
      end
    end

    private

    def parse_options
      option_parser.new.parse(@argv.clone)
    end

    def option_parser
      ::OptionParser.new do |parser|
        parser.on('--file_path FILE_PATH', 'file path') do |file_path|
          file_path = File.expand_path(file_path)
          @file_path = file_path if File.exist?(file_path)
        end
      end
    end
  end
end
