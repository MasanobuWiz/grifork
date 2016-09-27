require 'spec_helper'

require 'tempfile'

describe Grifork::DSL do
  describe '.load_file' do
    let(:content) { nil }
    before do
      @dsl = Tempfile.new
      File.write(@dsl.path, content)
    end

    after do
      File.unlink(@dsl.path)
    end

    subject { Grifork::DSL.load_file(@dsl.path) }

    context 'With valid DSL' do
      let(:content) do
        <<-EODSL
          branches 2
          log file: 'path/to/grifork.log'
          hosts ['web1', { hostname: 'db1', ipaddress: '192.168.1.1' }]
          local { p :local }
          remote { p :remote }
        EODSL
      end

      it 'Can load config' do
        expect { subject }.not_to raise_error
        dsl = subject
        expect(dsl).to be_an_instance_of(Grifork::DSL)
        config = dsl.instance_variable_get('@config')
        expect(config[:branches]).to eq 2
        expect(config[:log]).to be_an_instance_of(Grifork::Config::Log)
        expect(config[:hosts].size).to eq 2
        expect(config[:local_task]).to be_truthy
        expect(config[:remote_task]).to be_truthy
      end
    end

    context 'With invalid DSL' do
      let(:content) do
        <<-EODSL
          no_such_method :xxx
        EODSL
      end

      it 'Raise error' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end
end