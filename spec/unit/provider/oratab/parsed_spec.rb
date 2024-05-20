#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:oratab).provider(:parsed) do
  before :each do
    allow(Puppet::Type.type(:oratab)).to receive(:defaultprovider).and_return(described_class)
    allow(described_class).to receive(:default_target).and_return(my_fixture('oratab'))
  end

  let :resource do
    Puppet::Type.type(:oratab).new(
      name: 'TEST01',
      ensure: :present,
      home: '/u01/app/oracle/product/9.2.0.1.0',
      atboot: :yes,
      description: 'managed by puppet',
    )
  end

  let :provider do
    described_class.new(resource)
  end

  [:destroy, :create, :exists?].each do |method|
    it "responds to #{method}" do
      expect(provider).to respond_to method
    end
  end

  [:home, :atboot, :description].each do |property|
    it "has getter and setter for property #{property}" do
      expect(provider).to respond_to property
      expect(provider).to respond_to "#{property}=".to_sym
    end
  end

  describe 'when parsing a line' do
    describe 'with no description' do
      it 'captures the name' do
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N')[:name]).to eq('TEST')
        expect(described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:N')[:name]).to eq('TEST_01')
      end

      it 'captures the home directory' do
        expect(described_class.parse_line('TEST:/db_1:N')[:home]).to eq('/db_1')
        expect(described_class.parse_line('TEST:/db_1:Y')[:home]).to eq('/db_1')
        expect(described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:Y')[:home]).to eq('/app/oracle/db/11.2/db_1')
      end

      it 'captures the atboot flag' do
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N')[:atboot]).to eq(:no)
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:Y')[:atboot]).to eq(:yes)
      end
    end

    describe 'with a description' do
      it 'captures the name' do
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N # fancy comment')[:name]).to eq('TEST')
        expect(described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:N # even ## fancier')[:name]).to eq('TEST_01')
      end
      it 'captures the home directory' do
        expect(described_class.parse_line('TEST:/db_1:N # fancy comment')[:home]).to eq('/db_1')
        expect(described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:Y# even ## fancier')[:home]).to eq('/app/oracle/db/11.2/db_1')
      end
      it 'captures the atboot flag' do
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N # fancy comment')[:atboot]).to eq(:no)
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:Y## even ## fancier')[:atboot]).to eq(:yes)
      end
      it 'captures the description' do
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N # fancy comment')[:description]).to eq('fancy comment')
        expect(described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:Y## even ## fancier')[:description]).to eq('# even ## fancier')
      end
    end
  end

  describe 'when calling instances' do
    it 'reads all instances' do
      instances = described_class.instances
      expect(instances.size).to eq(3)
      expect(instances[0].get(:name)).to eq('TEST')
      expect(instances[0].get(:home)).to eq('/app/oracle/db/11.2/db_1')
      expect(instances[0].get(:atboot)).to eq(:no)
      expect(instances[0].get(:description)).to eq('line added by Agent')
      expect(instances[1].get(:name)).to eq('PROD')
      expect(instances[1].get(:home)).to eq('/app/oracle/db/11.2/db_2')
      expect(instances[1].get(:atboot)).to eq(:yes)
      expect(instances[1].get(:description)).to eq(:absent)
      expect(instances[2].get(:name)).to eq('DR')
      expect(instances[2].get(:home)).to eq('/app/oracle/db/11.2/db_4')
      expect(instances[2].get(:atboot)).to eq(:no)
      expect(instances[2].get(:description)).to eq('i am still # an inline comment')
    end
  end
end
