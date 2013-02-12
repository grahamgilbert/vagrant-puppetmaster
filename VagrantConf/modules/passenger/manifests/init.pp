# Class: passenger
#
# This class installs Passenger (mod_rails) on your system.
# http://www.modrails.com
#
# Parameters:
#   [*passenger_version*]
#     The Version of Passenger to be installed
#
#   [*gem_path*]
#     The path to rubygems on your system
#
#   [*gem_binary_path*]
#     Path to Rubygems binaries on your system
#
#   [*mod_passenger_location*]
#     Path to Passenger's mod_passenger.so file
#
#   [*passenger_provider*]
#     The package provider to use for the system
#
#   [*passenger_package*]
#     The name of the Passenger package
#
# Usage:
#
#  class { 'passenger':
#    passenger_version      => '3.0.9',
#    gem_path               => '/var/lib/gems/1.8/gems',
#    gem_binary_path        => '/var/lib/gems/1.8/bin',
#    mod_passenger_location => '/var/lib/gems/1.8/gems/passenger-3.0.9/ext/apache2/mod_passenger.so',
#    passenger_provider     => 'gem',
#    passenger_package      => 'passenger',
#  }
#
#
# Requires:
#   - apache
#   - apache::dev
#
class passenger (
  $passenger_version      = $passenger::params::passenger_version,
  $gem_path               = $passenger::params::gem_path,
  $gem_binary_path        = $passenger::params::gem_binary_path,
  $mod_passenger_location = $passenger::params::mod_passenger_location,
  $passenger_provider     = $passenger::params::passenger_provider,
  $passenger_package      = $passenger::params::passenger_package
) inherits passenger::params {

  include apache
  require apache::dev

  case $osfamily {
    'debian': {
      package { ['libopenssl-ruby', 'libcurl4-openssl-dev']:
        ensure => present,
        #before => Exec['compile-passenger'],
      }

      file { '/etc/apache2/mods-available/passenger.load':
        ensure  => present,
        content => template('passenger/passenger-load.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }

      file { '/etc/apache2/mods-available/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-enabled.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }

      file { '/etc/apache2/mods-enabled/passenger.load':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.load',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.load'],
      }

      file { '/etc/apache2/mods-enabled/passenger.conf':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.conf',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.conf'],
      }
    }
    'redhat': {
      package { 'libcurl-devel':
        ensure => present,
        #before => Exec['compile-passenger'],
      }

      file { '/etc/httpd/conf.d/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-conf.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }
    }
    default:{
      fail("Operating system ${::operatingsystem} is not supported with the Passenger module")
    }
  }

  package {'passenger':
    name     => $passenger_package,
    ensure   => $passenger_version,
    provider => $passenger_provider,
  }

  #exec {'compile-passenger':
  #  path      => [ $gem_binary_path, '/usr/bin', '/bin'],
  #  command   => 'passenger-install-apache2-module -a',
  #  logoutput => on_failure,
  #  creates   => $mod_passenger_location,
  #  require   => Package['passenger'],
  #}
}
