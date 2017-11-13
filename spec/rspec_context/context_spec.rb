# frozen_string_literal: true

RSpec.describe RSpecContext::Context do
  describe 'InstanceMethods' do
    describe '#tree' do
      subject { instance.tree }
      let(:instance) { described_class.new(node) }
      let(:node) { spec_file.nodes.find(&:top_node?) }
      let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
      let(:file_path) { fixtures_path.join('files/client.rb') }

      it { is_expected.to be_a(Hash) }
    end

    describe '#to_context_hash' do
      subject { instance.to_context_hash }

      let(:instance) { described_class.new(node) }
      let(:node) { spec_file.nodes[10] }
      let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
      let(:file_path) { fixtures_path.join('files/client.rb') }

      it { is_expected.to be_a(Hash) }
    end
  end
end
