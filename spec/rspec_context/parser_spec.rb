# frozen_string_literal: true

RSpec.describe RSpecContext::Parser do
  describe 'InstanceMethods' do
    describe '#parse_spec_file' do
      subject { instance.parse_spec_file }

      let(:instance) { described_class.new(spec_file) }
      let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
      let(:file_path) { fixtures_path.join('files/client.rb') }

      it { is_expected.to be_a(Array) }
      it { is_expected.to all(be_a(RSpecContext::RSpecMethod)) }
    end
  end
end
