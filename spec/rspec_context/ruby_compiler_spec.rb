# frozen_string_literal: true

RSpec.describe RSpecContext::RubyCompiler do
  describe 'ClassMethods' do
    describe '.can_compile?' do
      subject { described_class.can_compile?(script) }

      context 'with valid script' do
        let(:script) { 'foo()' }
        it { is_expected.to be true }
      end

      context 'with invalid script' do
        let(:script) { 'foo do' }
        it { is_expected.to be false }
      end
    end
  end
end
