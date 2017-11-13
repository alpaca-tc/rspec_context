RSpec.describe RSpecContext::NodeBuilder do
  def build_rspec_method(range:)
    RSpecContext::RSpecMethod.new(spec_file, :example_method, range.begin).tap do |instance|
      allow(instance).to receive(:range).and_return(range)
    end
  end

  describe '#build_nodes' do
    subject { described_class.new(rspec_methods).build_nodes }

    let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
    let(:file_path) { fixtures_path.join('files/client.rb') }

    let(:rspec_methods) do
      [
        build_rspec_method(range: 0..10),
        build_rspec_method(range: 1..1),
        build_rspec_method(range: 3..9),
        build_rspec_method(range: 4..8)
      ]
    end

    it { is_expected.to be_a(Array) }
    it { is_expected.to all(be_a(RSpecContext::Node)) }

    it 'build nodes' do
      node = subject.pop

      expect(node.rspec_method).to eq(rspec_methods[0])
      expect(node.children[0].rspec_method).to eq(rspec_methods[1])
      expect(node.children[1].rspec_method).to eq(rspec_methods[2])
      expect(node.children[1].children[0].rspec_method).to eq(rspec_methods[3])
    end
  end
end
