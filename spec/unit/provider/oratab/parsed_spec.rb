#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:oratab).provider(:parsed) do

  before :each do
    described_class.stubs(:suitable?).returns true
    described_class.stubs(:default_target).returns my_fixture('oratab')
    Puppet::Type.type(:oratab).stubs(:defaultprovider).returns described_class
    @resource = Puppet::Type.type(:oratab).new(
      :name        => 'TEST01',
      :ensure      => :present,
      :home        => '/u01/app/oracle/product/9.2.0.1.0',
      :atboot      => :yes,
      :description => 'managed by puppet'
    )
    @provider = described_class.new(@resource)
  end

  [:destroy, :create, :exists?].each do |method|
    it "should respond to #{method}" do
      @provider.should respond_to method
    end
  end

  [:home, :atboot, :description].each do |property|
    it "should have getter and setter for property #{property}" do
      @provider.should respond_to property
      @provider.should respond_to "#{property}=".intern
    end
  end

  describe "when parsing a line" do

    describe "with no description" do
      it "should capture the name" do
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N')[:name].should == 'TEST'
        described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:N')[:name].should == 'TEST_01'
      end

      it "should capture the home directory" do
        described_class.parse_line('TEST:/db_1:N')[:home].should == '/db_1'
        described_class.parse_line('TEST:/db_1:Y')[:home].should == '/db_1'
        described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:Y')[:home].should == '/app/oracle/db/11.2/db_1'
      end

      it "should capture the atboot flag" do
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N')[:atboot].should == :no
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:Y')[:atboot].should == :yes
      end
    end

    describe "with a description" do
      it "should capture the name" do
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N # fancy comment')[:name].should == 'TEST'
        described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:N # even ## fancier')[:name].should == 'TEST_01'
      end
      it "should capture the home directory" do
        described_class.parse_line('TEST:/db_1:N # fancy comment')[:home].should == '/db_1'
        described_class.parse_line('TEST_01:/app/oracle/db/11.2/db_1:Y# even ## fancier')[:home].should == '/app/oracle/db/11.2/db_1'
      end
      it "should capture the atboot flag" do
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N # fancy comment')[:atboot].should == :no
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:Y## even ## fancier')[:atboot].should == :yes
      end
      it "should capture the description" do
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:N # fancy comment')[:description].should == 'fancy comment'
        described_class.parse_line('TEST:/app/oracle/db/11.2/db_1:Y## even ## fancier')[:description].should == '# even ## fancier'
      end
    end
  end

  describe "when calling instances" do
    before :each do
      @instances = described_class.instances
      @instances.size.should == 3
    end

    it "should be able to get the first entry" do
      @instances[0].get(:name).should == 'TEST'
      @instances[0].get(:home).should == '/app/oracle/db/11.2/db_1'
      @instances[0].get(:atboot).should == :no
      @instances[0].get(:description).should == 'line added by Agent'
    end

    it "should be able to get the second entry" do
      @instances[1].get(:name).should == 'PROD'
      @instances[1].get(:home).should == '/app/oracle/db/11.2/db_2'
      @instances[1].get(:atboot).should == :yes
      @instances[1].get(:description).should == :absent
    end

    it "should be able to get the third entry" do
      @instances[2].get(:name).should == 'DR'
      @instances[2].get(:home).should == '/app/oracle/db/11.2/db_4'
      @instances[2].get(:atboot).should == :no
      @instances[2].get(:description).should == 'i am still # an inline comment'
    end
  end

end
