# frozen_string_literal: true

require 'fileutils'

RSpec.describe LanguageServerRails::Client do
  let(:instance) { described_class.new(project) }
  let(:project) { LanguageServerRails::Project.new(project_root) }
  let(:project_root) { __dir__ }

  describe '#run' do
    def subject
      instance.run(id: 1, command: 'eval', script: 'Object.constants')
    end

    before do
      allow(project.background_server).to receive(:server_running?).and_return(server_running?)
    end

    after do
      project.background_server.stop
    end

    let(:server_running?) { true }

    context 'when background server is not booting' do
      let(:server_running?) { false }
      it { is_expected.to be false }
    end

    context 'when background server is booting' do
      before do
        project.background_server.boot_server
      end

      it 'returns response' do
        # サーバーの起動を待ってみる
        sleep(10) if subject == false

        expect(subject['id']).to eq(1)
        expect(subject['status']).to eq('success')
        expect(subject['data']).to be_a(Array)
      end
    end
  end
end

RSpec.describe '#broken' do
  broken d o '
end
