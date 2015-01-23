#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:oratab) do

  it "should have :name as its keyattribute" do
    expect(described_class.key_attributes).to eq([:name])
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure, :home, :atboot, :description, :target].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe "when validating value" do

    describe "for ensure" do
      it "should support present" do
        expect { described_class.new(:name => 'foo', :ensure => :present) }.to_not raise_error
      end

      it "should support absent" do
        expect { described_class.new(:name => 'foo', :ensure => :absent) }.to_not raise_error
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'foo', :ensure => :foo) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "for name" do
      it "should support a valid name" do
        expect { described_class.new(:name => 'TEST01E', :ensure => :present) }.to_not raise_error
        expect { described_class.new(:name => 'MY_FANCY_DB', :ensure => :present) }.to_not raise_error
      end

      it "should not support whitespace" do
        expect { described_class.new(:name => 'TEST 01E', :ensure => :present) }.to raise_error(Puppet::Error, /Name.*whitespace/)
        expect { described_class.new(:name => 'TEST01E ', :ensure => :present) }.to raise_error(Puppet::Error, /Name.*whitespace/)
        expect { described_class.new(:name => ' TEST01E', :ensure => :present) }.to raise_error(Puppet::Error, /Name.*whitespace/)
        expect { described_class.new(:name => "TEST\t01E", :ensure => :present) }.to raise_error(Puppet::Error, /Name.*whitespace/)
      end

      it "should not support an empty name" do
        expect { described_class.new(:name => '', :ensure => :present) }.to raise_error(Puppet::Error, /Name.*empty/)
      end
    end

    describe "for home" do
      it "should support an absolute  path" do
        expect { described_class.new(:name => 'TEST01E', :home => '/my/home', :ensure => :present) }.to_not raise_error
        expect { described_class.new(:name => 'TEST01E', :home => '/my/fancy path', :ensure => :present) }.to_not raise_error
      end
      it "should not support a relative path" do
        expect { described_class.new(:name => 'TEST01E', :home => './my/home', :ensure => :present) }.to raise_error(Puppet::Error, /Home must be an absolute path/)
        expect { described_class.new(:name => 'TEST01E', :home => 'my/home', :ensure => :present) }.to raise_error(Puppet::Error, /Home must be an absolute path/)
      end
    end

    describe "for atboot" do
      it "should support yes" do
        expect { described_class.new(:name => 'TEST01E', :atboot => :yes) }.to_not raise_error
      end

      it "should support no" do
        expect { described_class.new(:name => 'TEST01E', :atboot => :no) }.to_not raise_error
      end
      it "should support Y" do
        expect { described_class.new(:name => 'TEST01E', :atboot => :Y) }.to_not raise_error
      end
      it "should support N" do
        expect { described_class.new(:name => 'TEST01E', :atboot => :N) }.to_not raise_error
      end
      it "should alias Y to yes" do
        expect(described_class.new(:name => 'TEST01E', :atboot => :Y)[:atboot]).to eq(:yes)
      end
      it "should alias N to no" do
        expect(described_class.new(:name => 'TEST01E', :atboot => :N)[:atboot]).to eq(:no)
      end
      it "should not support other values" do
        expect { described_class.new(:name => 'TEST01E', :atboot => :yess) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "for description" do
      it "should support a valid description" do
        expect { described_class.new(:name => 'TEST01E', :description => 'added by agent install') }.to_not raise_error
      end
    end

  end
end
