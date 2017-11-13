RSpec.describe RSpecContext::Parser do
  describe '.parse_spec_file' do
    subject { described_class.parse_spec_file(spec_file) }
    let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
    let(:file_path) { fixtures_path.join('files/client.rb') }

    it { is_expected.to be_a(Array) }
  end
end
