require "bundler/setup"
require "rspec_context"
require 'rspec_context'
require 'pry' unless ENV['CI']

Dir[File.join(File.expand_path('../support', __FILE__), '**', '*.rb')].each { |file| require(file) }

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
end
