#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:oratab) do

  before do
    @provider_class = described_class.provide(:fake) { mk_resource_methods }
    @provider_class.stubs(:suitable?).returns true
    described_class.stubs(:defaultprovider).returns @provider_class
  end

  it "should have :name as its keyattribute" do
    described_class.key_attributes.should == [:name]
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end

    [:ensure, :home, :atboot, :description, :target].each do |property|
      it "should have a #{property} property" do
        described_class.attrtype(property).should == :property
      end
    end
  end

  describe "when validating value" do

    describe "for ensure" do
      it "should support present" do
        proc { described_class.new(:name => 'foo', :ensure => :present) }.should_not raise_error
      end

      it "should support absent" do
        proc { described_class.new(:name => 'foo', :ensure => :absent) }.should_not raise_error
      end

      it "should not support other values" do
        proc { described_class.new(:name => 'foo', :ensure => :foo) }.should raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "for name" do
      it "should support a valid name" do
        proc { described_class.new(:name => 'TEST01E', :ensure => :present) }.should_not raise_error
        proc { described_class.new(:name => 'MY_FANCY_DB', :ensure => :present) }.should_not raise_error
      end

      it "should not support whitespace" do
        proc { described_class.new(:name => 'TEST 01E', :ensure => :present) }.should raise_error(Puppet::Error, /Name.*whitespace/)
        proc { described_class.new(:name => 'TEST01E ', :ensure => :present) }.should raise_error(Puppet::Error, /Name.*whitespace/)
        proc { described_class.new(:name => ' TEST01E', :ensure => :present) }.should raise_error(Puppet::Error, /Name.*whitespace/)
        proc { described_class.new(:name => "TEST\t01E", :ensure => :present) }.should raise_error(Puppet::Error, /Name.*whitespace/)
      end

      it "should not support an empty name" do
        proc { described_class.new(:name => '', :ensure => :present) }.should raise_error(Puppet::Error, /Name.*empty/)
      end
    end

    describe "for home" do
      it "should support an absolute  path" do
        proc { described_class.new(:name => 'TEST01E', :home => '/my/home', :ensure => :present) }.should_not raise_error
        proc { described_class.new(:name => 'TEST01E', :home => '/my/fancy path', :ensure => :present) }.should_not raise_error
      end
      it "should not support a relative path" do
        proc { described_class.new(:name => 'TEST01E', :home => './my/home', :ensure => :present) }.should raise_error(Puppet::Error, /Home must be an absolute path/)
        proc { described_class.new(:name => 'TEST01E', :home => 'my/home', :ensure => :present) }.should raise_error(Puppet::Error, /Home must be an absolute path/)
      end
    end

    describe "for atboot" do
      it "should support yes" do
        proc { described_class.new(:name => 'TEST01E', :atboot => :yes) }.should_not raise_error
      end

      it "should support no" do
        proc { described_class.new(:name => 'TEST01E', :atboot => :no) }.should_not raise_error
      end
      it "should support Y" do
        proc { described_class.new(:name => 'TEST01E', :atboot => :Y) }.should_not raise_error
      end
      it "should support N" do
        proc { described_class.new(:name => 'TEST01E', :atboot => :N) }.should_not raise_error
      end
      it "should alias Y to yes" do
        described_class.new(:name => 'TEST01E', :atboot => :Y)[:atboot].should == :yes
      end
      it "should alias N to no" do
        described_class.new(:name => 'TEST01E', :atboot => :N)[:atboot].should == :no
      end
      it "should not support other values" do
        proc { described_class.new(:name => 'TEST01E', :atboot => :yess) }.should raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "for description" do
      it "should support a valid description" do
        proc { described_class.new(:name => 'TEST01E', :description => 'added by agent install') }.should_not raise_error
      end
    end

  end
end

