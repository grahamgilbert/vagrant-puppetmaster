passenger
=========

Overview
--------

The Passenger module allows easy configuration and management of Phusion Passenger.      

Module Description
-------------------

The Passenger module lets you run Rails or Rack inside Apache with ease. Utilizing [Passenger](http://www.modrails.com), an application server for Ruby (Rack) and Python (WSGI) apps, the Passenger module enables quick configuration of Passenger for Apache. 

Setup
-----

**What Passenger affects:**

* Apache
* installs packages on chosen nodes 
* package/service/configuration files for Passenger
	
### Beginning with Passenger	

Install and begin managing Passenger on a node by declaring the class in your node definition:

    node default {
      class {'passenger': }
    }

This will establish Passenger on your node with sane default values. However, you can manually set the parameter values:

    node default {
      class {'passenger':
        passenger_version      => '2.2.11',
        passenger_provider     => 'gem',
        passenger_package      => 'passenger',
        gem_path               => '/var/lib/gems/1.8/gems',
        gem_binary_path        => '/var/lib/gems/1.8/bin',
        passenger_root         => '/var/lib/gems/1.8/gems/passenger-2.2.11'
        mod_passenger_location => '/var/lib/gems/1.8/gems/passenger-2.2.11/ext/apache2/mod_passenger.so',
      }
    }
 
Usage
------

The `passenger` class has a set of configurable parameters that allow you to control aspects of Passenger's installation. 

**Parameters within `passenger`**

####`passenger_version`

The Version of Passenger to be installed

####`gem_path`

The path to rubygems on your system

####`gem_binary_path`

Path to Rubygems binaries on your system

####`mod_passenger_location`

Path to Passenger's mod_passenger.so file

####`passenger_provider`

The package provider to use for the system

####`passenger_package`

The name of the Passenger package

Implementation
---------------

This module operates by compiling Ruby gems on the system being managed. 

Limitations
------------

This module was developed and tested against RHEL and Debian based systems (Centos, Fedora, Redhat, Debian, Ubuntu). This module may require you to specify default parameter values to accommodate other distributions.

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

Release Notes
--------------

**0.0.4 Release**

* Remove puppetlabs-gcc dependency
* Add package dependencies for Passenger 3.0
* Re-order resources (removing chaining syntax)