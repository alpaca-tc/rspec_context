# frozen_string_literal: true

RSpec.describe RSpecContext::Context do
  describe 'ClassMethods' do
    describe '.from_rspec_method' do
      subject { described_class.from_rspec_method(spec_file, rspec_method) }

      let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
      let(:file_path) { fixtures_path.join('files/client.rb') }

      context 'with first rspec_method' do
        let(:rspec_method) { spec_file.rspec_methods.first }

        it 'returns context' do
          subject
        end
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#to_context_hash' do
      subject { instance.to_context_hash }
      let(:instance) { described_class.from_rspec_method(spec_file, rspec_method) }
      let(:rspec_method) { spec_file.rspec_methods.last }
      let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
      let(:file_path) { fixtures_path.join('files/client.rb') }

      it { is_expected.to be_a(Hash) }
    end
  end
end
