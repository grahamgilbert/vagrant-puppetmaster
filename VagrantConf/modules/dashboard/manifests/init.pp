# Class: puppet::dashboard
#
# This class installs and configures parameters for Puppet Dashboard
#
# Parameters:
#   [*dashboard_ensure*]
#     - The value of the ensure parameter for the
#       puppet-dashboard package
#
#   [*dashboard_user*]
#     - Name of the puppet-dashboard database and
#       system user
#
#   [*dashboard_group*]
#     - Name of the puppet-dashboard group
#
#   [*dashbaord_password*]
#     - Password for the puppet-dashboard database use
#
#   [*dashboard_db*]
#     - The puppet-dashboard database name
#
#   [*dashboard_charset*]
#     - Character set for the puppet-dashboard database
#
#   [*dashboard_site*]
#     - The ServerName setting for Apache
#
#   [*dashboard_port*]
#     - The port on which puppet-dashboard should run
#
#   [*mysql_root_pw*]
#     - Password for root on MySQL
#
#   [*passenger*]
#     - Boolean to determine whether Dashboard is to be
#       used with Passenger
#
#   [*mysql_package_provider*]
#     - The package provider to use when installing
#       the ruby-mysql package
#
#   [*ruby_mysql_package*]
#     - The package name for the ruby-mysql package
#
#   [*dashboard_config*]
#     - The Dashboard configuration file
#
#   [*dashboard_root*]
#     - The path to the Puppet Dashboard library
#
#   [*rack_version*]
#     - The version of the rack gem to install
#
# Actions:
#
# Requires:
# Class['mysql']
# Class['mysql::ruby']
# Class['mysql::server']
# Apache::Vhost[$dashboard_site]
#
# Sample Usage:
#   class {'dashboard':
#     dashboard_ensure       => 'present',
#     dashboard_user         => 'puppet-dbuser',
#     dashboard_group        => 'puppet-dbgroup',
#     dashboard_password     => 'changemme',
#     dashboard_db           => 'dashboard_prod',
#     dashboard_charset      => 'utf8',
#     dashboard_site         => $fqdn,
#     dashboard_port         => '8080',
#     mysql_root_pw          => 'REALLY_change_me',
#     passenger              => true,
#   }
#
#  Note: SELinux on Redhat needs to be set separately to allow access to the
#   puppet-dashboard.
#
class dashboard (
  $dashboard_ensure         = $dashboard::params::dashboard_ensure,
  $dashboard_user           = $dashboard::params::dashboard_user,
  $dashboard_group          = $dashboard::params::dashboard_group,
  $dashboard_password       = $dashboard::params::dashboard_password,
  $dashboard_db             = $dashboard::params::dashboard_db,
  $dashboard_charset        = $dashboard::params::dashboard_charset,
  $dashboard_site           = $dashboard::params::dashboard_site,
  $dashboard_port           = $dashboard::params::dashboard_port,
  $dashboard_config         = $dashboard::params::dashboard_config,
  $mysql_root_pw            = $dashboard::params::mysql_root_pw,
  $passenger                = $dashboard::params::passenger,
  $mysql_package_provider   = $dashboard::params::mysql_package_provider,
  $ruby_mysql_package       = $dashboard::params::ruby_mysql_package,
  $dashboard_config         = $dashboard::params::dashboard_config,
  $dashboard_root           = $dashboard::params::dashboard_root,
  $rack_version             = $dashboard::params::rack_version
) inherits dashboard::params {

  require mysql
  class { 'mysql::server':
    config_hash => { 'root_password' => $mysql_root_pw }
  }
  class { 'mysql::ruby':
    package_provider => $mysql_package_provider,
    package_name     => $ruby_mysql_package,
  }

  if $passenger {
    class { 'dashboard::passenger':
      dashboard_site   => $dashboard_site,
      dashboard_port   => $dashboard_port,
      dashboard_config => $dashboard_config,
      dashboard_root   => $dashboard_root,
    }
  } else {
    file { 'dashboard_config':
      ensure  => present,
      path    => $dashboard_config,
      content => template("dashboard/config.${::osfamily}.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0644',
      require => Package[$dashboard_package],
    }

    service { $dashboard_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      subscribe  => File['/etc/puppet-dashboard/database.yml'],
      require    => Exec['db-migrate']
    }
  }

  package { $dashboard_package:
    ensure  => $dashboard_version,
    require => [ Package['rdoc'], Package['rack']],
  }

  # Currently, the dashboard requires this specific version
  #  of the rack gem. Using the gem provider by default.
  package { 'rack':
    ensure   => $rack_version,
    provider => 'gem',
  }

  package { ['rake', 'rdoc']:
    ensure   => present,
    provider => 'gem',
  }

  File {
    mode    => '0755',
    owner   => $dashboard_user,
    group   => $dashboard_group,
    require => Package[$dashboard_package],
  }

  file { [ "${dashboard::params::dashboard_root}/public", "${dashboard::params::dashboard_root}/tmp", "${dashboard::params::dashboard_root}/log", '/etc/puppet-dashboard' ]:
    ensure       => directory,
    recurse      => true,
    recurselimit => '1',
  }

  file {'/etc/puppet-dashboard/database.yml':
    ensure  => present,
    content => template('dashboard/database.yml.erb'),
  }

  file { "${dashboard::params::dashboard_root}/config/database.yml":
    ensure => 'symlink',
    target => '/etc/puppet-dashboard/database.yml',
  }

  file { [ "${dashboard::params::dashboard_root}/log/production.log", "${dashboard::params::dashboard_root}/config/environment.rb" ]:
    ensure => file,
    mode   => '0644',
  }

  file { '/etc/logrotate.d/puppet-dashboard':
    ensure  => present,
    content => template('dashboard/logrotate.erb'),
    owner   => '0',
    group   => '0',
    mode    => '0644',
  }

  exec { 'db-migrate':
    command => 'rake RAILS_ENV=production db:migrate',
    cwd     => $dashboard::params::dashboard_root,
    path    => '/usr/bin/:/usr/local/bin/',
    creates => "/var/lib/mysql/${dashboard_db}/nodes.frm",
    require => [Package[$dashboard_package], Mysql::Db[$dashboard_db],
                File["${dashboard::params::dashboard_root}/config/database.yml"]],
  }

  mysql::db { $dashboard_db:
    user     => $dashboard_user,
    password => $dashboard_password,
    charset  => $dashboard_charset,
  }

  user { $dashboard_user:
      ensure     => 'present',
      comment    => 'Puppet Dashboard',
      gid        => $dashboard_group,
      shell      => '/sbin/nologin',
      managehome => true,
      home       => "/home/${dashboard_user}",
  }

  group { $dashboard_group:
      ensure => 'present',
  }
}

