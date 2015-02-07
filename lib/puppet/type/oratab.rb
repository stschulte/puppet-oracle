require 'puppet/provider/parsedfile'

module Puppet
  newtype(:oratab) do

    @doc = "Define database instaces in /etc/oratab with instance name
      home directory and a flag which indicates if the instance should
      be started together with the database"

    newparam(:name) do
      desc "The instance's name"

      isnamevar

      validate do |value|
        raise Puppet::Error, "Name must not contain whitespace: #{value}" if value =~ /\s/
        raise Puppet::Error, "Name must not be empty" if value.empty?
      end
    end

    ensurable

    newproperty(:home) do
      desc "The home directory of the instance. This must be an absolute
        path"

      validate do |value|
         raise Puppet::Error, "Home must be an absolute path: #{value}" unless value =~ /^\//
      end
    end

    newproperty(:atboot) do
      desc "If the instance should start together with the database itself
        set this property to `yes` otherwise to `no`"

      newvalues :yes, :no
      aliasvalue :Y, :yes
      aliasvalue :N, :no
    end

    newproperty(:description) do
      desc "An optional description that will be added as an inline comment
        in the target file"

    end

    newproperty(:target) do
      desc "The path of the target file to store the instance information in"

      defaultto do
        if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
          @resource.class.defaultprovider.default_target
        end
      end
    end
  end
end
