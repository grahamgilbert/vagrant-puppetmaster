# Class: ruby
#
# This class installs Ruby and manages rubygems
#
# Parameters:
#
#  version: (default installed)
#  Set the version of Ruby to install
#
#  gems_version: (default installed)
#  Set the version of Rubygems to be installed
#
#  rubygems_update: (default true)
#  If set to true, the module will ensure that the rubygems package is installed
#  but will use rubygems-update (same as gem update --system but versionable)
#  to update Rubygems to the version defined in $gems_version.
#  If set to false then the rubygems package resource will be versioned from
#  $gems_version
#
# Actions:
#   - Install Ruby
#   - Install Ruby Gems
#   - Update Ruby Gems
#
# Requires:
#
# Sample Usage:
#
# For a standard install using the latest Rubygems provided by rubygems-update on Redhat
#		use:
#		
#		  class { 'ruby': 
#       gems_version  => 'latest',
#     }
#		
#		On Redhat this is equivilant to
#		  $ yum install ruby rubygems
#		  $ gem update --system
#		
#		To install a specific version of ruby and rubygems but *not* use rubygems-update
#		use:
#		
#		  class { 'ruby':
#		    version         => '1.8.7',
#		    gems_version    => '1.8.24',
#		    rubygems_update => false
#		  }
#		
#		On Redhat this is equivilent to
#		  $ yum install ruby-1.8.7 rubygems-1.8.24
#		
#
class ruby ( 
    $version          = $ruby::params::version,
    $gems_version     = $ruby::params::gems_version,
    $rubygems_update  = $ruby::params::rubygems_update,
    $ruby_dev         = $ruby::params::ruby_dev,
    $ruby_package     = $ruby::params::ruby_package
) inherits ruby::params {

  package{ 'ruby':
    name  => $ruby_package,
    ensure => $version,
  }

  # if rubygems_update is set to true then we only need to make the package
  # resource for rubygems ensure to installed, we'll let rubygems-update
  # take care of the versioning.

  if $rubygems_update == true {
    $rubygems_ensure  = 'installed'
  } else {
    $rubygems_ensure  = $gems_version
  }

  package{'rubygems':
     ensure => $rubygems_ensure,
     require => Package['ruby'],
  }

  if $rubygems_update {
    package { 'rubygems-update':
      ensure    => $gems_version,
      provider  => 'gem',
      require   => Package['rubygems'],
    }

    exec { 'ruby::update_rubygems':
      path    => '/usr/local/bin:/usr/bin:/bin',
      command => 'update_rubygems',
      subscribe => Package['rubygems-update'],
      refreshonly => true,
    }
  }

}
