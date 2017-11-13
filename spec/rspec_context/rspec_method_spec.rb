# frozen_string_literal: true

RSpec.describe RSpecContext::RSpecMethod do
  describe 'InstanceMethods' do
    let(:instance) { described_class.new(spec_file, type, method_name, line, rspec_prefix: rspec_prefix?) }
    let(:method_name) { 'describe' }
    let(:type) { :example_group_method }
    let(:line) { 9 }
    let(:spec_file) { RSpecContext::SpecFile.new(file_path) }
    let(:file_path) { fixtures_path.join('files/client.rb') }
    let(:rspec_prefix?) { false }

    describe '#name' do
      context 'given 9 as line' do
        subject { instance.name }
        it { is_expected.to eq('#run') }
      end

      context 'given 4 as line' do
        subject { instance.name }
        let(:rspec_prefix?) { true }
        let(:line) { 4 }
        it { is_expected.to eq(LanguageServerRails::Client) }
      end
    end

    describe '#cover?' do
      subject { instance.cover?(other) }
      let(:other) { described_class.new(spec_file, type, method_name, line) }

      before do
        instance.instance_variable_set(:@range, 1..10)
        other.instance_variable_set(:@range, range)
      end

      context 'given inside cnaidate' do
        let(:range) { 1..1 }
        it { is_expected.to be true }
      end

      context 'given outside cnaidate' do
        let(:range) { 11..11 }
        it { is_expected.to be false }
      end
    end
  end
end
