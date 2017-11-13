# frozen_string_literal: true

RSpec.describe RSpecContext::Context do
  describe 'ClassMethods' do
    describe '.from_candidate' do
      subject { described_class.from_candidate(spec_file, candidate) }

      let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
      let(:file_path) { fixtures_path.join('files/client.rb') }

      context 'with first candidate' do
        let(:candidate) { spec_file.candidates.first }

        it 'returns context' do
          subject
        end
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#to_context_hash' do
      subject { instance.to_context_hash }
      let(:instance) { described_class.from_candidate(spec_file, candidate) }
      let(:candidate) { spec_file.candidates.last }
      let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
      let(:file_path) { fixtures_path.join('files/client.rb') }

      it { is_expected.to be_a(Hash) }
    end
  end
end
