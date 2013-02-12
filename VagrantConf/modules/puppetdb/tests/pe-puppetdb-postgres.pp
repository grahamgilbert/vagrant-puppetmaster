# This manifest shows an example of how you might set up puppetdb to work with
# a Puppet Enterprise environment consisting of a puppet master and a puppetdb
# server, as opposed to puppet open source.

node 'puppetmaster.example.com' {
  class { 'puppetdb::master::config':
    puppetdb_server     => 'puppetdb.example.com',
    puppet_confdir      => '/etc/puppetlabs/puppet',
    terminus_package    => 'pe-puppetdb-terminus',
    puppet_service_name => 'pe-httpd',
  }
}

node 'puppetdb.example.com' {
  class { 'puppetdb':
    puppetdb_package => 'pe-puppetdb',
    puppetdb_service => 'pe-puppetdb',
    confdir          => '/etc/puppetlabs/puppetdb/conf.d',
  }
}
