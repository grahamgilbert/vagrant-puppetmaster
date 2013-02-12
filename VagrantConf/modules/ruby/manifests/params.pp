# Class: ruby::params
#
# This class handles the Ruby module parameters
#
# Parameters:
#   $ruby_dev = the name of the Ruby development libraries
# 
# Actions:
#
# Requires:
#
# Sample Usage:
#
class ruby::params {

  $version          = 'installed'
  $gems_version     = 'installed'
  $ruby_package     = 'ruby'

  case $osfamily {
    "redhat": {
      $ruby_dev="ruby-devel"
      $rubygems_update  = true
    }
    "debian": {
      $ruby_dev= [ "ruby-dev", "rake", "irb" ]
      $rubygems_update  = false
    }
  }

}

