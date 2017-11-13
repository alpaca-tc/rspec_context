# frozen_string_literal: true

module RSpecContext
  # rubocop:disable Style/MethodMissing
  module CleanRoom
    def method_missing(*)
      self
    end

    def const_missing(name)
      ::Class.new.tap do |klass|
        klass.extend(CleanRoom)

        # FIXME: How can i get class name from Class without Object namespace?
        ::Object.const_set(name, klass)

        const_set(name, klass)
      end
    end
  end
  # rubocop:enable Style/MethodMissing
end
