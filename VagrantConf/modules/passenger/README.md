# Passenger Module

This module is used for configuring Passenger (http://www.modrails.com)

# Quick Start

This module was developed and tested against RHEL and Debian based systems (Centos, Fedora, Redhat, Debian, Ubuntu). This module may require you to specify default parameter values to accommodate other distributions. 

To declare the class in your node declaration, you can do the following:

    node default {
      class {'passenger': }
    }

The Passenger module will attempt to apply sane default values to all its parameters, but you can manually specify them using the below syntax:

    node default {
      class {'passenger':
        passenger_version      => '2.2.11',
        passenger_provider     => 'gem',
        passenger_package      => 'passenger',
        gem_path               => '/var/lib/gems/1.8/gems',
        gem_binary_path        => '/var/lib/gems/1.8/bin',
        mod_passenger_location => '/var/lib/gems/1.8/gems/passenger-2.2.11/ext/apache2/mod_passenger.so',
      }
    }

# Dependencies

This module requires the Puppetlabs gcc and apache module for its functionality.  You may retrieve those modules from http://forge.puppetlabs.com
