#Quick Manifest to stand up a demo Puppet Master
#include apt

##we'll need php and the current version of the php file as well.
##Need to install puppet dashboard and configure it
node default{
    


    
    #package { 'puppetdb-terminus': 
    #    ensure => latest,
    #}
    
    package {'libapache2-mod-php5':
      ensure  =>  latest,
    }
  
  host { 'puppet.pebbleit.dev':
    ensure       => 'present',
    host_aliases => ['puppet'],
    ip           => '192.168.33.10',
    target       => '/etc/hosts',
  }

  
  package {'puppetmaster':
    ensure  =>  latest,
    require => Host['puppet.pebbleit.dev'],
  }
    
  # Configure puppetdb and its underlying database
  class { 'puppetdb': 
    listen_address => '0.0.0.0',
    require => Package['puppetmaster'],
    puppetdb_version => latest,
    }
  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config': }
    
    class {'dashboard':
    #  dashboard_ensure          => 'present',
    #  dashboard_user            => 'puppet-dbuser',
    #  dashboard_group           => 'puppet-dbgroup',
    #  dashboard_password        => 'changeme',
    #  dashboard_db              => 'dashboard_prod',
    #  dashboard_charset         => 'utf8',
      dashboard_site            => $fqdn,
      dashboard_port            => '3000',
    #  mysql_root_pw             => 'changemetoo',
      #passenger                 => true,
      require                   => Package["puppetmaster"],
    }
    
    #service{'puppetmaster':
    #  ensure => running,
    #  require => Package['puppetmaster'],
    #  }
      
      
    ##we copy rather than symlinking as puppet will manage this
    file {'/etc/puppet/puppet.conf':
      ensure => present,
      owner => root,
      group => root,
      source => "/vagrant/puppet/puppet.conf",
      notify  =>  [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
      require => Package['puppetmaster'],
    }
    
    file {'/etc/puppet/autosign.conf':
      ensure => link,
      owner => root,
      group => root,
      source => "/vagrant/puppet/autosign.conf",
      notify  =>  [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
      require => Package['puppetmaster'],
    }
    
    file {'/etc/puppet/auth.conf':
      ensure => link,
      owner => root,
      group => root,
      source => "/vagrant/puppet/auth.conf",
      notify  =>  [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
      require => Package['puppetmaster'],
    }
    
    file {'/etc/puppet/fileserver.conf':
      ensure => link,
      owner => root,
      group => root,
      source => "/vagrant/puppet/fileserver.conf",
      notify  =>  [Service['puppetmaster'],Service['puppet-dashboard'],Service['puppet-dashboard-workers']],
      require => Package['puppetmaster'],
    }
    
    file {'/etc/puppet/modules':
      mode  => '0644',
      recurse => true,
    }
    
}