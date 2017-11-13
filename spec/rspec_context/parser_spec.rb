# frozen_string_literal: true

RSpec.describe RSpecContext::Parser do
  describe '.parse_spec_file' do
    subject { described_class.parse_spec_file(spec_file) }
    let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
    let(:file_path) { fixtures_path.join('files/client.rb') }

    it { is_expected.to be_a(Array) }
  end

  describe '#build_nodes' do
    subject { described_class.new(spec_file).build_nodes(rspec_methods) }
    let(:rspec_methods) { described_class.new(spec_file).parse_rspec_methods }
    let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
    let(:file_path) { fixtures_path.join('files/client.rb') }

    it { expect(subject.length).to eq(1) }
  end
end
