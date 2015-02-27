#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:oranfstab) do

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

    [:ensure, :nfsserver, :localips, :remoteips, :mounts].each do |property|
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

    describe "for nfsserver" do
      it "should support a  hostname" do
        proc { described_class.new(:name => 'TEST01E', :nfsserver => 'test-nactl01', :ensure => :present) }.should_not raise_error
      end
      it "should not support an invalid hostname" do
        proc { described_class.new(:name => 'TEST01E', :nfsserver => 'host#', :ensure => :present) }.should raise_error(Puppet::Error, /Nfsserver must contain a valid hostname:/)
        proc { described_class.new(:name => 'TEST01E', :nfsserver => 'invalid host', :ensure => :present) }.should raise_error(Puppet::Error, /Nfsserver must contain a valid hostname:/)
      end
      it "should not support an empty hostname" do
        proc { described_class.new(:name => "TEST01E", :nfsserver => '', :ensure => :present) }.should raise_error(Puppet::Error, /Nfsserver must contain a valid hostname:/)
      end
    end

    describe "for localips" do
      it "should support array" do
        proc { described_class.new(:name => 'TEST01E', :localips => ["192.168.1.1"]) }.should_not raise_error
        proc { described_class.new(:name => 'TEST01E', :localips => ["192.168.1.1", "192.168.1.2"]) }.should_not raise_error
      end
      it "should not support invalid IP contents" do
        proc { described_class.new(:name => "TEST01E", :localips => ["not an ip"], :ensure => :present) }.should raise_error(Puppet::Error, /Localips should contain valid IP address/)
      end
      it "should not support blank contents" do
        proc { described_class.new(:name => "TEST01E", :localips => [""], :ensure => :present) }.should raise_error(Puppet::Error, /Localips should not be blank/)
        proc { described_class.new(:name => "TEST01E", :localips => "", :ensure => :present) }.should raise_error(Puppet::Error, /Localips should not be blank/)
      end
    end

    describe "for remoteips" do
      it "should support array" do
        proc { described_class.new(:name => 'TEST01E', :remoteips => ["192.168.1.1"]) }.should_not raise_error
        proc { described_class.new(:name => 'TEST01E', :remoteips => ["192.168.1.1", "192.168.1.2"]) }.should_not raise_error
      end
      it "should not support invalid IP contents" do
        proc { described_class.new(:name => "TEST01E", :remoteips => ["not an ip"], :ensure => :present) }.should raise_error(Puppet::Error, /Remoteips should contain valid IP address/)
      end
      it "should not support blank contents" do
        proc { described_class.new(:name => "TEST01E", :remoteips => [""], :ensure => :present) }.should raise_error(Puppet::Error, /Remoteips should not be blank/)
        proc { described_class.new(:name => "TEST01E", :remoteips => "", :ensure => :present) }.should raise_error(Puppet::Error, /Remoteips should not be blank/)
      end
    end

    describe "for mounts" do
      it "should support array of hashes" do
        proc { described_class.new(:name => 'TEST01E', :mounts => [ {"export" => "/vol/volume/qtree", "path" => "/mountpoint"}]) }.should_not raise_error
      end
      it "should not support an array" do 
        proc { described_class.new(:name => "TEST01E", :mounts => ["not a hash"], :ensure => :present) }.should raise_error(Puppet::Error, /Mounts should be an array of hashes./)
      end
    end
    
  end
end

