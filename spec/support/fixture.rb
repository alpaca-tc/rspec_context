# frozen_string_literal: true

require 'pathname'

Module.new do
  def fixtures_path
    Pathname.new(File.expand_path('../../fixtures', __FILE__))
  end

  RSpec.configuration.include(self)
end
