# Class: ruby
#
# This class installs Ruby and manages rubygems
#
# Parameters:
#
#  version: (default installed)
#    Set the version of Ruby to install
#
#  gems_version: (default installed)
#    Set the version of Rubygems to be installed
#
#  rubygems_update: (default true)
#    If set to true, the module will ensure that the rubygems package is
#    installed but will use rubygems-update (same as gem update --system
#    but versionable) to update Rubygems to the version defined in
#    $gems_version. If set to false then the rubygems package resource
#    will be versioned from $gems_version
#
#  ruby_package: (default ruby)
#    Set the package name for ruby
#
#  rubygems_package: (default rubygems)
#    Set the package name for rubygems
#
# Actions:
#   - Install Ruby
#   - Install Rubygems
#   - Update Rubygems
#
# Requires:
#
# Sample Usage:
#
#  For a standard install using the latest Rubygems provided by
#  rubygems-update on Redhat use:
#
#    class { 'ruby':
#      gems_version  => 'latest',
#    }
#
#  On Redhat this is equivilant to
#    $ yum install ruby rubygems
#    $ gem update --system
#
#  To install a specific version of ruby and rubygems
#  but *not* use rubygems-update use:
#
#    class { 'ruby':
#      version         => '1.8.7',
#      gems_version    => '1.8.24',
#      rubygems_update => false,
#    }
#
#  On Redhat this is equivalent to
#    $ yum install ruby-1.8.7 rubygems-1.8.24
#
#  If you need to use different packages for either ruby or rubygems you
#  can. This could be for different versions or custom packages. For instance
#  the following installs ruby 1.9 on Ubuntu 12.04.
#
#    class { 'ruby':
#      ruby_package     => 'ruby1.9.1-full',
#      rubygems_package => 'rubygems1.9.1',
#      gems_version     => 'latest',
#    }
#
# Ruby package names are not straightforward. Especially in Debian
# osfamily Linux distributions
# ruby is a virtual package that points to ruby1.8
# ruby1.8 installs Ruby 1.8.7 (and earlier versions)
# ruby1.9.1 installs Ruby 1.9.1
# ruby1.9.1-full installs Ruby 1.9.1
# ruby1.9.3 installs Ruby 1.9.3
# Ruby 2.0.0 is availible from a PPA or Ubuntu 13.10 or later.
# Ruby 2.1.0 is availible from a PPA or Ubuntu 13.10 or later.
# ...and this should all be overridden if a package is specified
#
class ruby (
  $version            = $ruby::params::version,
  $latest_release     = undef,
  $gems_version       = $ruby::params::gems_version,
  $rubygems_update    = $ruby::params::rubygems_update,
  $ruby_package       = $ruby::params::ruby_package,
  $ruby_dev_packages  = $ruby::params::ruby_dev,
  $rubygems_package   = $ruby::params::rubygems_package,
  $switch             = undef
) inherits ruby::params {

  if $latest_release {
    $ruby_package_ensure = 'latest'
  } else {
    $ruby_package_ensure = 'installed'
  }

  case $::osfamily {
    Debian: {
      case $ruby_package {
        installed: {
          $real_ruby_package  = $ruby_package
        }
        default:{
          case $version {
            /^1\.8.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}1.8"
            }
            /^1\.9.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}${version}"
            }
            /^2\.0.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}2.0"
            }
            /^2\.1.*$/:{
              $real_ruby_package  = "${ruby::params::ruby_package}2.1"
            }
            default: {
              $real_ruby_package  = $ruby_package
            }
          }
        }
      }
    }
    default: {
      $real_ruby_package  = $ruby_package
    }
  }

  package { 'ruby':
    ensure => $ruby_package_ensure,
    name   => $real_ruby_package,
  }

  # if rubygems_update is set to true then we only need to make the package
  # resource for rubygems ensure to installed, we'll let rubygems-update
  # take care of the versioning.

  if $rubygems_update == true {
    $rubygems_ensure = 'installed'
  } else {
    $rubygems_ensure = $gems_version
  }

  package { 'rubygems':
    ensure  => $rubygems_ensure,
    name    => $rubygems_package,
    require => Package['ruby'],
  }

  if $rubygems_update {
    package { 'rubygems-update':
      ensure    => $gems_version,
      provider  => 'gem',
      require   => Package['rubygems'],
    }

    exec { 'ruby::update_rubygems':
      path        => '/usr/local/bin:/usr/bin:/bin',
      command     => 'update_rubygems',
      refreshonly => true,
      subscribe   => Package['rubygems-update'],
    }
  }

  if $switch {
    case $::operatingsystem {
      Ubuntu: {
        if versioncmp($::lsbdistrelease, '14.04') < 0 {
          package{'ruby-switch':
            ensure  => installed,
            name    => $ruby::params::ruby_switch_package,
            require => Package['ruby'],
          }

          # The ruby<VERSION>-full package names cannot be used as arguments to
          # ruby-switch so handle these cases explicitly.
          $ruby_interpreter = $real_ruby_package ? {
            'ruby1.8-full'   => 'ruby1.8',
            'ruby1.9.1-full' => 'ruby1.9.1',
            default          => $real_ruby_package,
          }

          exec{'switch_ruby':
            command => "/usr/bin/ruby-switch --set ${ruby_interpreter}",
            unless  => "/usr/bin/ruby-switch --check|/bin/grep ${ruby_interpreter}",
            require => Package['ruby-switch'],
          }
        } else {
          notice('The ruby-switch package is no longer provided for Ubuntu versions later than 14.04.')
        }
      }
      default: {
        notice("The switch parameter for the ruby class does not work for ${::operatingsystem}, no action taken.")
      }
    }
  }
}
