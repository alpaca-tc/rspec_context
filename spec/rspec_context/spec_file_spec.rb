RSpec.describe RSpecContext::SpecFile do
  describe 'InstanceMethods' do
    let(:instance) { described_class.new(file_path) }
    let(:file_path) { fixtures_path.join('files/client.rb') }

    describe '#content_lines' do
      subject { instance.content_lines }
      it { is_expected.to be_a(Array).and(all(be_a(String))) }
    end

    describe '#nodes' do
      subject { instance.nodes }
      it { is_expected.to be_a(Array).and(all(be_a(RSpecContext::Node))) }
    end
  end
end
