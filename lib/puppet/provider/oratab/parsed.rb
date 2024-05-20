# frozen_string_literal: true

require 'puppet/provider/parsedfile'

oratab = case Facter.value(:operatingsystem)
         when 'Solaris'
           '/var/opt/oracle/oratab'
         else
           '/etc/oratab'
         end

Puppet::Type.type(:oratab).provide(:parsed, parent: Puppet::Provider::ParsedFile, default_target: oratab, filetype: :flat) do
  text_line :comment, match: %r{^\s*#}
  text_line :blank, match: %r{^\s*$}

  record_line :parsed, fields: ['name', 'home', 'atboot', 'description'],
    optional: ['description'],
    match: %r{^\s*(.*?):(.*?):(.*?)\s*(?:#\s*(.*))?$},
    post_parse: proc { |h|
      h[:atboot] = :yes if h[:atboot] == 'Y'
      h[:atboot] = :no if h[:atboot] == 'N'
      h
    },
    pre_gen: proc { |h|
      h[:atboot] = 'Y' if h[:atboot] == :yes
      h[:atboot] = 'N' if h[:atboot] == :no
      h
    },
    to_line: proc { |h|
      str = "#{h[:name]}:#{h[:home]}:#{h[:atboot]}"
      if ((description = h[:description])) && (description != :absent) && !description.empty?
        str += " # #{description}"
      end
      str
    }
end
