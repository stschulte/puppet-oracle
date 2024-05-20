#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:oratab) do
  it 'has :name as its keyattribute' do
    expect(described_class.key_attributes).to eq([:name])
  end

  describe 'when validating attributes' do
    [:name, :provider].each do |param|
      it "has a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure, :home, :atboot, :description, :target].each do |property|
      it "has a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe 'when validating value' do
    describe 'for ensure' do
      it 'supports present' do
        expect { described_class.new(name: 'foo', ensure: :present) }.not_to raise_error
      end

      it 'supports absent' do
        expect { described_class.new(name: 'foo', ensure: :absent) }.not_to raise_error
      end

      it 'does not support other values' do
        expect { described_class.new(name: 'foo', ensure: :foo) }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    describe 'for name' do
      it 'supports a valid name' do
        expect { described_class.new(name: 'TEST01E', ensure: :present) }.not_to raise_error
        expect { described_class.new(name: 'MY_FANCY_DB', ensure: :present) }.not_to raise_error
      end

      it 'does not support whitespace' do
        expect { described_class.new(name: 'TEST 01E', ensure: :present) }.to raise_error(Puppet::Error, %r{Name.*whitespace})
        expect { described_class.new(name: 'TEST01E ', ensure: :present) }.to raise_error(Puppet::Error, %r{Name.*whitespace})
        expect { described_class.new(name: ' TEST01E', ensure: :present) }.to raise_error(Puppet::Error, %r{Name.*whitespace})
        expect { described_class.new(name: "TEST\t01E", ensure: :present) }.to raise_error(Puppet::Error, %r{Name.*whitespace})
      end

      it 'does not support an empty name' do
        expect { described_class.new(name: '', ensure: :present) }.to raise_error(Puppet::Error, %r{Name.*empty})
      end
    end

    describe 'for home' do
      it 'supports an absolute path' do
        expect { described_class.new(name: 'TEST01E', home: '/my/home', ensure: :present) }.not_to raise_error
        expect { described_class.new(name: 'TEST01E', home: '/my/fancy path', ensure: :present) }.not_to raise_error
      end
      it 'does not support a relative path' do
        expect { described_class.new(name: 'TEST01E', home: './my/home', ensure: :present) }.to raise_error(Puppet::Error, %r{Home must be an absolute path})
        expect { described_class.new(name: 'TEST01E', home: 'my/home', ensure: :present) }.to raise_error(Puppet::Error, %r{Home must be an absolute path})
      end
    end

    describe 'for atboot' do
      it 'supports yes' do
        expect { described_class.new(name: 'TEST01E', atboot: :yes) }.not_to raise_error
      end

      it 'supports no' do
        expect { described_class.new(name: 'TEST01E', atboot: :no) }.not_to raise_error
      end
      it 'supports Y' do
        expect { described_class.new(name: 'TEST01E', atboot: :Y) }.not_to raise_error
      end
      it 'supports N' do
        expect { described_class.new(name: 'TEST01E', atboot: :N) }.not_to raise_error
      end
      it 'aliases Y to yes' do
        expect(described_class.new(name: 'TEST01E', atboot: :Y)[:atboot]).to eq(:yes)
      end
      it 'aliases N to no' do
        expect(described_class.new(name: 'TEST01E', atboot: :N)[:atboot]).to eq(:no)
      end
      it 'does not support other values' do
        expect { described_class.new(name: 'TEST01E', atboot: :yess) }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    describe 'for description' do
      it 'supports a valid description' do
        expect { described_class.new(name: 'TEST01E', description: 'added by agent install') }.not_to raise_error
      end
    end
  end
end
