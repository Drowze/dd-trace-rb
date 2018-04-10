require 'spec_helper'

require 'ddtrace/contrib/active_record/utils'

RSpec.describe Datadog::Contrib::ActiveRecord::Utils do

  describe '#normalize_vendor' do
    subject(:result) { described_class.normalize_vendor(value) }

    context 'when given' do
      context 'nil' do
        let(:value) { nil }
        it { is_expected.to eq('defaultdb') }
      end

      context 'sqlite3' do
        let(:value) { 'sqlite3' }
        it { is_expected.to eq('sqlite') }
      end

      context 'mysql2' do
        let(:value) { 'mysql2' }
        it { is_expected.to eq('mysql2') }
      end

      context 'postgresql' do
        let(:value) { 'postgresql' }
        it { is_expected.to eq('postgres') }
      end

      context 'customdb' do
        let(:value) { 'customdb' }
        it { is_expected.to eq(value) }
      end
    end
  end

  describe 'regression: retrieving database without an active connection does not raise an error' do
    before(:each) do
      ActiveRecord::Base.establish_connection('mysql2://root:root@127.0.0.1:53306/mysql')
      ActiveRecord::Base.remove_connection
    end

    after(:each) { ActiveRecord::Base.establish_connection('mysql2://root:root@127.0.0.1:53306/mysql') }

    it do
      expect { described_class.adapter_name }.to_not raise_error
      expect { described_class.adapter_host }.to_not raise_error
      expect { described_class.adapter_port }.to_not raise_error
      expect { described_class.database_name }.to_not raise_error
    end
  end
end
