require 'puppet/provider/parsedfile'

module Puppet
  newtype(:oranfstab) do

    @doc = "Define database mount points in /etc/oranfstab."

    newparam(:name) do
      desc "The instance's name."
      isnamevar

      validate do |value|
        raise Puppet::Error, "Name must not contain whitespace: #{value}" if value =~ /\s/
        raise Puppet::Error, "Name must not be empty" if value.empty?
      end
    end

    ensurable

    newproperty(:nfsserver) do
      desc "The NFS Server hostname for this instance."
      validate do |value|
        raise Puppet::Error, "Nfsserver must contain a valid hostname: #{value}" unless value =~ /^[\w-]+$/
        raise Puppet::Error, "Nfsserver must not be empty" if value.empty?
      end
    end

    newproperty(:localips, :array_matching => :all) do
      desc "The local IP(s) to use."
      validate do |value|
        raise Puppet::Error, "Localips should not be blank." if value.empty?
        raise Puppet::Error, "Localips should contain valid IP address': #{value}" unless value =~ /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/
      end
    end

    newproperty(:remoteips, :array_matching => :all) do
      desc "The remote IP(s) to use."
      validate do |value|
        raise Puppet::Error, "Remoteips should not be blank." if value.empty?
        raise Puppet::Error, "Remoteips should contain valid IP address': #{value}" unless value =~ /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/
      end
    end

    newproperty(:mounts, :array_matching => :all) do
      desc "Array of mounts"
      validate do |value|
        raise Puppet::Error, "Mounts should be an array of hashes." unless value.is_a?(Hash)
      end
      
      def insync?(is)
        if is.is_a?(Array)
          #  array of hashes doesn't support .sort
          return is.sort_by(&:hash) == @should.sort_by(&:hash)
        else
          return is == @should
        end
      end

      def should_to_s(newvalue)
        if newvalue == :absent
          return "absent"
        else 
          newvalue
        end
      end
    end

  end
end
