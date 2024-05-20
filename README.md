# Puppet Oracle Module

[![Build Status](https://github.com/stschulte/puppet-oracle/actions/workflows/main.yml/badge.svg)](https://github.com/stschulte/puppet-oracle/actions/workflows/main.yml)
[![Coverage Status](https://coveralls.io/repos/stschulte/puppet-oracle/badge.svg)](https://coveralls.io/r/stschulte/puppet-oracle)
[![Puppet Forge](https://img.shields.io/puppetforge/v/stschulte/oracle.svg)](https://forge.puppet.com/stschulte/oracle)

This repository aims to ease the configuration of Oracle
Databases with custom types and providers

## New facts

(currently none)

## New functions

(currently none)

## New custom types

### oratab

The oratab file stores information about the home directory of your databases and whether
the different instances should be automatically started and stopped by the dbstart and
dbshut scripts or not.

The oratab type now allows you to treat a single entry as a resource:

    oratab { 'PROD_DB':
      ensure => present,
      home   => '/u01/app/oracle/product/10.1.0/db_1',
      atboot => yes,
    }

The example above will lead to the following entry in the file `/etc/oratab` (or `/var/opt/oracle/oratab` on Solaris)

    PROD_DB:/u01/app/oracle/product/10.1.0/db_1:Y

You can also specify an inline comment with the description property. This is however optional.

    oratab { 'PROD_DB':
      ensure      => present,
      home        => '/u01/app/oracle/product/10.1.0/db_1',
      atboot      => yes,
      description => 'managed by puppet'
    }

will lead to

    PROD_DB:/u01/app/oracle/product/10.1.0/db_1:Y # managed by puppet

If you do not specifiy the description property, puppet will not touch the current inline comment.
This might interest you because newer versions of oracle always update the comment as
`line added by agent` on each instance stop and start.

## Running tests

Before running tests ensure you have all dependencies installed

```
bundle install
```

You can now generate documentation and run tests

```
bundle exec rake syntax lint metadata_lint check:symlinks check:git_ignore check:dot_underscore check:test_file rubocop
bundle exec rake spec

```
